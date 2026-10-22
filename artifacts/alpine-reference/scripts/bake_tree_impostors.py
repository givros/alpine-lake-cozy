import bpy,math,json
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1];out=R/'viewer/public/assets/tree-impostors';out.mkdir(parents=True,exist_ok=True)
scene=bpy.data.scenes.new('Tree_LOD_Atlas');scene.render.engine='CYCLES';scene.cycles.samples=4;scene.cycles.use_denoising=False;scene.render.film_transparent=True;scene.render.resolution_x=256;scene.render.resolution_y=512;scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA';scene.view_settings.view_transform='Standard';scene.view_settings.look='None';scene.view_settings.exposure=0;scene.view_settings.gamma=1
world=bpy.data.worlds.new('Atlas_Black');world.use_nodes=True;world.node_tree.nodes.get('Background').inputs[1].default_value=0;scene.world=world
camData=bpy.data.cameras.new('Atlas_Camera');camData.type='ORTHO';camera=bpy.data.objects.new('Atlas_Camera',camData);scene.collection.objects.link(camera);scene.camera=camera
# Use the available device for this owned background process only.
try:
 prefs=bpy.context.preferences.addons['cycles'].preferences;prefs.compute_device_type='OPTIX';prefs.get_devices()
 for d in prefs.devices:d.use=d.type!='CPU'
 scene.cycles.device='GPU'
except Exception:pass
materials={}
def bake_material(original,normal):
 key=(original.name,normal)
 if key in materials:return materials[key]
 m=original.copy();m.name=original.name+('_Atlas_Normal' if normal else '_Atlas_Albedo');n=m.node_tree.nodes;links=m.node_tree.links
 for p in list(n):
  if p.type!='BSDF_PRINCIPLED':continue
  emission=n.new('ShaderNodeEmission');emission.inputs[1].default_value=1
  if normal:
   geo=n.new('ShaderNodeNewGeometry');scale=n.new('ShaderNodeVectorMath');scale.operation='SCALE';scale.inputs['Scale'].default_value=.5;links.new(geo.outputs['Normal'],scale.inputs[0]);add=n.new('ShaderNodeVectorMath');add.operation='ADD';add.inputs[1].default_value=(.5,.5,.5);links.new(scale.outputs[0],add.inputs[0]);links.new(add.outputs[0],emission.inputs[0])
  else:
   base=p.inputs['Base Color'];ao=n.new('ShaderNodeAmbientOcclusion');ao.inputs['Distance'].default_value=.6;ao.samples=8;mix=n.new('ShaderNodeMixRGB');mix.blend_type='MULTIPLY';mix.inputs[0].default_value=.35
   if base.links:links.new(base.links[0].from_socket,mix.inputs[1])
   else:mix.inputs[1].default_value=base.default_value
   links.new(ao.outputs['Color'],mix.inputs[2]);links.new(mix.outputs[0],emission.inputs[0])
  replacement=emission.outputs[0]
  alpha=p.inputs.get('Alpha')
  if alpha and (alpha.links or alpha.default_value<1):
   transparent=n.new('ShaderNodeBsdfTransparent');blend=n.new('ShaderNodeMixShader');links.new(transparent.outputs[0],blend.inputs[1]);links.new(replacement,blend.inputs[2])
   if alpha.links:links.new(alpha.links[0].from_socket,blend.inputs[0])
   else:blend.inputs[0].default_value=alpha.default_value
   replacement=blend.outputs[0]
  for link in list(p.outputs[0].links):links.new(replacement,link.to_socket)
  n.remove(p)
 materials[key]=m;return m
records=[]
for k in range(6):
 for variant in range(3):
  ident=k*3+variant;objects=[]
  for prefix in ['Spruce_Wood_Prototype_','Spruce_Foliage_Prototype_']:
   me=bpy.data.meshes[prefix+str(k)+'_Irregular_'+str(variant)];o=bpy.data.objects.new('Atlas_'+prefix+str(ident),me);scene.collection.objects.link(o);objects.append(o)
  points=[v.co for o in objects for v in o.data.vertices];lo=min(v.z for v in points);hi=max(v.z for v in points);radius=max(math.hypot(v.x,v.y) for v in points);ortho=max(hi-lo+.4,radius*4*1.06);center=(lo+hi)/2;camData.ortho_scale=ortho
  record={'id':ident,'prototype':k,'variant':variant,'width':ortho*.5,'height':ortho,'centerZ':center,'views':8};records.append(record)
  for mode in ['albedo','normal']:
   scene.view_settings.view_transform='Raw' if mode=='normal' else 'Standard'
   for o in objects:
    original=list(o.data.materials);o.data=o.data.copy();o.data.materials.clear()
    for m in original:o.data.materials.append(bake_material(m,mode=='normal'))
   for angle in range(8):
    theta=angle*math.tau/8;camera.location=(math.sin(theta)*40,-math.cos(theta)*40,center);camera.rotation_euler=(Vector((0,0,center))-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(out/f'{mode}_{ident:02d}_{angle}.png');bpy.ops.render.render(write_still=True,scene=scene.name)
   # Restore original source material identity for the next pass.
   for o,prefix in zip(objects,['Spruce_Wood_Prototype_','Spruce_Foliage_Prototype_']):o.data=bpy.data.meshes[prefix+str(k)+'_Irregular_'+str(variant)]
  for o in objects:bpy.data.objects.remove(o,do_unlink=True)
  print('TREE_ATLAS',ident,flush=True)
(out/'manifest.json').write_text(json.dumps({'tile':[256,512],'layout':[4,2],'layers':records},indent=2));print('TREE_ATLAS_COMPLETE',flush=True)
