import * as T from 'three/webgpu';
import {treeDetailPolicy as treeDetail} from './treeDetailPolicy';

const pyramidWGSL=`
@group(0) @binding(0) var depthSource: texture_depth_2d;
@group(0) @binding(1) var levelOut: texture_storage_2d<r32float,write>;
@compute @workgroup_size(8,8) fn base(@builtin(global_invocation_id) id:vec3u){
 let size=textureDimensions(levelOut);if(any(id.xy>=size)){return;}
 let sourceSize=textureDimensions(depthSource);var d=1.0;
 if(all(id.xy<sourceSize)){d=0.0;for(var y=-1;y<=1;y++){for(var x=-1;x<=1;x++){
  let p=vec2i(id.xy)+vec2i(x,y);if(any(p<vec2i(0))||any(p>=vec2i(sourceSize))){d=1.0;}else{d=max(d,textureLoad(depthSource,p,0));}
 }}}
 textureStore(levelOut,vec2i(id.xy),vec4f(d));
}`;
const reduceWGSL=`
@group(0) @binding(0) var levelIn:texture_2d<f32>;
@group(0) @binding(1) var levelOut:texture_storage_2d<r32float,write>;
@compute @workgroup_size(8,8) fn reduce(@builtin(global_invocation_id) id:vec3u){
 if(any(id.xy>=textureDimensions(levelOut))){return;}let size=vec2i(textureDimensions(levelIn));let p=vec2i(id.xy*2u);var d=0.0;
 for(var y=0;y<2;y++){for(var x=0;x<2;x++){d=max(d,textureLoad(levelIn,min(p+vec2i(x,y),size-1),0).r);}}
 textureStore(levelOut,vec2i(id.xy),vec4f(d));
}`;
const cullWGSL=`
struct Params{vp:mat4x4f,viewport:vec4f,info:vec4u,camera:vec4f,detail:vec4f};
struct Bounds{lo:vec4f,hi:vec4f};struct Family{base:u32,count:u32,first:u32,flags:u32};
struct Draw{indices:u32,count:atomic<u32>,first:u32,base:i32,instance:u32};
@group(0) @binding(0) var<uniform> params:Params;
@group(0) @binding(1) var<storage,read> source:array<mat4x4f>;
@group(0) @binding(2) var<storage,read> bounds:array<Bounds>;
@group(0) @binding(3) var<storage,read> families:array<Family>;
@group(0) @binding(4) var pyramid:texture_2d<f32>;
@group(0) @binding(5) var<storage,read_write> output:array<mat4x4f>;
@group(0) @binding(6) var<storage,read_write> draws:array<Draw>;
@group(0) @binding(7) var<storage,read> lods:array<vec4u>;
@group(0) @binding(8) var<storage,read_write> previousLevels:array<u32>;
@compute @workgroup_size(64) fn reset(@builtin(global_invocation_id) id:vec3u){
 if(id.x>=params.info.y){return;}let f=lods[id.x];draws[id.x].indices=f.y;atomicStore(&draws[id.x].count,0u);draws[id.x].first=0u;draws[id.x].base=0;draws[id.x].instance=f.x;
}
@compute @workgroup_size(64) fn cull(@builtin(global_invocation_id) id:vec3u){
 if(id.x>=params.info.x){return;}let box=bounds[id.x];let family=u32(box.lo.w);let f=families[family];if(params.detail.w<0.5&&(f.flags&1u)!=0u&&distance(source[id.x][3].xz,params.camera.xz)>${treeDetail.submitUntilMetres}.0){return;}var lo=vec3f(1e20);var hi=vec3f(-1e20);var near=false;
 for(var i=0u;i<8u;i++){let p=vec3f(select(box.lo.x,box.hi.x,(i&1u)!=0u),select(box.lo.y,box.hi.y,(i&2u)!=0u),select(box.lo.z,box.hi.z,(i&4u)!=0u));let clip=params.vp*vec4f(p,1.0);if(clip.w<=0.00001){near=true;}let ndc=clip.xyz/max(clip.w,0.00001);lo=min(lo,ndc);hi=max(hi,ndc);}
 if(!near&&(hi.x< -1.0||lo.x>1.0||hi.y< -1.0||lo.y>1.0||hi.z<0.0||lo.z>1.0)){return;}
 if(!near&&lo.z>=0.0&&params.info.w==1u){
  let a=max(vec2f(0),vec2f(lo.x*0.5+0.5,0.5-hi.y*0.5)*params.viewport.xy-vec2f(3));
  let b=min(params.viewport.xy-vec2f(1),vec2f(hi.x*0.5+0.5,0.5-lo.y*0.5)*params.viewport.xy+vec2f(3));
  let level=u32(clamp(ceil(log2(max(max(b.x-a.x,b.y-a.y)+1.0,1.0))),0.0,f32(params.info.z-1u)));
  let scale=exp2(f32(level));let p=vec2i(floor(a/scale));let q=vec2i(floor(b/scale));
  let d=max(max(textureLoad(pyramid,p,i32(level)).r,textureLoad(pyramid,vec2i(q.x,p.y),i32(level)).r),max(textureLoad(pyramid,vec2i(p.x,q.y),i32(level)).r,textureLoad(pyramid,q,i32(level)).r));
  if(lo.z>d+0.00002){return;}
 }
 var command=f.first;
 if(params.detail.w<0.5){let d=length(max(max(box.lo.xyz-params.camera.xyz,params.camera.xyz-box.hi.xyz),vec3f(0)));if(d>8.0){let scale=max(max(length(source[id.x][0].xyz),length(source[id.x][1].xyz)),length(source[id.x][2].xyz));let projected=scale*params.detail.x/d;
  for(var level=1u;level<(f.flags>>8u);level++){if(bitcast<f32>(lods[f.first+level].z)*projected<=params.detail.y/1.2){command=f.first+level;}}
  let old=min(previousLevels[id.x],(f.flags>>8u)-1u);let oldCommand=f.first+old;
  if(oldCommand>command&&bitcast<f32>(lods[oldCommand].z)*projected<=params.detail.y){command=oldCommand;}
  if(oldCommand<command&&d<9.6){command=oldCommand;}
 }}
 previousLevels[id.x]=command-f.first;
 let slot=lods[command].x+atomicAdd(&draws[command].count,1u);output[slot]=source[id.x];
}`;

