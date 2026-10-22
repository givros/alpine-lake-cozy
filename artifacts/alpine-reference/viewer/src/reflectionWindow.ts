import * as T from 'three/webgpu';
// Preserve native capture pixels while excluding portions of the capture that water never samples.
export function reflectionWindow(renderer:T.WebGPURenderer,reflection:any,lake:T.Mesh,stats:any){
 const base=reflection.reflector,update=base.updateBefore.bind(base);const projection=new T.Matrix4(),crop=new T.Matrix4();const size=new T.Vector2();let key='',cached:number[]|null=null;
 const planes=[(v:T.Vector4)=>v.w+v.x,(v:T.Vector4)=>v.w-v.x,(v:T.Vector4)=>v.w+v.y,(v:T.Vector4)=>v.w-v.y,(v:T.Vector4)=>v.z,(v:T.Vector4)=>v.w-v.z];
 base.updateBefore=(frame:any)=>{
  if(stats.fullReflectionDiagnostic){stats.reflectionWindow=null;return update(frame);}
  const camera=frame.camera as T.Camera;renderer.getDrawingBufferSize(size);const W=size.x,H=size.y;
  projection.multiplyMatrices(camera.projectionMatrix,camera.matrixWorldInverse).multiply(lake.matrixWorld);const nextKey=projection.elements.join(',')+':'+W+':'+H;
  if(nextKey!==key){key=nextKey;const pos=lake.geometry.getAttribute('position');let polygon:T.Vector4[]=[];for(let i=1;i<pos.count;i++)polygon.push(new T.Vector4(pos.getX(i),pos.getY(i),pos.getZ(i),1).applyMatrix4(projection));
   for(const plane of planes){const result:T.Vector4[]=[];for(let i=0;i<polygon.length;i++){const a=polygon[i],b=polygon[(i+1)%polygon.length],da=plane(a),db=plane(b);if(da>=0)result.push(a);if((da>=0)!==(db>=0))result.push(a.clone().lerp(b,da/(da-db)));}polygon=result;if(!polygon.length)break;}
   if(!polygon.length)cached=null;else{const xs=polygon.map(p=>(1-p.x/p.w)*.5*W),ys=polygon.map(p=>(1-p.y/p.w)*.5*H);const x=Math.max(0,Math.floor(Math.min(...xs))-16),y=Math.max(0,Math.floor(Math.min(...ys))-16),right=Math.min(W,Math.ceil(Math.max(...xs))+16),bottom=Math.min(H,Math.ceil(Math.max(...ys))+16);cached=[x,y,right-x,bottom-y];}
  }
  if(!cached){stats.reflectionWindow=null;return false;}
  const [x,y,w,h]=cached;stats.reflectionWindow=[x,y,w,h];const render=renderer.render;
  renderer.render=function(scene:T.Object3D,c:T.Camera){
   if(c!==base.getVirtualCamera(camera))return render.call(renderer,scene,c);
   const target=renderer.getRenderTarget()!;const viewport=target.viewport.clone(),scissor=target.scissor.clone(),test=target.scissorTest;const oldProjection=c.projectionMatrix.clone();
   crop.set(W/w,0,0,(W-2*x-w)/w,0,H/h,0,(2*y+h-H)/h,0,0,1,0,0,0,0,1);c.projectionMatrix.premultiply(crop);c.projectionMatrixInverse.copy(c.projectionMatrix).invert();target.viewport.set(x,y,w,h);target.scissor.set(x,y,w,h);target.scissorTest=true;
   try{return render.call(renderer,scene,c);}finally{target.viewport.copy(viewport);target.scissor.copy(scissor);target.scissorTest=test;c.projectionMatrix.copy(oldProjection);c.projectionMatrixInverse.copy(oldProjection).invert();}
  };
  try{return update(frame);}finally{renderer.render=render;}
 };
}
