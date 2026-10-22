import bpy,numpy as np,json,math,hashlib
from pathlib import Path
R=Path(__file__).resolve().parents[1];s=bpy.context.scene;cfg=json.loads((R/'viewer/public/assets/photoreal_config.json').read_text())
# Visible solar angle belongs to the camera-background branch only; direct
# transport remains owned by the real shadow-casting sun.
n=s.world.node_tree.nodes;lk=s.world.node_tree.links;tc=next(x for x in n if x.type=='TEX_COORD');bg=next(x for x in n if x.type=='BACKGROUND' and abs(x.inputs[1].default_value-.8)<.001);env=next(x for x in n if x.type=='TEX_ENVIRONMENT')
dot=n.new('ShaderNodeVectorMath');dot.operation='DOT_PRODUCT';dot.inputs[1].default_value=cfg['sky']['sun_direction_blender'];lk.new(tc.outputs['Generated'],dot.inputs[0]);sub=n.new('ShaderNodeMath');sub.operation='SUBTRACT';sub.inputs[1].default_value=math.cos(.0063);lk.new(dot.outputs['Value'],sub.inputs[0]);divide=n.new('ShaderNodeMath');divide.operation='DIVIDE';divide.inputs[1].default_value=1-math.cos(.0063);divide.use_clamp=True;lk.new(sub.outputs[0],divide.inputs[0]);add=n.new('ShaderNodeMixRGB');add.blend_type='ADD';add.inputs[2].default_value=(25,12,3,1);lk.new(divide.outputs[0],add.inputs[0]);lk.new(env.outputs[0],add.inputs[1]);lk.new(add.outputs[0],bg.inputs[0])
visible=[o for o in s.objects if o.type=='MESH' and not o.hide_render];meshes={o.data for o in visible};counts={};badPositions=[];badNormals=[]
for me in meshes:
 me.calc_loop_triangles();counts[me.name]=len(me.loop_triangles)
 a=np.empty(len(me.vertices)*3,np.float32);me.vertices.foreach_get('co',a)
 if not np.isfinite(a).all():badPositions.append(me.name)
 normals=np.empty(len(me.corner_normals)*3,np.float32);me.corner_normals.foreach_get('vector',normals)
 if not np.isfinite(normals).all() or (np.linalg.norm(normals.reshape(-1,3),axis=1)<1e-6).any():badNormals.append(me.name)
report=json.loads((R/'source_validation.json').read_text());report.update(revision='reference_04',source_instanced_triangles=sum(counts[o.data.name] for o in visible),visible_mesh_objects=len(visible),unique_meshes=len(meshes),invalid_positions=badPositions,invalid_corner_normals=badNormals,source_solar_background='Angular display disk aligned to the real sun; no duplicate irradiance contribution');(R/'source_validation.json').write_text(json.dumps(report,indent=2))
spec=json.loads((R/'scene_spec.json').read_text());spec['revision']='reference_04';spec['lighting']={'source_diffuse_sky_strength':3.4,'source_camera_sky_strength':.8,'source_sun_energy':4,'runtime':cfg['lighting'],'sky_angular_offset':.23,'notes':'Separate source/runtime transport calibration. Warm valley directional fill is an authored approximation.'};(R/'scene_spec.json').write_text(json.dumps(spec,indent=2))
s.camera=bpy.data.objects['Reference_Camera'];bpy.ops.wm.save_as_mainfile(filepath=str(R/'Alpine_Lake.blend'));print('FINAL_REVIEW',report['source_instanced_triangles'],badPositions,badNormals,flush=True)
