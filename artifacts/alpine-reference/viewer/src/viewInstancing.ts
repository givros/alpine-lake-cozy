import * as T from 'three/webgpu';
import {gpuOcclusion} from './gpuOcclusion';

// Each pass owns its instance buffer: a reflection must never overwrite the main
// camera's visibility list, nor omit an offscreen object from the sun's shadows.
export function installViewInstancing(scene:T.Scene,mainCamera:T.Camera,sources:T.InstancedMesh[],stats:any,renderer:T.WebGPURenderer){
 const roles=['main','reflection','shadow'];
 const groups=roles.map((role,index)=>{const g=index===2?new T.Group():new T.BundleGroup();if(index!==2)(g as any).isBundleGroup=false;g.name='Instances_'+role;scene.add(g);return g;});
 // Build the first ordinary frame before recording bundles: shadow and reflected
 // camera bindings do not exist yet during the initial asynchronous compilation.
 stats.enableRenderBundles=()=>{for(const g of groups.slice(0,2))(g as any).isBundleGroup=true;};
 const families=sources.map(source=>{
  const matrices=new Float32Array(source.instanceMatrix.array.slice(0,source.count*16));
  if(!source.geometry.boundingSphere)source.geometry.computeBoundingSphere();const sphere=source.geometry.boundingSphere!;
  const bounds=new Float32Array(source.count*4),m=new T.Matrix4(),p=new T.Vector3();
  for(let i=0;i<source.count;i++){
   m.fromArray(matrices,i*16);p.copy(sphere.center).applyMatrix4(m);const e=m.elements;
   const scale=Math.max(Math.hypot(e[0],e[1],e[2]),Math.hypot(e[4],e[5],e[6]),Math.hypot(e[8],e[9],e[10]));
   bounds.set([p.x,p.y,p.z,sphere.radius*scale+.002],i*4);
  }
  const views=roles.map((role,index)=>{
   const mesh=index===0?source:new T.InstancedMesh(source.geometry,source.material,source.instanceMatrix.count);
   mesh.name=source.name+'_'+role;mesh.castShadow=mesh.receiveShadow=true;
   mesh.instanceMatrix.setUsage(T.StaticDrawUsage);mesh.instanceMatrix.array.set(matrices);mesh.count=source.count;
   mesh.boundingSphere=source.boundingSphere?.clone()??null;mesh.userData.sourceInstances=source.count;
   groups[index].add(mesh);return mesh;
  });
  return {matrices,bounds,count:source.count,views,lods:source.geometry.userData.lodLevels??[],treeVariant:source.geometry.userData.treeVariant};
 });
 const gpu=gpuOcclusion(renderer,scene,families,stats);
 const frustum=new T.Frustum(),vp=new T.Matrix4();const keys=['','',''];
 stats.instanceVisibility={families:families.length,total:families.reduce((n,f)=>n+f.count,0),passes:{}};
 scene.onBeforeRender=(_renderer,_scene,camera)=>{
  if(gpu.isPrepass())return;
  const index=camera===mainCamera?0:(camera as T.OrthographicCamera).isOrthographicCamera?2:1;
  groups.forEach((g,i)=>g.visible=i===index);
  stats.updateTreeImpostors?.(camera,index);
  if(index!==2){gpu.update(camera,index);return;}
  vp.multiplyMatrices(camera.projectionMatrix,camera.matrixWorldInverse);const key=vp.elements.join(',');
  if(keys[index]===key)return;keys[index]=key;
  frustum.setFromProjectionMatrix(vp,camera.coordinateSystem);const planes=frustum.planes;let active=0,triangles=0;
  for(const f of families){const target=f.views[index],out=target.instanceMatrix.array,b=f.bounds;let count=0;
   for(let i=0;i<f.count;i++){const j=i*4,x=b[j],y=b[j+1],z=b[j+2],r=b[j+3];let visible=true;
    for(let k=0;k<6;k++){const p=planes[k],n=p.normal;if(n.x*x+n.y*y+n.z*z+p.constant < -r){visible=false;break;}}
    if(visible){out.set(f.matrices.subarray(i*16,i*16+16),count*16);count++;}
   }
   target.count=count;target.instanceMatrix.needsUpdate=true;active+=count;triangles+=count*(target.geometry.index?.count??target.geometry.attributes.position.count)/3;
  }
  stats.instanceVisibility.passes[roles[index]]={active,triangles};
 };
 return {groups,families};
}
