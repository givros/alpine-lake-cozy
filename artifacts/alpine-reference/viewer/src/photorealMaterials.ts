import * as T from 'three/webgpu';
import {texture,uv,vertexColor,mix,vec2,vec3,float,normalMap,dot,max,vec4,uniform,triplanarTexture,positionWorld,normalWorldGeometry,bumpMap,normalize} from 'three/tsl';

// Reconstruct the authored Blender semantic material layers at their original texture resolution.
export async function applyPhotorealMaterials(root:T.Object3D,config?:any){
 const loader=new T.TextureLoader();
 async function photo(asset:string,kind:string){
  const t=await loader.loadAsync(`${import.meta.env.BASE_URL}assets/photoreal/${asset}_${kind}.${kind==='NormalRough'?'png':'jpg'}`);
  t.wrapS=t.wrapT=T.RepeatWrapping;t.flipY=false;t.colorSpace=kind==='Diffuse'?T.SRGBColorSpace:T.NoColorSpace;t.anisotropy=16;return t;
 }
 const assets=['leafy_grass','rocky_trail','forest_ground_04','rock_face_03','snow_02','aerial_grass_rock'];
 const maps=await Promise.all(assets.map(async a=>({color:await photo(a,'Diffuse'),packed:await photo(a,'NormalRough')})));
 const c=vertexColor();const ground=new T.MeshStandardNodeMaterial();ground.name='Ground';
 const sample=(i:number,k:'color'|'normal'|'rough')=>k==='color'?texture(maps[i].color,uv()):k==='normal'?texture(maps[i].packed,uv()):vec4(texture(maps[i].packed,uv()).a);
 ground.colorNode=mix(mix(mix(mix(sample(0,'color').rgb.mul(vec3(.42,1,.28)),sample(5,'color').rgb.mul(vec3(.85,1,.70)),.7),sample(2,'color').rgb,c.g),sample(3,'color').rgb,c.b),sample(1,'color').rgb,c.r);
 ground.roughnessNode=mix(mix(mix(mix(sample(0,'rough').r,sample(5,'rough').r,.7),sample(2,'rough').r,c.g),sample(3,'rough').r,c.b),sample(1,'rough').r,c.r);
 ground.normalNode=normalMap(mix(mix(mix(mix(sample(0,'normal').rgb,sample(5,'normal').rgb,.7),sample(2,'normal').rgb,c.g),sample(3,'normal').rgb,c.b),sample(1,'normal').rgb,c.r),vec2(.65));
 const mountain=new T.MeshStandardNodeMaterial();mountain.name='Alpine_Geology';
 const geologyPosition=vec3(positionWorld.x,positionWorld.z.negate(),positionWorld.y);const geologyNormal=vec3(normalWorldGeometry.x,normalWorldGeometry.z.negate(),normalWorldGeometry.y);const tri=(t:T.Texture)=>triplanarTexture(texture(t),null,null,float(.035),geologyPosition,geologyNormal);const rockHeight=await photo('rock_face_03','Displacement');
 const tintValues=config?.mountain?.rock_tint_linear??[.90,.86,.78];const saturationValue=config?.mountain?.rock_saturation??.5;const rockTint=uniform(new T.Vector3(...tintValues as [number,number,number]));const rockSaturation=uniform(saturationValue);(window as any).__lake.geologyControls={tint:rockTint,saturation:rockSaturation};const rawRock=tri(maps[3].color).rgb;const rock=mix(vec3(dot(rawRock,vec3(.2126,.7152,.0722))),rawRock,rockSaturation).mul(rockTint);const snow=sample(4,'color').rgb;
 mountain.colorNode=mix(mix(rock,snow,c.r),sample(5,'color').rgb.mul(vec3(.6,.75,.45)),c.g);
 mountain.roughnessNode=mix(tri(maps[3].packed).a,sample(4,'rough').r,c.r);
 mountain.normalNode=normalize(mix(vec3(bumpMap(tri(rockHeight).r,float(.117)) as any),vec3(normalMap(sample(4,'normal').rgb,vec2(1.1)) as any),c.r));
 const coverage=await Promise.all(['grass_medium_01','grass_medium_02','grass_bermuda_01'].map(async a=>{const t=await loader.loadAsync(`${import.meta.env.BASE_URL}assets/photoreal/${a}_coverage.png`);t.flipY=false;t.colorSpace=T.NoColorSpace;t.anisotropy=16;return t;}));
 const nativeGrassMaps=await Promise.all(['grass_medium_01','grass_medium_02','grass_bermuda_01'].map(async a=>{
  const maps=await Promise.all(['diff','nor_gl','arm'].map(async role=>{const t=await loader.loadAsync(`${import.meta.env.BASE_URL}assets/photoreal/${a}_${role}_2k.jpg`);t.flipY=false;t.colorSpace=role==='diff'?T.SRGBColorSpace:T.NoColorSpace;t.anisotropy=16;return t;}));return {albedo:maps[0],normal:maps[1],arm:maps[2]};
 }));
 const cutoutNames=['grass_medium_01','grass_medium_02','grass_bermuda_01','flower_heliophila','flower_empodium','flower_stinkkruid','fern_02'];
 const cutouts=await Promise.all(cutoutNames.map(async name=>{const t=await loader.loadAsync(`${import.meta.env.BASE_URL}assets/photoreal/${name}_cutout.png`);t.flipY=false;t.colorSpace=T.NoColorSpace;t.anisotropy=16;return t;}));
 const botanicalMaterials=new Map<string,T.Material>();
 await Promise.all(cutoutNames.slice(3).map(async name=>{const textures=await Promise.all(['diff','nor_gl','arm'].map(async role=>{const t=await loader.loadAsync(`${import.meta.env.BASE_URL}assets/photoreal/${name}_${role}_2k.jpg`);t.flipY=false;t.colorSpace=role==='diff'?T.SRGBColorSpace:T.NoColorSpace;t.anisotropy=16;return t;}));const mat=new T.MeshStandardNodeMaterial({map:textures[0],normalMap:textures[1],roughnessMap:textures[2],aoMap:textures[2],alphaMap:cutouts[cutoutNames.indexOf(name)],alphaTest:.15,alphaToCoverage:true,side:T.DoubleSide,roughness:1});mat.name=name;botanicalMaterials.set(name,mat);}));
 const livingGrass=new T.MeshSSSNodeMaterial({roughness:.86,metalness:0,side:T.DoubleSide});livingGrass.name='Living_Meadow_Grass';livingGrass.colorNode=vertexColor().rgb;livingGrass.thicknessColorNode=vertexColor().rgb.mul(1.4);livingGrass.thicknessDistortionNode=float(.1);livingGrass.thicknessAmbientNode=float(0);livingGrass.thicknessAttenuationNode=float(.45);livingGrass.thicknessPowerNode=float(2);livingGrass.thicknessScaleNode=float(.7);
 const nativeGrass=new Map<string,T.Material>();let sharedFoliage:T.Material|undefined;
 root.traverse(o=>{const m=o as T.Mesh;if(!m.isMesh)return;
  if(m.geometry.getAttribute('color_1'))m.geometry.setAttribute('color',m.geometry.getAttribute('color_1'));
  if(m.geometry.getAttribute('color1'))m.geometry.setAttribute('color',m.geometry.getAttribute('color1'));
  function replace(mat:T.Material):T.Material{
   if(mat.name==='Living_Meadow_Grass')return livingGrass;
   if(mat.name==='Timber_Photographic'||mat.name==='Endgrain_Photographic'){const timber=mat as T.MeshStandardMaterial;timber.color.fromArray(config?.materials?.wood_tint_linear??[.62,.68,.65]);timber.roughness=.84;return timber;}
   if(mat.name==='RoofSlate_Photographic'){const roof=mat as T.MeshStandardMaterial;if(!roof.userData.referenceDarkened){roof.color.fromArray(config?.materials?.roof_slate_tint_linear??[.1056,.112,.125]);roof.userData.referenceDarkened=true;}return roof;}
   if(mat.name==='Ground')return ground;if(mat.name==='Alpine_Geology')return mountain;
   if(botanicalMaterials.has(mat.name))return botanicalMaterials.get(mat.name)!;
   const grassIndex=['grass_medium_01','grass_medium_02','grass_bermuda_01'].indexOf(mat.name);
   if(grassIndex>=0){
    const cached=nativeGrass.get(mat.name);if(cached)return cached;const source=mat as T.MeshStandardMaterial;
    const maps=nativeGrassMaps[grassIndex];
    const grass=new T.MeshSSSNodeMaterial({map:maps.albedo,normalMap:maps.normal,normalScale:new T.Vector2(1,1),roughnessMap:maps.arm,aoMap:maps.arm,aoMapIntensity:1,metalness:0,roughness:1,side:T.DoubleSide});
    grass.name=mat.name;grass.opacityNode=texture(cutouts[grassIndex]).r;grass.alphaTest=.15;grass.alphaToCoverage=true;const albedo=texture(maps.albedo).rgb.div(max(texture(coverage[grassIndex]).r,.02));grass.colorNode=albedo.mul(.8);grass.thicknessColorNode=albedo.mul(.6);grass.thicknessDistortionNode=float(.2);grass.thicknessAmbientNode=float(0);grass.thicknessAttenuationNode=float(.8);grass.thicknessPowerNode=float(2);grass.thicknessScaleNode=float(1);nativeGrass.set(mat.name,grass);return grass;
   }
   if(mat.name==='fir_tree_01_twig'){const native=mat as T.MeshStandardMaterial;native.transparent=false;native.opacity=1;native.alphaTest=0;native.roughness=.9;return native;}
   if(mat.name.startsWith('Spruce_Needles_')){
    if(sharedFoliage)return sharedFoliage;
    const source=mat as T.MeshStandardMaterial;
    const leaf=new T.MeshSSSNodeMaterial({map:source.map,side:T.DoubleSide,alphaTest:.12,roughness:.83,metalness:0});
    leaf.name='Spruce_Needles_Shared';leaf.transparent=false;leaf.depthWrite=true;leaf.alphaToCoverage=true;leaf.thicknessColorNode=vec3(.18,.23,.065);leaf.thicknessDistortionNode=float(.12);leaf.thicknessAmbientNode=float(0);leaf.thicknessAttenuationNode=float(.45);leaf.thicknessPowerNode=float(3);leaf.thicknessScaleNode=float(.8);sharedFoliage=leaf;return leaf;
   }
   return mat;
  }
  m.material=Array.isArray(m.material)?m.material.map(replace):replace(m.material);
 });
 return {terrainLayers:5,mountainLayers:2,textureResolution:'native supplied 2K',foliage:'light-dependent thin-needle scattering; no emissive fill'};
}


