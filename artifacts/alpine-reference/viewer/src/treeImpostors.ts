import {loadPackedAsset} from './packedAssets';
import * as T from 'three/webgpu';
import {treeDetailPolicy as detail} from './treeDetailPolicy';
import {texture,uv,attribute,vec2,vec3,vec4,float,int,mix,max,normalize,cameraViewMatrix,cameraPosition,positionWorld,smoothstep,uniform,fwidth} from 'three/tsl';

export async function installTreeImpostors(scene:T.Scene,trees:{matrix:T.Matrix4,variant:number}[],stats:any){
 const manifest=await fetch(import.meta.env.BASE_URL+'assets/tree-impostors/manifest.json').then(r=>r.json());
 const [colorBytes,normalBytes]=await Promise.all(['albedo','normal'].map(name=>loadPackedAsset('tree-impostors/'+name+'.bin')));
 function array(data:ArrayBuffer,color:boolean){const t=new T.DataArrayTexture(new Uint8Array(data),1024,1024,manifest.layers.length);t.colorSpace=color?T.SRGBColorSpace:T.NoColorSpace;t.generateMipmaps=true;t.minFilter=T.LinearMipmapLinearFilter;t.magFilter=T.LinearFilter;t.anisotropy=8;t.needsUpdate=true;return t;}
 const color=array(colorBytes,true),normals=array(normalBytes,false),full=uniform(0);stats.setFullDetail=(enabled:boolean)=>{stats.fullDetailDiagnostic=enabled;full.value=enabled?1:0;};
 const distance=positionWorld.xz.sub(cameraPosition.xz).length();const far=smoothstep(detail.fullUntilMetres,detail.transitionEndMetres,distance);const fade=float(1).sub(far).mul(float(1).sub(full)).add(full);
 const seen=new Set<T.Material>();scene.traverse(o=>{const m=o as T.Mesh;if(!m.isMesh)return;for(const material of Array.isArray(m.material)?m.material:[m.material]){if(seen.has(material))continue;seen.add(material);if(material.name==='Real_Fir_Bark'||material.name==='Spruce_Needles_Shared'){
  const mat=material as T.MeshStandardNodeMaterial;
  // Resolve coverage with the existing four MSAA samples, without a screen-space
  // noise pattern crawling over branches as the camera moves. Bound the edge
  // width explicitly: smoothstep with equal edges produces NaNs in flat alpha.
  let coverage:any=float(1);
  if(mat.map){const texel=texture(mat.map);mat.colorNode=texel.rgb.mul(uniform(mat.color));coverage=smoothstep(.12,float(.12).add(max(fwidth(texel.a),.02)),texel.a);}
  const opacity=coverage.mul(fade);mat.opacityNode=opacity;mat.alphaTest=0;mat.alphaToCoverage=true;mat.maskNode=opacity.greaterThan(.001);mat.maskShadowNode=coverage.greaterThan(.5);
 }}});
 const layer=attribute('lodLayer','float'),angles=vec3(attribute('lodAngles','vec3') as any),basis=vec2(attribute('lodBasis','vec2') as any);
 function sample(map:T.DataArrayTexture,angle:any){const tile=vec2(angle.mod(4),angle.div(4).floor());const texUV=vec2(uv().x,uv().y.oneMinus()).clamp(.001,.999).add(tile).div(vec2(4,2));return texture(map,texUV).depth(int(layer as any));}
 const a=sample(color,angles.x),b=sample(color,angles.y),n0=sample(normals,angles.x),n1=sample(normals,angles.y),alpha=mix(a.a,b.a,angles.z);
 const albedo=mix(a.rgb.mul(a.a),b.rgb.mul(b.a),angles.z).div(max(alpha,.001));const n=normalize(mix(n0.rgb.mul(2).sub(1).mul(a.a),n1.rgb.mul(2).sub(1).mul(b.a),angles.z));
 const worldNormal=vec3(n.x.mul(basis.x).sub(n.y.mul(basis.y)),n.z,n.x.mul(basis.y).add(n.y.mul(basis.x)).negate());
 const coverage=smoothstep(.15,float(.15).add(max(fwidth(alpha),.02)),alpha);
 const material=new T.MeshSSSNodeMaterial({roughness:.85,side:T.DoubleSide,alphaTest:0,alphaToCoverage:true});material.name='Distant_Conifer_Atlas';material.colorNode=albedo;const opacity=coverage.mul(far).mul(float(1).sub(full));material.opacityNode=opacity;material.maskNode=opacity.greaterThan(.001);material.normalNode=normalize(cameraViewMatrix.mul(vec4(worldNormal,0)).xyz);material.thicknessColorNode=albedo.mul(.4);material.thicknessScaleNode=float(.3);material.thicknessAmbientNode=float(0);material.thicknessAttenuationNode=float(.65);material.thicknessPowerNode=float(2);material.thicknessDistortionNode=float(.1);
 const views=[0,1].map(index=>{const g=new T.PlaneGeometry(1,1);const layers=new Float32Array(trees.length),angles=new Float32Array(trees.length*3),basis=new Float32Array(trees.length*2);
  trees.forEach((t,i)=>{const e=t.matrix.elements,s=Math.hypot(e[0],e[1],e[2]);layers[i]=t.variant;basis[i*2]=e[0]/s;basis[i*2+1]=-e[2]/s;});
  g.setAttribute('lodLayer',new T.InstancedBufferAttribute(layers,1));g.setAttribute('lodAngles',new T.InstancedBufferAttribute(angles,3));g.setAttribute('lodBasis',new T.InstancedBufferAttribute(basis,2));const m=new T.InstancedMesh(g,material,trees.length);m.name='Distant_Conifers_'+index;m.castShadow=false;m.receiveShadow=true;m.frustumCulled=false;scene.add(m);return {mesh:m,angles,key:''};
 });
 const pos=new T.Vector3(),scale=new T.Vector3(),q=new T.Quaternion(),matrix=new T.Matrix4(),up=new T.Vector3(0,1,0);
 stats.updateTreeImpostors=(camera:T.Camera,index:number)=>{
  views.forEach((v,i)=>v.mesh.visible=index===i&&!stats.fullDetailDiagnostic);if(index===2)return;
  const v=views[index],cp=camera.getWorldPosition(new T.Vector3()),key=cp.toArray().join(',');if(v.key===key)return;v.key=key;
  trees.forEach((tree,i)=>{const e=tree.matrix.elements,p=manifest.layers[tree.variant],width=Math.max(Math.hypot(e[0],e[1],e[2]),Math.hypot(e[8],e[9],e[10])),height=Math.hypot(e[4],e[5],e[6]);const angle=Math.atan2(cp.x-e[12],cp.z-e[14]),yaw=Math.atan2(-e[2],e[0]);const local=((angle-yaw)%(Math.PI*2)+Math.PI*2)%(Math.PI*2)/(Math.PI/4),a=Math.floor(local);v.angles.set([a,(a+1)%8,local-a],i*3);pos.set(e[12]+e[4]*p.centerZ,e[13]+e[5]*p.centerZ,e[14]+e[6]*p.centerZ);q.setFromAxisAngle(up,angle);scale.set(p.width*width,p.height*height,1);matrix.compose(pos,q,scale);v.mesh.setMatrixAt(i,matrix);});
  v.mesh.instanceMatrix.needsUpdate=true;v.mesh.geometry.getAttribute('lodAngles').needsUpdate=true;
 };
 stats.treeImpostors={placements:trees.length,prototypeLayers:manifest.layers.length,viewsPerPrototype:8,transitionMetres:[detail.fullUntilMetres,detail.transitionEndMetres],submitUntilMetres:detail.submitUntilMetres,sourceModelsRetained:true,allSourceTreesPreloaded:true,transition:'bounded alpha coverage with four MSAA samples; no screen-space noise'};
}
