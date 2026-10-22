import * as T from 'three/webgpu';
import {MeshoptEncoder} from 'meshoptimizer';

// Cache ordering only: invert the temporary vertex remap so original position,
// normal, UV and color buffers stay byte-for-byte unchanged. No simplification,
// quantization, compression, vertex removal or triangle removal is performed.
export async function optimizeIndexOrder(root:T.Object3D){
 await MeshoptEncoder.ready;
 const processed=new WeakSet<T.BufferGeometry>();const cache=new Map<string,T.BufferAttribute>(),buffers=new WeakMap<ArrayBufferLike,number>();let serial=0,triangles=0;
 function fingerprint(a:ArrayLike<number>){let sum=0,xor=0;for(let i=0;i<a.length;i+=3){let x=a[i],y=a[i+1],z=a[i+2];if((y<x&&y<=z)||(y===x&&z<y)){[x,y,z]=[y,z,x];}else if((z<x&&z<y)||(z===x&&x<y)){[x,y,z]=[z,x,y];}const h=(Math.imul(x+1,73856093)^Math.imul(y+1,19349663)^Math.imul(z+1,83492791))>>>0;sum=(sum+h)>>>0;xor^=h;}return sum+':'+xor;}
 root.traverse(o=>{const mesh=o as T.Mesh;if(!mesh.isMesh||!mesh.geometry.index||processed.has(mesh.geometry))return;processed.add(mesh.geometry);const old=mesh.geometry.index,a=old.array;
  if(!buffers.has(a.buffer))buffers.set(a.buffer,++serial);const key=buffers.get(a.buffer)+':'+a.byteOffset+':'+a.byteLength;
  let optimized=cache.get(key);
  if(!optimized){
   if(old.count<3000){cache.set(key,old);return;}
   const indices=new Uint32Array(a),before=fingerprint(a),[remap]=MeshoptEncoder.reorderMesh(indices,true,false),inverse=new Uint32Array(remap.length);
   for(let i=0;i<remap.length;i++)if(remap[i]!==0xffffffff)inverse[remap[i]]=i;
   for(let i=0;i<indices.length;i++)indices[i]=inverse[indices[i]];
   if(fingerprint(indices)!==before)throw Error('Index cache optimization changed oriented triangle inventory');
   optimized=new T.BufferAttribute(a instanceof Uint16Array?new Uint16Array(indices):indices,1);cache.set(key,optimized);triangles+=indices.length/3;
  }
  mesh.geometry.setIndex(optimized);
 });
 return {uniqueIndexBuffers:cache.size,optimizedUniqueTriangles:triangles,allVertexAttributesUnchanged:true,orientedTriangleFingerprintsMatched:true};
}
