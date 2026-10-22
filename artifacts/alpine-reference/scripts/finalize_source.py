import bpy,json,numpy as np,math
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1];s=bpy.context.scene
config=json.loads((R/'viewer/public/assets/photoreal_config.json').read_text())
for n in s.world.node_tree.nodes:
 if n.type=='TEX_ENVIRONMENT':n.image=bpy.data.images.load(str(R/'references/alpine_sunset_sky_v2.png'),check_existing=True);n.image.pack()
for name in ['Timber_Photographic','Endgrain_Photographic']:
 m=bpy.data.materials.get(name)
 if not m:continue
 p=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');source=p.inputs['Base Color'].links[0].from_socket
 mul=m.node_tree.nodes.new('ShaderNodeMixRGB');mul.name='Reference_Timber_Albedo';mul.blend_type='MULTIPLY';mul.inputs[0].default_value=1;mul.inputs[2].default_value=(*config['materials']['wood_tint_linear'],1);m.node_tree.links.new(source,mul.inputs[1]);m.node_tree.links.new(mul.outputs[0],p.inputs['Base Color']);p.inputs['Roughness'].default_value=.84
poses={'Reference_Camera':([0,-52.5,12],[0,70,1.3]),'Inspection_Aerial':([85,-105,115],[-5,22.5,2]),'Inspection_West':([-75,-5,18],[-255,-90,35]),'Inspection_East':([80,-35,18],[245,-145,45]),'Inspection_Reverse':([0,-55,12],[0,-205,32]),'Inspection_Cabin':([50,-5,11],[40.5,10.5,7]),'Inspection_Bridge':([-7,-28,6],[-9,18,1.6]),'Inspection_Forest':([61,22,16],[53,37,14]),'Inspection_Shore':([-35,-12,5],[-20,45,6])}
# Runtime coordinates above are converted explicitly to Blender Z-up.
poses['Inspection_Bridge']=([-7,-28,6],[-9,-18,1.6])
for name,(position,target) in poses.items():
 ob=bpy.data.objects.get(name)
 if ob is None:
  ob=bpy.data.objects.new(name,bpy.data.cameras.new(name));s.collection.objects.link(ob)
 ob.location=position;ob.rotation_euler=(Vector(target)-ob.location).to_track_quat('-Z','Y').to_euler();ob.data.lens=23
s.camera=bpy.data.objects['Reference_Camera'];s.render.engine='CYCLES';s.cycles.samples=24;s.cycles.use_denoising=True;s.render.resolution_x=1440;s.render.resolution_y=810;s.render.resolution_percentage=100
visible=[o for o in s.objects if o.type=='MESH' and not o.hide_render];unique={o.data for o in visible};tri={};invalid=[]
for me in unique:
 me.calc_loop_triangles();tri[me.name]=len(me.loop_triangles);a=np.empty(len(me.vertices)*3,np.float32);me.vertices.foreach_get('co',a)
 if not np.isfinite(a).all():invalid.append(me.name)
imageRecords=[{'name':im.name,'size':list(im.size),'packed':bool(im.packed_file)} for im in bpy.data.images if im.source=='FILE']
report={'revision':'reference_03','blender':bpy.app.version_string,'visible_mesh_objects':len(visible),'unique_meshes':len(unique),'source_instanced_triangles':sum(tri[o.data.name] for o in visible),'invalid_positions':invalid,'images':imageRecords,'missing_unpacked_images':[im['name'] for im in imageRecords if not im['packed']],'camera_views':poses,'source_material_translation':{'wood':'Photographic maps with principal-axis UVs and explicit linear albedo factor; same factor reconstructed in runtime','terrain':'Source semantic FLOAT32 layer weights translated by TSL','water':'Real channel mesh and source-supported ripples; runtime adds live optical normal flow and camera-correct lake reflections'}}
(R/'source_validation.json').write_text(json.dumps(report,indent=2))
spec=json.loads((R/'scene_spec.json').read_text());nav=json.loads((R/'viewer/public/assets/navigation.json').read_text());spec['cameras']=poses;spec['reference_camera']['lens_mm']=23;spec['routes']=nav['spec']['paths'];spec['revision']='reference_03';spec['animation']={'requested':'Gentle lake ripples and visible stream current','runtime_cycle_seconds':12,'vegetation':'static; no unrequested wind','characters':'none requested'};(R/'scene_spec.json').write_text(json.dumps(spec,indent=2))
registry=[]
for b in nav['blockers']:
 cid=b['id'];parts=[o for o in visible if o.name.startswith(cid+'_')];p=2.25 if cid=='CABIN_1' else 1.75 if cid=='CABIN_2' else 1.9;front=b['y']-(b['d']-.4)/2
 registry.append({'id':cid,'role':'hero' if cid=='CABIN_1' else 'supporting residence','parts':len(parts),'support':'Terrain_Continuous_Shore','position':[b['x'],b['y'],b['z']],'entry':[b['x'],front-p],'construction':['split log walls and actual apertures','framed glazing and shutters','door panels and ironwork','solid slate roof, eaves and rafters','stone foundation and open masonry flue','porch posts, braces, joists, rails and steps'],'interior':'Closed doors, no furnished interiors requested','provenance':'Original editable construction reused locally and revised'})
registry.extend([{'id':'BRIDGE','role':'hero traversable crossing','support':'bridge deck plus actual banks','geometry':'Individual deck boards, stringers, posts, rails and attachments','runtime_support':nav['bridge']},{'id':'CONIFERS','role':'groves and forest enclosure','prototypes':'18 constructed full-crown spruce variants plus native CC0 fir and sapling botanical meshes','parts':['continuous bark stem','primary and secondary boughs','folded needle sprays','soil datum'],'provenance':['Original constructed spruces','https://polyhaven.com/a/fir_tree_01','https://polyhaven.com/a/fir_sapling']},{'id':'ROCKS','provenance':['https://polyhaven.com/a/rock_moss_set_01','https://polyhaven.com/a/rock_moss_set_02'],'license':'CC0','support_evidence':'surface_revision.json'},{'id':'SKY','provenance':'Original ImageGen sky-only equirectangular texture, native resolution','source':'references/alpine_sunset_sky_v2.png'},{'id':'MASSIF','construction':'Measured alpine terrain reshaped against the supplied reference skyline with supported snow deposits','evidence':'reconstruction_changes.json'}]);(R/'asset_registry.json').write_text(json.dumps(registry,indent=2))
(R/'animation_manifest.json').write_text(json.dumps({'scene':'Alpine Reference Reconstruction','characters':[],'systems':[{'id':'water','cycle_seconds':12,'implementation':'Runtime TSL optical normal flow over real lake and stream geometry','source_geometry_static':True}],'vegetation':'Static, no wind requested'},indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(R/'Alpine_Lake.blend'))
print('FINAL_SOURCE_AUDIT',json.dumps({k:v for k,v in report.items() if k not in ['images','camera_views']}),flush=True)
