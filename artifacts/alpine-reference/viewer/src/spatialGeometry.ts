import * as T from 'three/webgpu';

// Split index ownership into exact spatial groups. Vertex/normal/UV buffers remain shared,
// with every original triangle present once; this is neither decimation nor LOD.
export function partitionNativeCrowns(root:T.Object3D){
 const objects:T.Mesh[]=[];root.traverse(o=>{const m=o as T.Mesh;if(m.isMesh&&!Array.isArray(m.material)&&m.material.name.startsWith('fir_tree_01_')&&(m.geometry.index?.count??0)>900000)objects.push(m);});
 const cache=new Map<T.BufferGeometry,T.BufferGeometry[]>();let sourceTriangles=0,partitionTriangles=0;
 for(const o of objects){
  const source=o.geometry;let parts=cache.get(source);
  if(!parts){
   const p=source.getAttribute('position'),index=source.index!;
   const cells=new Map<string,{indices:number[],bounds:T.Box3}>();
   const a=new T.Vector3(),b=new T.Vector3(),c=new T.Vector3();
   for(let i=0;i<index.count;i+=3){
    const ia=index.getX(i),ib=index.getX(i+1),ic=index.getX(i+2);a.fromBufferAttribute(p,ia);b.fromBufferAttribute(p,ib);c.fromBufferAttribute(p,ic);
    const key=Math.floor((a.x+b.x+c.x)/9)+':'+Math.floor((a.y+b.y+c.y)/9)+':'+Math.floor((a.z+b.z+c.z)/9);
    let cell=cells.get(key);if(!cell){cell={indices:[],bounds:new T.Box3()};cells.set(key,cell);}cell.indices.push(ia,ib,ic);cell.bounds.expandByPoint(a).expandByPoint(b).expandByPoint(c);
   }
   parts=[];
   for(const cell of cells.values()){const geometry=new T.BufferGeometry();for(const [name,attribute]of Object.entries(source.attributes))geometry.setAttribute(name,attribute);geometry.setIndex(new T.BufferAttribute(new Uint32Array(cell.indices),1));geometry.boundingBox=cell.bounds;geometry.boundingSphere=cell.bounds.getBoundingSphere(new T.Sphere());parts.push(geometry);}
   if(parts.reduce((sum,g)=>sum+g.index!.count,0)!==index.count)throw Error('Native crown partition lost triangles');cache.set(source,parts);
  }
  sourceTriangles+=source.index!.count/3;partitionTriangles+=parts.reduce((sum,g)=>sum+g.index!.count/3,0);
  const group=new T.Group();group.name=o.name;group.matrix.copy(o.matrix);group.matrixAutoUpdate=false;
  for(const geometry of parts){const mesh=new T.Mesh(geometry,o.material);mesh.name=o.name+'_Crown_Region';mesh.userData.keepSharedGeometry=true;group.add(mesh);}
  o.parent!.add(group);o.removeFromParent();
 }
 root.updateMatrixWorld(true);return {objects:objects.length,uniquePartitions:[...cache.values()].reduce((sum,v)=>sum+v.length,0),sourceTriangles,partitionTriangles,exactCoverage:sourceTriangles===partitionTriangles};
}