// Each camera owns persistent indirect buffers. GPU frustum/LOD selection changes
// their contents without rebuilding recorded draws. Full source stays resident.
export function gpuOcclusion(renderer:T.WebGPURenderer,scene:T.Scene,families:any[],stats:any){
 stats.occlusionDisabled=true;
 const r=renderer as any,device:any=r.backend.device;
 if(!device.features.has('indirect-first-instance'))throw Error('GPU visibility requires indirect-first-instance support.');
 const total=families.reduce((n,f)=>n+f.count,0);let drawCount=0,slotCount=0;families.forEach(f=>{f.levelDefs=[{geometry:f.views[0].geometry,error:0},...f.lods];f.firstDraw=drawCount;drawCount+=f.levelDefs.length;slotCount+=f.count*f.levelDefs.length;});const capacity=T.MathUtils.ceilPowerOfTwo(slotCount);
 const matrices=new Float32Array(total*16),bounds=new Float32Array(total*8),familyData=new Uint32Array(families.length*4);
 const lodData=new Uint32Array(drawCount*4);let slotOffset=0;let offset=0;const box=new T.Box3(),matrix=new T.Matrix4();
 families.forEach((f,index)=>{
  f.base=offset;matrices.set(f.matrices,offset*16);if(!f.views[0].geometry.boundingBox)f.views[0].geometry.computeBoundingBox();
  for(let i=0;i<f.count;i++){matrix.fromArray(f.matrices,i*16);box.copy(f.views[0].geometry.boundingBox!).applyMatrix4(matrix);bounds.set([box.min.x-.002,box.min.y-.002,box.min.z-.002,index,box.max.x+.002,box.max.y+.002,box.max.z+.002,0],(offset+i)*8);}
  familyData.set([offset,f.count,f.firstDraw,(f.levelDefs.length<<8)|(f.treeVariant!==undefined?1:0)],index*4);
  f.levelDefs.forEach((l:any,j:number)=>{const errorBits=new Uint32Array(new Float32Array([l.error]).buffer)[0];lodData.set([slotOffset,l.geometry.index?.count??l.geometry.attributes.position.count,errorBits,0],(f.firstDraw+j)*4);slotOffset+=f.count;});offset+=f.count;
 });
 function buffer(data:ArrayBufferView,usage:number){const b=device.createBuffer({size:data.byteLength,usage:usage|GPUBufferUsage.COPY_DST});device.queue.writeBuffer(b,0,data.buffer,data.byteOffset,data.byteLength);return b;}
 const input=buffer(matrices,GPUBufferUsage.STORAGE),bbox=buffer(bounds,GPUBufferUsage.STORAGE),metadata=buffer(familyData,GPUBufferUsage.STORAGE),lodMetadata=buffer(lodData,GPUBufferUsage.STORAGE);
 const params=device.createBuffer({size:128,usage:GPUBufferUsage.UNIFORM|GPUBufferUsage.COPY_DST});
 const states=[0,1].map(index=>{
  const transforms=new T.StorageInstancedBufferAttribute(new Float32Array(capacity*16),16);
  const commands=new T.IndirectStorageBufferAttribute(new Uint32Array(drawCount*5),1);
  r._attributes.update(transforms,3);r._attributes.update(commands,4);
  families.forEach(f=>{const original=f.views[index];f.levelDefs.forEach((l:any,level:number)=>{
   const mesh=level===0?original:new T.InstancedMesh(l.geometry,original.material,1);
   mesh.name=original.name+'_LOD_'+level;mesh.castShadow=mesh.receiveShadow=true;mesh.boundingSphere=original.boundingSphere?.clone()??null;mesh.frustumCulled=false;
   mesh.instanceMatrix=transforms as any;const source=l.geometry,g=new T.BufferGeometry();for(const [name,a]of Object.entries(source.attributes))g.setAttribute(name,a as T.BufferAttribute);g.setIndex(source.index);g.boundingBox=source.boundingBox;g.boundingSphere=source.boundingSphere;g.setIndirect(commands,(f.firstDraw+level)*20);mesh.geometry=g;mesh.count=f.count;if(level)original.parent!.add(mesh);
  });});
  const previousLevels=buffer(new Uint32Array(total),GPUBufferUsage.STORAGE);
  return {transforms,commands,previousLevels,key:'',bind:null as any};
 });
 const layout=device.createBindGroupLayout({entries:[
  {binding:0,visibility:GPUShaderStage.COMPUTE,buffer:{type:'uniform'}},
  ...[1,2,3].map(binding=>({binding,visibility:GPUShaderStage.COMPUTE,buffer:{type:'read-only-storage'}})),
  {binding:4,visibility:GPUShaderStage.COMPUTE,texture:{sampleType:'unfilterable-float'}},
  ...[5,6].map(binding=>({binding,visibility:GPUShaderStage.COMPUTE,buffer:{type:'storage'}})),{binding:7,visibility:GPUShaderStage.COMPUTE,buffer:{type:'read-only-storage'}},{binding:8,visibility:GPUShaderStage.COMPUTE,buffer:{type:'storage'}}
 ]});
 const module=device.createShaderModule({code:cullWGSL}),pipelineLayout=device.createPipelineLayout({bindGroupLayouts:[layout]});
 const reset=device.createComputePipeline({layout:pipelineLayout,compute:{module,entryPoint:'reset'}}),cull=device.createComputePipeline({layout:pipelineLayout,compute:{module,entryPoint:'cull'}});
 const basePipeline=device.createComputePipeline({layout:'auto',compute:{module:device.createShaderModule({code:pyramidWGSL}),entryPoint:'base'}});
 const reducePipeline=device.createComputePipeline({layout:'auto',compute:{module:device.createShaderModule({code:reduceWGSL}),entryPoint:'reduce'}});
 const depthMaterial=new T.MeshBasicNodeMaterial({colorWrite:false,side:T.FrontSide});
 const occluders=new Set<T.Mesh>();scene.traverse(o=>{const m=o as T.Mesh;if(m.isMesh&&(m.name.startsWith('Terrain_Continuous_Shore')||m.name==='Alpine_Massif_Measured'))occluders.add(m);});
 let target:T.RenderTarget,pyramid:any,W=0,H=0,PW=0,PH=0,levels=0,baseBind:any,reduceBinds:any[]=[];
 const size=new T.Vector2(),vp=new T.Matrix4();let prepass=false;
 function resize(){renderer.getDrawingBufferSize(size);if(size.x===W&&size.y===H)return;W=size.x;H=size.y;PW=T.MathUtils.ceilPowerOfTwo(W);PH=T.MathUtils.ceilPowerOfTwo(H);levels=Math.floor(Math.log2(Math.max(PW,PH)))+1;
  target?.dispose();pyramid?.destroy();target=new T.RenderTarget(W,H,{depthBuffer:true,samples:0});target.depthTexture=new T.DepthTexture(W,H,T.FloatType);
  pyramid=device.createTexture({label:'Conservative terrain depth pyramid',size:[PW,PH],mipLevelCount:levels,format:'r32float',usage:GPUTextureUsage.TEXTURE_BINDING|GPUTextureUsage.STORAGE_BINDING});
  for(const state of states){state.key='';state.bind=device.createBindGroup({layout,entries:[{binding:0,resource:{buffer:params}},{binding:1,resource:{buffer:input}},{binding:2,resource:{buffer:bbox}},{binding:3,resource:{buffer:metadata}},{binding:4,resource:pyramid.createView()},{binding:5,resource:{buffer:r.backend.get(state.transforms).buffer}},{binding:6,resource:{buffer:r.backend.get(state.commands).buffer}},{binding:7,resource:{buffer:lodMetadata}},{binding:8,resource:{buffer:state.previousLevels}}]});}
  baseBind=null;reduceBinds=[];for(let i=1;i<levels;i++)reduceBinds.push(device.createBindGroup({layout:reducePipeline.getBindGroupLayout(0),entries:[{binding:0,resource:pyramid.createView({baseMipLevel:i-1,mipLevelCount:1})},{binding:1,resource:pyramid.createView({baseMipLevel:i,mipLevelCount:1})}]}));
 }
 function update(camera:T.Camera,index:number){
  if(prepass||index===2)return;resize();vp.multiplyMatrices(camera.projectionMatrix,camera.matrixWorldInverse);const key=vp.elements.join(',')+':'+!!stats.occlusionDisabled+':'+!!stats.fullDetailDiagnostic;if(states[index].key===key)return;states[index].key=key;
  const previous=renderer.getRenderTarget(),override=scene.overrideMaterial,background=scene.background,bgNode=scene.backgroundNode;
  if(!stats.occlusionDisabled){
  const hidden:T.Object3D[]=[];scene.traverse(o=>{if((o as T.Mesh).isMesh&&!occluders.has(o as T.Mesh)&&o.visible){hidden.push(o);o.visible=false;}});
  prepass=true;try{scene.overrideMaterial=depthMaterial;scene.background=null;scene.backgroundNode=null;renderer.setRenderTarget(target);renderer.render(scene,camera);}finally{renderer.setRenderTarget(previous);scene.overrideMaterial=override;scene.background=background;scene.backgroundNode=bgNode;for(const o of hidden)o.visible=true;prepass=false;}
  if(!baseBind)baseBind=device.createBindGroup({layout:basePipeline.getBindGroupLayout(0),entries:[{binding:0,resource:r.backend.get(target.depthTexture).texture.createView()},{binding:1,resource:pyramid.createView({baseMipLevel:0,mipLevelCount:1})}]});
  }
  const data=new ArrayBuffer(128);new Float32Array(data,0,16).set(vp.elements);new Float32Array(data,64,4).set([W,H,PW,PH]);new Uint32Array(data,80,4).set([total,drawCount,levels,stats.occlusionDisabled?0:1]);const cp=camera.getWorldPosition(new T.Vector3());new Float32Array(data,96,4).set([cp.x,cp.y,cp.z,0]);new Float32Array(data,112,4).set([(previous?.viewport.w??H)*Math.abs(camera.projectionMatrix.elements[5])*.5,.6,0,stats.fullDetailDiagnostic?1:0]);device.queue.writeBuffer(params,0,data);
  const encoder=device.createCommandEncoder({label:'Full-detail visibility'}),pass=encoder.beginComputePass();
  if(!stats.occlusionDisabled){pass.setPipeline(basePipeline);pass.setBindGroup(0,baseBind);pass.dispatchWorkgroups(Math.ceil(PW/8),Math.ceil(PH/8));
  pass.setPipeline(reducePipeline);for(let i=1;i<levels;i++){pass.setBindGroup(0,reduceBinds[i-1]);pass.dispatchWorkgroups(Math.ceil(Math.max(1,PW>>i)/8),Math.ceil(Math.max(1,PH>>i)/8));}
  }
  pass.setBindGroup(0,states[index].bind);pass.setPipeline(reset);pass.dispatchWorkgroups(Math.ceil(drawCount/64));pass.setPipeline(cull);pass.dispatchWorkgroups(Math.ceil(total/64));pass.end();device.queue.submit([encoder.finish()]);
 }
 stats.gpuVisibility={total,families:families.length,drawCount,occluders:occluders.size,states,adaptive:{pixelError:.6,coarsenPixelError:.5,fullNearMetres:8,coarsenBeyondMetres:9.6,hysteresis:true,treeImpostorMetres:[treeDetail.fullUntilMetres,treeDetail.transitionEndMetres]}};
 return {update,isPrepass:()=>prepass};
}

