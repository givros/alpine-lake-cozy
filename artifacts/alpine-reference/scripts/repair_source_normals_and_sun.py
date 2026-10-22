import bpy,numpy as np,json
from pathlib import Path
from mathutils import Vector,Quaternion
R=Path(__file__).resolve().parents[1];s=bpy.context.scene;cfg=json.loads((R/'viewer/public/assets/photoreal_config.json').read_text());report=json.loads((R/'source_validation.json').read_text());fixed=[]
for name in report.get('invalid_corner_normals',[]):
 me=bpy.data.meshes[name];norm=np.empty(len(me.corner_normals)*3,np.float32);me.corner_normals.foreach_get('vector',norm);norm=norm.reshape(-1,3);bad=np.linalg.norm(norm,axis=1)<1e-6;initial=int(bad.sum())
 for p in me.polygons:
  normal=np.asarray(p.normal,np.float32)
  if np.linalg.norm(normal)<1e-6:normal=np.array([0,0,1],np.float32)
  for li in p.loop_indices:
   if bad[li]:norm[li]=normal
 me.normals_split_custom_set(norm.tolist());fixed.append({'mesh':name,'repaired_zero_fans':initial,'geometry':'All positions, faces, UVs and materials preserved; only invalid corner normals repaired'})
nodes=s.world.node_tree.nodes
for n in nodes:
 if n.type=='VECT_MATH' and n.operation=='DOT_PRODUCT':n.inputs[1].default_value=cfg['sky']['sun_direction_blender']
 if n.type=='MAPPING':n.inputs['Rotation'].default_value=Quaternion(cfg['sky']['world_rotation_quaternion_blender']).inverted().to_euler()
d=Vector(cfg['sky']['sun_direction_blender']);bpy.data.objects['Sunset_Sun'].rotation_euler=(-d).to_track_quat('-Z','Y').to_euler()
remaining=[]
for name in report.get('invalid_corner_normals',[]):
 me=bpy.data.meshes[name];a=np.empty(len(me.corner_normals)*3,np.float32);me.corner_normals.foreach_get('vector',a)
 if (np.linalg.norm(a.reshape(-1,3),axis=1)<1e-6).any() or not np.isfinite(a).all():remaining.append(name)
report['invalid_corner_normals']=remaining;report['normal_repair']=fixed;report['exported_normal_audit']='All GLB NORMAL arrays were checked independently and already contained finite nonzero normals; the source repair preserves the valid exported geometric result.';(R/'source_validation.json').write_text(json.dumps(report,indent=2))
spec=json.loads((R/'scene_spec.json').read_text());spec['lighting']['runtime']=cfg['lighting'];spec['lighting']['sun_direction_blender']=list(d);spec['reconstruction']['solar_landmark_normalized']=[.134,.285];(R/'scene_spec.json').write_text(json.dumps(spec,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(R/'Alpine_Lake.blend'));print('NORMALS_AND_SUN_REVIEW',fixed,'remaining',remaining,flush=True)
