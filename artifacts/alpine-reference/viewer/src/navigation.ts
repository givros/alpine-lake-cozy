import * as T from 'three/webgpu';
export class Walker {
 keys=new Set<string>();active=false;yaw=0;pitch=0;foot=new T.Vector3();height=1.72;radius=.32;velocity=0;
 grid=new Map<string,number[]>();positions:Float32Array;indices:ArrayLike<number>;
 obstacleGrid=new Map<string,{trees:any[],rocks:any[]}>();
 constructor(public camera:T.PerspectiveCamera,public terrain:T.Mesh,public nav:any,surroundings?:T.Mesh){
  const meshes=surroundings?[terrain,surroundings]:[terrain];const geometry=meshes.map(m=>{m.updateWorldMatrix(true,false);return m.geometry.clone().applyMatrix4(m.matrixWorld);});
  this.positions=new Float32Array(geometry.reduce((n,g)=>n+g.getAttribute('position').array.length,0));this.indices=new Uint32Array(geometry.reduce((n,g)=>n+g.index!.count,0));let vertex=0,index=0;
  for(const g of geometry){const p=g.getAttribute('position').array;this.positions.set(p,vertex*3);for(let i=0;i<g.index!.count;i++)(this.indices as Uint32Array)[index++]=g.index!.getX(i)+vertex;vertex+=p.length/3;}
  const bounds=nav.spec.player_bounds??nav.spec.bounds;
  for(let i=0;i<this.indices.length;i+=3){const ids=[this.indices[i],this.indices[i+1],this.indices[i+2]];const xs=ids.map(k=>this.positions[k*3]),zs=ids.map(k=>this.positions[k*3+2]);const xmin=Math.max(bounds[0]-1,Math.min(...xs)),xmax=Math.min(bounds[2]+1,Math.max(...xs)),zmin=Math.max(-bounds[3]-1,Math.min(...zs)),zmax=Math.min(-bounds[1]+1,Math.max(...zs));if(xmin>xmax||zmin>zmax)continue;for(let x=Math.floor(xmin/2);x<=Math.floor(xmax/2);x++)for(let z=Math.floor(zmin/2);z<=Math.floor(zmax/2);z++){const k=x+','+z;const list=this.grid.get(k)||[];list.push(i);this.grid.set(k,list);}}
  const add=(type:'trees'|'rocks',object:any,x:number,y:number,r:number)=>{for(let ix=Math.floor((x-r-this.radius)/8);ix<=Math.floor((x+r+this.radius)/8);ix++)for(let iy=Math.floor((y-r-this.radius)/8);iy<=Math.floor((y+r+this.radius)/8);iy++){const key=ix+','+iy,cell=this.obstacleGrid.get(key)??{trees:[],rocks:[]};cell[type].push(object);this.obstacleGrid.set(key,cell);}};
  for(const t of nav.trees)add('trees',t,t.position[0],t.position[1],.23*t.scale);for(const r of nav.rocks??[])add('rocks',r,r.x,r.y,r.r);
  this.reset();
 }
 support(x:number,z:number){
  const b=this.nav.bridge;const y=-z;
  if(x>b.x0&&x<b.x1&&y>b.y0&&y<b.y1)return b.z-.04+.09*Math.cos((x-(b.x0+b.x1)/2)*Math.PI/(b.x1-b.x0));
  let raised=-100;
  for(const cabin of this.nav.blockers){const p=cabin.id==='CABIN_1'?2.25:cabin.id==='CABIN_2'?1.75:1.9;const front=cabin.y-(cabin.d-.4)/2;if(Math.abs(x-cabin.x)<(cabin.w-.4)/2&&y<front&&y>front-p)return cabin.z+.06;}
  for(const cabin of this.nav.blockers){const p=cabin.id==='CABIN_1'?2.25:cabin.id==='CABIN_2'?1.75:1.9;const front=cabin.y-(cabin.d-.4)/2;for(let j=0;j<3;j++)if(Math.abs(x-cabin.x)<(cabin.stair_half_width??.825)&&Math.abs(y-(front-p-.3-j*.32))<.18)raised=Math.max(raised,cabin.z-.03-j*.17);}
  // Exact barycentric support from exported triangles, spatially indexed in 2m cells.
  const v=this.positions;for(const i of this.grid.get(Math.floor(x/2)+','+Math.floor(z/2))||[]){const a=this.indices[i]*3,b=this.indices[i+1]*3,c=this.indices[i+2]*3;const den=(v[b+2]-v[c+2])*(v[a]-v[c])+(v[c]-v[b])*(v[a+2]-v[c+2]);if(Math.abs(den)<1e-10)continue;const u=((v[b+2]-v[c+2])*(x-v[c])+(v[c]-v[b])*(z-v[c+2]))/den;const w=((v[c+2]-v[a+2])*(x-v[c])+(v[a]-v[c])*(z-v[c+2]))/den;const t=1-u-w;if(u>=-.00001&&w>=-.00001&&t>=-.00001)return Math.max(raised,u*v[a+1]+w*v[b+1]+t*v[c+1]);}return raised;
 }
 reset(){const [x,y]=this.nav.spec.player.spawn;this.foot.set(x,this.support(x,-y),-y);this.yaw=.05;this.pitch=0;this.velocity=0;this.keys.clear();this.sync();}
 blocked(x:number,z:number){
  const b=this.nav.bridge, y=-z;
  if(x<b.x0||x>b.x1||y<b.y0||y>b.y1){if([[x,z],[x-this.radius,z],[x+this.radius,z],[x,z-this.radius],[x,z+this.radius]].some(([a,b])=>this.support(a,b)<.15))return true;}
  const bounds=this.nav.spec.player_bounds??this.nav.spec.bounds;if(x<bounds[0]+2||x>bounds[2]-2||y<bounds[1]+2||y>bounds[3]-2)return true;
  for(const b of this.nav.blockers)if(Math.abs(x-b.x)<b.w/2+this.radius&&Math.abs(y-b.y)<b.d/2+this.radius)return true;
  for(const b of this.nav.blockers){const half=(b.w-.4)/2,front=b.y-(b.d-.4)/2,p=b.id==='CABIN_1'?2.25:b.id==='CABIN_2'?1.75:1.9,outer=front-p;
   if(Math.abs(y-outer)<.075+this.radius&&Math.abs(x-b.x)>(b.porch_opening_half_width??.9)-.075-this.radius&&Math.abs(x-b.x)<half+this.radius)return true;
   if(Math.abs(Math.abs(x-b.x)-(half-.18))<.075+this.radius&&y>outer-this.radius&&y<front+this.radius)return true;
  }
  const obstacles=this.obstacleGrid.get(Math.floor(x/8)+','+Math.floor(y/8));
  for(const t of obstacles?.trees??[])if(Math.hypot(x-t.position[0],y-t.position[1])<.23*t.scale+this.radius)return true;
  for(const r of obstacles?.rocks??[])if(Math.hypot(x-r.x,y-r.y)<r.r+this.radius)return true;
  for(const f of this.nav.fences||[]){const dx=f.b[0]-f.a[0],dy=f.b[1]-f.a[1],t=Math.max(0,Math.min(1,((x-f.a[0])*dx+(y-f.a[1])*dy)/(dx*dx+dy*dy)));if(Math.hypot(x-f.a[0]-t*dx,y-f.a[1]-t*dy)<this.radius+f.radius)return true;}
  for(const b of this.nav.solid_boxes||[])if(x>b.x0-this.radius&&x<b.x1+this.radius&&y>b.y0-this.radius&&y<b.y1+this.radius)return true;
  const half=(b.y1-b.y0)/2;if(x>b.x0&&x<b.x1&&Math.abs(y-(b.y0+b.y1)/2)>half-this.radius&&Math.abs(y-(b.y0+b.y1)/2)<half+.3)return true;
  return false;
 }
 sync(){this.camera.position.copy(this.foot).y+=this.height;this.camera.rotation.set(this.pitch,this.yaw,0,'YXZ');}
 look(dx:number,dy:number){this.yaw-=dx*.0017;this.pitch=T.MathUtils.clamp(this.pitch-dy*.0017,-1.35,1.35);this.sync();}
 step(dt:number){if(!this.active)return;let f=Number(this.keys.has('KeyW')||this.keys.has('KeyZ'))-Number(this.keys.has('KeyS'));let s=Number(this.keys.has('KeyD'))-Number(this.keys.has('KeyA')||this.keys.has('KeyQ'));const len=Math.hypot(f,s)||1;f/=len;s/=len;
  const speed=this.keys.has('ShiftLeft')?6.5:4.2,dx=(s*Math.cos(this.yaw)-f*Math.sin(this.yaw))*speed*dt,dz=(-f*Math.cos(this.yaw)-s*Math.sin(this.yaw))*speed*dt;
  const count=Math.max(1,Math.ceil(Math.hypot(dx,dz)/.12));
  for(let i=0;i<count;i++){
   for(const axis of ['x','z'] as const){const x=this.foot.x+(axis==='x'?dx/count:0),z=this.foot.z+(axis==='z'?dz/count:0);if(this.blocked(x,z))continue;const h=this.support(x,z);if(h-this.foot.y>.45||this.foot.y-h>1.1)continue;this.foot.set(x,Math.max(h,this.foot.y),z);}
  }const ground=this.support(this.foot.x,this.foot.z);if(this.foot.y>ground+.005){this.velocity-=9.81*dt;this.foot.y=Math.max(ground,this.foot.y+this.velocity*dt);}else{this.foot.y=ground;this.velocity=0;}this.sync();
 }
}

