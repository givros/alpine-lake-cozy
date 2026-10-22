import {loadPackedAsset} from './packedAssets';
import * as T from 'three/webgpu';

export async function assignAdaptiveLods(gltf:any){
 const [manifest,raw]=await Promise.all([fetch(import.meta.env.BASE_URL+'assets/adaptive-lod.json').then(r=>r.json()),loadPackedAsset('adaptive-lod.bin')]);
 const trees:{matrix:T.Matrix4,variant:number}[]=[];const assigned=new WeakSet<T.BufferGeometry>();
 gltf.scene.traverse((o:T.Object3D)=>{const mesh=o as T.Mesh;if(!mesh.isMesh)return;const association=gltf.parser.associations.get(mesh);if(association?.meshes===undefined)return;
  const source=gltf.parser.json.meshes[association.meshes],name=source.name??'';const match=name.match(/Spruce_(Wood|Foliage)_Prototype_(\d+)_Irregular_(\d+)/);
  if(match){mesh.geometry.userData.treeVariant=Number(match[2])*3+Number(match[3]);if(match[1]==='Wood')trees.push({matrix:mesh.matrixWorld.clone(),variant:mesh.geometry.userData.treeVariant});}
  if(assigned.has(mesh.geometry))return;assigned.add(mesh.geometry);const record=manifest.levels[association.meshes+':'+(association.primitives??0)];
  // One measured intermediate branch level avoids recording three extra draws
  // per tree family and camera. The full source remains the close-range level.
  if(record)mesh.geometry.userData.lodLevels=(match?[record.levels[2]]:record.levels).map((level:any)=>{const g=new T.BufferGeometry();for(const [key,a]of Object.entries(mesh.geometry.attributes))g.setAttribute(key,a);g.setIndex(new T.BufferAttribute(new Uint32Array(raw,level.offset,level.count),1));g.boundingBox=mesh.geometry.boundingBox;g.boundingSphere=mesh.geometry.boundingSphere;return {geometry:g,error:level.error,ratio:level.ratio};});
 });
 return {trees,lodFamilies:Object.keys(manifest.levels).length};
}
