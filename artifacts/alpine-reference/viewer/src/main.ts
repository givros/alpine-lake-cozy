import {loadPackedAsset} from './packedAssets';
import * as T from 'three/webgpu';
import {reflector,positionWorld,uniform,sin,cos,vec3,mix,float,normalView,positionView,normalize,dot,pow,clamp,max,min,texture,equirectUV,backgroundRotation,normalWorldGeometry,cameraViewMatrix,vec4} from 'three/tsl';
import {HDRLoader} from 'three/addons/loaders/HDRLoader.js';
import {GLTFLoader} from 'three/addons/loaders/GLTFLoader.js';
import {mergeGeometries} from 'three/addons/utils/BufferGeometryUtils.js';
import {OrbitControls} from 'three/addons/controls/OrbitControls.js';
import {Walker} from './navigation';
import {stableShaderBindings} from './stableShaderBindings';
import {installViewInstancing} from './viewInstancing';
import {optimizeIndexOrder} from './optimizeIndexOrder';
import {assignAdaptiveLods} from './adaptiveLods';
import {installTreeImpostors} from './treeImpostors';
import {reflectionWindow} from './reflectionWindow';
import {partitionNativeCrowns} from './spatialGeometry';
import {applyPhotorealMaterials} from './photorealMaterials';
const status=document.querySelector<HTMLDivElement>('#status')!;
const stats:any={ready:false,submitted:0,completed:0,frames:[],errors:[],backend:'uninitialized',inflight:0,maxInflight:3,rafIntervals:[],draws:0,triangles:0};(window as any).__lake=stats;
window.addEventListener('error',e=>stats.errors.push(e.message));
async function main(){
 document.querySelectorAll<HTMLButtonElement>('button').forEach(b=>b.disabled=true);
 if(!('gpu' in navigator)||!window.isSecureContext)throw Error('WebGPU is required. Open this local viewer in a WebGPU-capable desktop browser.');
 const renderer=new T.WebGPURenderer({antialias:true,alpha:false,trackTimestamp:new URLSearchParams(location.search).get('profile')==='1'});await renderer.init();stableShaderBindings(renderer);
 if(!(renderer.backend as any).isWebGPUBackend)throw Error('A native WebGPU backend could not be initialized.');
 stats.backend='WebGPU';stats.adapter=(renderer.backend as any).adapter?.info;renderer.setPixelRatio(devicePixelRatio);renderer.setSize(innerWidth,innerHeight);renderer.toneMapping=T.ACESFilmicToneMapping;renderer.toneMappingExposure=1.05;renderer.shadowMap.enabled=true;renderer.shadowMap.type=T.PCFShadowMap;document.body.prepend(renderer.domElement);
 const gpuDevice=(renderer.backend as any).device;gpuDevice.addEventListener('uncapturederror',(e:any)=>{if(stats.errors.length<100)stats.errors.push(e.error.message)});gpuDevice.lost.then((e:any)=>{stats.errors.push('Device lost: '+e.message);renderer.setAnimationLoop(null);status.hidden=false;status.textContent='The graphics device was lost. Reload this viewer to restore it.';});
 const config=await fetch(import.meta.env.BASE_URL+'assets/photoreal_config.json').then(r=>r.json());const scene=new T.Scene();scene.fog=new T.FogExp2(0xc0b4a1,.00085);
 const camera=new T.PerspectiveCamera(47.546,innerWidth/innerHeight,.15,2400);
 const reference=()=>{camera.position.set(0,12,52.5);camera.lookAt(0,1.3,-70);camera.updateProjectionMatrix();};reference();
 const orbit=new OrbitControls(camera,renderer.domElement);orbit.target.set(0,1.3,-70);orbit.enableDamping=true;orbit.maxDistance=400;orbit.minDistance=2;
 const skyTexture=config.sky.format==='hdr'?await new HDRLoader().loadAsync(import.meta.env.BASE_URL+'assets/'+config.sky.image):await new T.TextureLoader().loadAsync(import.meta.env.BASE_URL+'assets/'+config.sky.image);skyTexture.mapping=T.EquirectangularReflectionMapping;if(config.sky.format!=='hdr')skyTexture.colorSpace=T.SRGBColorSpace;renderer.toneMappingExposure=config.lighting?.exposure??1.05;scene.background=skyTexture;scene.environment=config.sky.environment_image?await new HDRLoader().loadAsync(import.meta.env.BASE_URL+'assets/'+config.sky.environment_image):skyTexture;scene.environment.mapping=T.EquirectangularReflectionMapping;scene.environmentIntensity=config.lighting?.environment??1.25;scene.backgroundIntensity=config.lighting?.background??1.1;
 const q=config.sky.world_rotation_quaternion_blender;const skyRotation=new T.Quaternion(q[1],q[3],-q[2],q[0]);scene.backgroundRotation.setFromQuaternion(skyRotation);scene.environmentRotation.copy(scene.backgroundRotation);
 const sd=config.lighting?.sun_direction_blender??config.sky.sun_direction_blender;const sunDirection=new T.Vector3(sd[0],sd[2],-sd[1]).normalize();
 const skyNode=texture(skyTexture,equirectUV(backgroundRotation.mul(normalize(normalWorldGeometry.add(vec3(0,.23,0))))));const skyRGB=skyNode.rgb;const maximum=max(max(skyRGB.r,skyRGB.g),skyRGB.b);const minimum=min(min(skyRGB.r,skyRGB.g),skyRGB.b);const neutrality=clamp(float(1).sub(maximum.sub(minimum).div(maximum.add(.01))).sub(.35).div(.65),0,1);const skyTint=uniform(new T.Vector3(...(config.sky.cloud_tint??[2,1.03,.30]) as [number,number,number]));const skyGrade=uniform(config.sky.cloud_grade??.85);const skySpread=uniform(config.sky.cloud_spread??.55);const skyDirection=uniform(new T.Vector3(config.sky.sun_direction_blender[0],config.sky.sun_direction_blender[2],-config.sky.sun_direction_blender[1]).normalize());const sunward=pow(clamp(dot(normalWorldGeometry,skyDirection).sub(skySpread).div(float(1).sub(skySpread)),0,1),1.5);const skyCosine=dot(normalWorldGeometry,skyDirection);const solarDisk=pow(clamp(skyCosine.sub(Math.cos(config.sky.angular_solar_radius_radians??.0063)).div(1-Math.cos(config.sky.angular_solar_radius_radians??.0063)),0,1),.3);const horizonGlow=pow(clamp(skyCosine,0,1),14).mul(pow(clamp(float(1).sub(normalWorldGeometry.y.mul(3).abs()),0,1),3));scene.backgroundNode=skyRGB.mul(mix(vec3(1),skyTint,sunward.mul(neutrality).mul(skyGrade))).add(vec3(.38,.11,.018).mul(horizonGlow)).add(vec3(28,13,3).mul(solarDisk).mul(config.sky.analytic_solar_disk===false?0:1));stats.skyControls={tint:skyTint,grade:skyGrade,spread:skySpread,direction:skyDirection};

 const hemi=new T.HemisphereLight(0xbacddd,0x51452e,config.lighting?.hemisphere??1.1);hemi.color.setHex(config.lighting?.hemisphere_color??0xbacddd);scene.add(hemi);
 const sun=new T.DirectionalLight();sun.color.fromArray(config.lighting?.sun_rgb??[1,.76,.51]);sun.intensity=config.lighting?.sun??3.4;sun.target.position.set(0,0,-40);sun.position.copy(sun.target.position).addScaledVector(sunDirection,350);sun.castShadow=true;sun.shadow.mapSize.set(4096,4096);Object.assign(sun.shadow.camera,{left:-350,right:350,top:420,bottom:-240,near:1,far:1400});sun.shadow.bias=-.00003;sun.shadow.normalBias=.045;scene.add(sun,sun.target);const bounce=new T.DirectionalLight(0xffd9a0,config.lighting?.bounce??0);bounce.color.fromArray(config.lighting?.bounce_rgb??[1,.76,.48]);bounce.position.fromArray(config.lighting?.bounce_position_runtime??[-110,100,60]);bounce.target.position.set(0,15,-45);scene.add(bounce,bounce.target);stats.scene=scene;stats.lighting={sun,hemi,bounce};
 const started=performance.now();const [gltf,nav]=await Promise.all([loadPackedAsset('alpine-lake.glb',(loaded,total)=>{status.textContent=`Loading the valley… ${Math.round(loaded/total*100)}%`;}).then(bytes=>new GLTFLoader().parseAsync(bytes,import.meta.env.BASE_URL+'assets/')),fetch(import.meta.env.BASE_URL+'assets/navigation.json').then(r=>r.json())]);
 const root=gltf.scene;root.updateMatrixWorld(true);const adaptive=await assignAdaptiveLods(gltf);let terrain:T.Mesh|undefined;let lake:T.Mesh|undefined;let surroundingTerrain:T.Mesh|undefined;
 stats.photorealMaterials=await applyPhotorealMaterials(root,config);stats.nativeCrownPartitions={objects:0,sourceTriangles:0,partitionTriangles:0,exactCoverage:true,mode:"adaptive whole-mesh levels; full source retained"};stats.indexOrdering=await optimizeIndexOrder(root);
 root.traverse(o=>{const m=o as T.Mesh;if(!m.isMesh)return;for(const mat of Array.isArray(m.material)?m.material:[m.material]){if(mat.name==='Needles'||mat.name==='NeedlesLight'){mat.alphaTest=.2;mat.transparent=false;mat.alphaToCoverage=false;mat.depthWrite=true;}}});
 // Repartition pre-exported global instancing into spatial cells without dropping instances.
 function sharedInstances(geometry:T.BufferGeometry,material:T.Material|T.Material[],count:number){const capacity=Math.max(16,T.MathUtils.ceilPowerOfTwo(count));const mesh=new T.InstancedMesh(geometry,material,capacity);mesh.count=count;return mesh;}
 const exportedInstances:T.InstancedMesh[]=[];root.traverse(o=>{if((o as T.InstancedMesh).isInstancedMesh)exportedInstances.push(o as T.InstancedMesh);});
 let exportedInstanceCount=0;
 for(const source of exportedInstances){const cells=new Map<string,T.Matrix4[]>();const matrix=new T.Matrix4();const world=new T.Matrix4();
  for(let i=0;i<source.count;i++){source.getMatrixAt(i,matrix);world.multiplyMatrices(source.matrixWorld,matrix);const k=Math.floor(world.elements[12]/32)+':'+Math.floor(world.elements[14]/32);const list=cells.get(k)||[];list.push(world.clone());cells.set(k,list);}
  for(const list of cells.values()){const im=sharedInstances(source.geometry,source.material,list.length);for(let i=0;i<list.length;i++)im.setMatrixAt(i,list[i]);im.castShadow=im.receiveShadow=true;im.computeBoundingSphere();im.name='Spatial_'+source.name;scene.add(im);exportedInstanceCount+=list.length;}
  source.removeFromParent();
 }
 stats.exportedSpatialCells=scene.children.filter(o=>(o as T.InstancedMesh).isInstancedMesh).length;
 // Retain every triangle and instance. Static architecture is merged only by exact material.
 const groups=new Map<string,{material:T.Material,geometries:T.BufferGeometry[]}>();const remove:T.Object3D[]=[];let originalMeshes=exportedInstances.length,instances=exportedInstanceCount;
 const attributeBuffers=new WeakMap<ArrayBufferLike,number>();let bufferSerial=0;
 function geometryKey(g:T.BufferGeometry){return Object.entries(g.attributes).sort(([a],[b])=>a.localeCompare(b)).map(([n,a])=>{const array=a.array;if(!attributeBuffers.has(array.buffer))attributeBuffers.set(array.buffer,++bufferSerial);return n+':'+attributeBuffers.get(array.buffer)+':'+array.byteOffset+':'+array.byteLength;}).join('|')+':'+(g.index?(()=>{const a=g.index!.array;if(!attributeBuffers.has(a.buffer))attributeBuffers.set(a.buffer,++bufferSerial);return `${attributeBuffers.get(a.buffer)}:${a.byteOffset}:${a.byteLength}`;})():'none');}
 const viewInstances:T.InstancedMesh[]=[];const repeats=new Map<string,T.Mesh[]>();root.traverse(o=>{const m=o as T.Mesh;if(m.isMesh&&!Array.isArray(m.material)&&!m.name.startsWith('Terrain')&&!m.name.startsWith('Lake_Surface')){const cell=m.name.startsWith('Foothill_')?128:m.name.startsWith('Botanical_')&&!m.name.startsWith('Botanical_Fir_')||m.name.startsWith('Meadow_')?32:48;const k=geometryKey(m.geometry)+':'+m.material.uuid;const list=repeats.get(k)||[];list.push(m);repeats.set(k,list);}});
 const handled=new Set<T.Object3D>();
 for(const list of repeats.values())if(list.length>1){const first=list[0];const im=sharedInstances(first.geometry,first.material,list.length);for(let i=0;i<list.length;i++){im.setMatrixAt(i,list[i].matrixWorld);handled.add(list[i]);remove.push(list[i]);}im.castShadow=im.receiveShadow=true;im.computeBoundingSphere();scene.add(im);viewInstances.push(im);instances+=list.length;}
 root.traverse(o=>{const m=o as T.Mesh;if(!m.isMesh)return;originalMeshes++;const material=m.material as T.MeshStandardMaterial;
  if(handled.has(m))return;
  if(m.name.startsWith('Terrain')){terrain=m;return;}if(m.name==='Valley_Continuation'){surroundingTerrain=m;m.castShadow=m.receiveShadow=true;return;}if(m.name.startsWith('Lake_Surface')){lake=m;return;}
  if(m.name.startsWith('Solar_Disc')){m.castShadow=false;m.receiveShadow=false;return;}
  m.castShadow=true;m.receiveShadow=true;
  if(material.name==='Needles'||material.name==='NeedlesLight'){material.alphaTest=.2;material.transparent=false;material.alphaToCoverage=false;material.depthWrite=true;}
  if((m as T.InstancedMesh).isInstancedMesh){instances+=(m as T.InstancedMesh).count;return;}
  if(Array.isArray(m.material))return;
  if(m.userData.keepSharedGeometry||(m.geometry.index?.count??0)>300000)return;
  const geom=m.geometry.clone().applyMatrix4(m.matrixWorld);if(!geom.index) return;
  const layout=Object.entries(geom.attributes).sort(([a],[b])=>a.localeCompare(b)).map(([name,a])=>`${name}:${a.itemSize}:${a.normalized}:${a.array.constructor.name}`).join('|');
  const cell=Math.floor(m.matrixWorld.elements[12]/48)+':'+Math.floor(m.matrixWorld.elements[14]/48);const key=material.uuid+':'+layout+':'+cell;let group=groups.get(key);if(!group){group={material,geometries:[]};groups.set(key,group);}group.geometries.push(geom);remove.push(m);
 });
 for(const o of remove)o.removeFromParent();let staticBatches=0;
 for(const {material,geometries}of groups.values()){
  let chunk:T.BufferGeometry[]=[];let bytes=0;
  const flush=()=>{if(!chunk.length)return;const merged=mergeGeometries(chunk);if(!merged)throw Error('Static material merge failed');const m=new T.Mesh(merged,material);m.castShadow=m.receiveShadow=true;scene.add(m);staticBatches++;for(const g of chunk)g.dispose();chunk=[];bytes=0;};
  for(const g of geometries){const size=Object.values(g.attributes).reduce((sum,a)=>sum+a.array.byteLength,0)+(g.index?.array.byteLength??0);if(bytes+size>128*1024*1024)flush();chunk.push(g);bytes+=size;}flush();
 }
 scene.add(root);const inventory:any[]=[];scene.traverse(o=>{const m=o as T.Mesh;if(m.isMesh)inventory.push({name:m.name,material:Array.isArray(m.material)?'multi':m.material.name,instances:(m as T.InstancedMesh).count??1,triangles:(m.geometry.index?.count??m.geometry.attributes.position.count)/3,maxAttributeBytes:Math.max(...Object.values(m.geometry.attributes).map(a=>a.array.byteLength))});});stats.geometryInventory=inventory;stats.retainedSceneTriangles=inventory.reduce((sum,a)=>sum+a.triangles*a.instances,0);stats.instanceUniformCapacity='power-of-two storage, exact active draw count';console.log('GEOMETRY_PROFILE',JSON.stringify(inventory.sort((a,b)=>b.triangles*b.instances-a.triangles*a.instances).slice(0,12)));if(!terrain||!lake)throw Error('Required terrain or water missing in source export.');terrain.receiveShadow=true;terrain.castShadow=true;
 if(terrain.geometry.getAttribute('color_1'))terrain.geometry.setAttribute('color',terrain.geometry.getAttribute('color_1'));
 if(terrain.geometry.getAttribute('color1'))terrain.geometry.setAttribute('color',terrain.geometry.getAttribute('color1'));
 // Semantic vertex colors are blend weights, already consumed by the authored node material.
 (terrain.material as T.MeshStandardMaterial).vertexColors=false;
 stats.terrainAttributes=Object.fromEntries(Object.entries(terrain.geometry.attributes).map(([k,v])=>[k,{count:v.count,values:Array.from(v.array.slice(0,12))}]));
 const lakeMaterial=new T.MeshBasicNodeMaterial();const reflection=reflector({resolutionScale:1,bounces:false,samples:4});reflection.target.rotation.x=-Math.PI/2;scene.add(reflection.target);
 const waterCycle=uniform(0);const wave=sin(positionWorld.x.mul(.9).add(waterCycle)).mul(cos(positionWorld.z.mul(1.2).sub(waterCycle.mul(2))));reflection.uvNode=reflection.uvNode!.add(vec3(wave.mul(.0004),wave.mul(.0003),0).xy);
 const fresnel=pow(float(1).sub(clamp(dot(normalView,normalize(positionView.negate())),0,1)),5).mul(.98).add(.02);
 lakeMaterial.colorNode=mix(vec3(.010,.035,.037),reflection,fresnel);lake.material=lakeMaterial;lake.castShadow=false;lake.receiveShadow=false;
 if(new URLSearchParams(location.search).get('reflectionWindow')!=='0')reflectionWindow(renderer,reflection,lake,stats);
 // Distinct flowing stream with optical ripples; it is real exported channel geometry.
 scene.traverse(o=>{const m=o as T.Mesh;if(!m.isMesh||Array.isArray(m.material))return;const mat=m.material as T.MeshStandardMaterial;if(mat.name==='Foam'){mat.color.setHex(0xa7c3c2);mat.transparent=true;mat.opacity=.45;mat.depthWrite=false;m.castShadow=false;}if(mat.name==='StreamWater'){
  const flow=new T.MeshStandardNodeMaterial({color:0x355e60,roughness:.11,metalness:.58});flow.normalNode=normalize(cameraViewMatrix.mul(vec4(normalize(normalWorldGeometry.add(vec3(sin(positionWorld.z.mul(2.8).add(waterCycle.mul(5))).mul(.10),float(0),cos(positionWorld.x.mul(3).add(waterCycle.mul(2))).mul(.07)))),0)).xyz);m.material=flow;
 }});
 lake.renderOrder=100000;
 await installTreeImpostors(scene,adaptive.trees,stats);
 installViewInstancing(scene,camera,viewInstances,stats,renderer);
 const walker=new Walker(camera,terrain,nav,surroundingTerrain);reference();orbit.update();let walking=false;
 function pause(){if(walking){const direction=new T.Vector3();camera.getWorldDirection(direction);orbit.target.copy(camera.position).addScaledVector(direction,10);}walking=false;walker.active=false;walker.keys.clear();orbit.enabled=true;document.body.classList.remove('walking');if(document.pointerLockElement)document.exitPointerLock();}
 document.querySelector('#walk')!.addEventListener('click',async()=>{try{await renderer.domElement.requestPointerLock();walking=true;walker.active=true;orbit.enabled=false;walker.sync();document.body.classList.add('walking');}catch{status.hidden=false;status.textContent='Mouse capture was unavailable. Click Explore on foot again.';}});
 document.addEventListener('pointerlockchange',()=>{if(!document.pointerLockElement)pause();});document.addEventListener('mousemove',e=>{if(walking)walker.look(e.movementX,e.movementY);});
 document.addEventListener('keydown',e=>{if(e.code==='Escape'){pause();e.preventDefault();}if(e.code==='KeyR'&&walking)walker.reset();walker.keys.add(e.code);});document.addEventListener('keyup',e=>walker.keys.delete(e.code));window.addEventListener('blur',pause);
 document.querySelector('#reference')!.addEventListener('click',()=>{pause();reference();orbit.target.set(0,1.3,-70);orbit.update();});document.querySelector('#aerial')!.addEventListener('click',()=>{pause();camera.position.set(85,115,105);orbit.target.set(-5,2,-22.5);orbit.update();});
 document.querySelector('#surroundings')!.addEventListener('click',()=>{pause();camera.position.set(25,18,45);orbit.target.set(10,27,180);orbit.update();});
 let fullscreenBusy=false;document.querySelector('#fullscreen')!.addEventListener('click',async()=>{if(fullscreenBusy)return;fullscreenBusy=true;try{if(document.fullscreenElement)await document.exitFullscreen();else{await document.documentElement.requestFullscreen();try{await (navigator as any).keyboard?.lock(['Escape']);}catch{}}}finally{fullscreenBusy=false;}});
 document.addEventListener('fullscreenchange',()=>{document.querySelector('#fullscreen')!.textContent=document.fullscreenElement?'Exit fullscreen':'Fullscreen';if(!document.fullscreenElement)(navigator as any).keyboard?.unlock();resizePending=true;});
 let resizePending=false;window.addEventListener('resize',()=>resizePending=true);
 let last=performance.now();stats.source={originalMeshes,instances,staticBatches};stats.loadingMs=performance.now()-started;status.textContent='Preparing light and reflections…';
 stats.walker=walker;stats.camera=camera;stats.renderer=renderer;stats.scene=scene;stats.pause=pause;stats.reference=reference;stats.nav=nav;
 stats.pose=(x:number,y:number,z:number,tx:number,ty:number,tz:number)=>{pause();camera.position.set(x,y,z);orbit.target.set(tx,ty,tz);camera.lookAt(tx,ty,tz);orbit.update();};
 // Static object transforms are evaluated once. GPU instance buffers, water uniforms and cameras remain dynamic.
 scene.traverse(o=>{o.updateMatrix();o.matrixAutoUpdate=false;});scene.updateMatrixWorld(true);
 await new Promise<void>(resolve=>requestAnimationFrame(()=>resolve()));const prepareStart=performance.now();await renderer.compileAsync(scene,camera);stats.shaderPrepareMs=performance.now()-prepareStart;stats.ready=true;last=performance.now();
 let shadowReady=false;
 renderer.setAnimationLoop(async()=>{
  if(stats.rendering||stats.inflight>=stats.maxInflight)return;stats.rendering=true;
  try{
   if(resizePending){await (renderer.backend as any).device.queue.onSubmittedWorkDone();renderer.setPixelRatio(devicePixelRatio);renderer.setSize(innerWidth,innerHeight);camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();resizePending=false;}
   const now=performance.now(),dt=Math.min((now-last)/1000,.06);stats.cpuFrameInterval=now-last;stats.rafIntervals.push(now-last);if(stats.rafIntervals.length>7200)stats.rafIntervals.shift();last=now;
   waterCycle.value=(stats.freezeTime??(now-started)/1000)*Math.PI/6;walker.step(dt);if(!walking)orbit.update();stats.submitted++;const cpuStart=performance.now();renderer.render(scene,camera);stats.cpuRenderMs=performance.now()-cpuStart;stats.inflight++;gpuDevice.queue.onSubmittedWorkDone().then(()=>{stats.inflight--;const completedAt=performance.now();if(stats.lastCompletedAt){stats.frames.push(completedAt-stats.lastCompletedAt);if(stats.frames.length>7200)stats.frames.shift();}stats.lastCompletedAt=completedAt;stats.completed++;if(stats.completed===1){status.hidden=true;document.querySelectorAll<HTMLButtonElement>('button').forEach(b=>b.disabled=false);stats.firstCompleteMs=completedAt-started;}});
   if(!shadowReady){sun.shadow.autoUpdate=false;shadowReady=true;stats.enableRenderBundles?.();}
   stats.draws=renderer.info.render.drawCalls;stats.triangles=renderer.info.render.triangles;stats.framebuffer=[renderer.domElement.width,renderer.domElement.height];stats.shadowAutoUpdate=sun.shadow.autoUpdate;
   const reflectedCamera=reflection.reflector.getVirtualCamera(camera);const reflectedTarget=reflection.reflector.getRenderTarget(reflectedCamera);const gpuReflection=(renderer.backend as any).get(reflectedTarget.texture).texture;stats.reflectionBuffer=gpuReflection?[gpuReflection.width,gpuReflection.height]:null;
  }catch(e){stats.errors.push(String(e));status.hidden=false;status.textContent=String(e);renderer.setAnimationLoop(null);}finally{stats.rendering=false;}
 });
}
main().catch(e=>{stats.errors.push(String(e));status.textContent=String(e);});







