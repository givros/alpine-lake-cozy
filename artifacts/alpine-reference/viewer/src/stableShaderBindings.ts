import type {WebGPURenderer} from 'three/webgpu';

// r184 otherwise embeds a process-wide NodeUniform id in each instance-buffer
// identifier. Identical shader layouts then compile thousands of different strings.
// Naming declarations by their local binding order preserves every buffer and binding;
// only equivalent WGSL program text is shared. Dependencies remain untouched.
export function stableShaderBindings(renderer:WebGPURenderer){
 const backend=(renderer as any).backend;
 const create=backend.createNodeBuilder.bind(backend);
 backend.createNodeBuilder=(...args:any[])=>{
  const builder=create(...args),get=builder.getUniformFromNode.bind(builder);
  const names=new WeakMap<object,string>();let serial=0;
  builder.getUniformFromNode=(node:any,type:string,stage:any,name:string|null=null)=>{
   if(name===null&&(type==='buffer'||type==='storageBuffer'||type==='indirectStorageBuffer')){
    let local=names.get(node);if(local===undefined){local='SceneBuffer_'+serial++;names.set(node,local);}name=local;
   }
   return get(node,type,stage,name);
  };
  return builder;
 };
}
