import {gunzipSync} from 'node:zlib';
import {MeshoptSimplifier} from 'meshoptimizer';import fs from 'node:fs';
await MeshoptSimplifier.ready;const packed=JSON.parse(fs.readFileSync('public/assets/packed/manifest.json','utf8'))['alpine-lake.glb'];const raw=gunzipSync(Buffer.concat(packed.parts.map(p=>fs.readFileSync('public/assets/packed/'+p)))),jsonLength=raw.readUInt32LE(12),g=JSON.parse(raw.subarray(20,20+jsonLength)),binStart=28+jsonLength;
const components={SCALAR:1,VEC2:2,VEC3:3,VEC4:4},types={5121:Uint8Array,5123:Uint16Array,5125:Uint32Array,5126:Float32Array};
function data(id){const a=g.accessors[id],v=g.bufferViews[a.bufferView],C=types[a.componentType],n=components[a.type],offset=raw.byteOffset+binStart+(v.byteOffset||0)+(a.byteOffset||0),stride=v.byteStride||n*C.BYTES_PER_ELEMENT;if(stride===n*C.BYTES_PER_ELEMENT)return new C(raw.buffer,offset,a.count*n);const out=new C(a.count*n);for(let i=0;i<a.count;i++)out.set(new C(raw.buffer,offset+i*stride,n),i*n);return out;}
const manifest={sourceBytes:raw.length,levels:{},quality:{fullNearMetres:8,pixelError:.6}},chunks=[];let offset=0,done=0;
for(let mi=0;mi<g.meshes.length;mi++)for(let pi=0;pi<g.meshes[mi].primitives.length;pi++){
 const p=g.meshes[mi].primitives[pi],name=g.materials[p.material]?.name??'';
 const tree=/Spruce_(Wood|Foliage)_Prototype_/.test(g.meshes[mi].name??'');
 if((!tree&&!/Living_Meadow_Grass|^fir_|^flower_|^fern_|Petal$|^Leaf$/.test(name))||p.indices===undefined)continue;
 const original=new Uint32Array(data(p.indices));if(original.length<600)continue;const positions=data(p.attributes.POSITION),normals=p.attributes.NORMAL!==undefined?data(p.attributes.NORMAL):null,uv=p.attributes.TEXCOORD_0!==undefined?data(p.attributes.TEXCOORD_0):null;
 const stride=(normals?3:0)+(uv?2:0),attrs=new Float32Array(positions.length/3*stride),weights=[...(normals?[.15,.15,.15]:[]),...(uv?[.3,.3]:[])];
 for(let i=0;i<positions.length/3;i++){let j=i*stride;if(normals){attrs[j++]=normals[i*3];attrs[j++]=normals[i*3+1];attrs[j++]=normals[i*3+2];}if(uv){attrs[j++]=uv[i*2];attrs[j]=uv[i*2+1];}}
 const scale=MeshoptSimplifier.getScale(positions,3),levels=[];
 for(const [ratio,error]of [[.35,.0025],[.10,.01],[.035,.035]]){
  const [indices,actualError]=MeshoptSimplifier.simplifyWithAttributes(original,positions,3,attrs,stride,weights,null,Math.floor(original.length*ratio/3)*3,error,['Sparse','Permissive']);
  const bytes=Buffer.from(indices.buffer,indices.byteOffset,indices.byteLength);chunks.push(bytes);levels.push({offset,count:indices.length,error:actualError*scale,ratio:indices.length/original.length});offset+=bytes.length;
 }
 manifest.levels[mi+':'+pi]={material:name,sourceTriangles:original.length/3,levels};done++;if(done%10===0)console.log('LOD',done,mi,name,levels.map(l=>l.ratio.toFixed(2)).join(','));
}
fs.writeFileSync('public/assets/adaptive-lod.bin',Buffer.concat(chunks));fs.writeFileSync('public/assets/adaptive-lod.json',JSON.stringify(manifest));console.log('LOD_COMPLETE',done,offset);

