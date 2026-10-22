import bpy,numpy as np,math,json
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1]
def densify(me,wood,variant=0):
 v=np.empty(len(me.vertices)*3,np.float32);me.vertices.foreach_get('co',v);v=v.reshape(-1,3)
 faces=[list(f.vertices) for f in me.polygons];uv=me.uv_layers.active
 sourceUV=np.empty(len(me.loops)*2,np.float32);uv.data.foreach_get('uv',sourceUV);sourceUV=sourceUV.reshape(-1,2)
 vs=[v];fs=faces.copy();uvs=[sourceUV]
 branchFaces=[f for f in me.polygons if not wood or max(f.vertices)>=480]
 for turn,scale in [(.49+variant*.013,.94),(-.57-variant*.009,1.035)]:
  q=v.copy();c=math.cos(turn);s=math.sin(turn);q[:,0]=v[:,0]*c-v[:,1]*s;q[:,1]=v[:,0]*s+v[:,1]*c
  # Small subordinate bough variation, with branch insertion still on the stem.
  q[:,2]=v[:,2]*scale;offset=sum(len(a) for a in vs);vs.append(q)
  for f in branchFaces:fs.append([i+offset for i in f.vertices])
  uvs.append(np.concatenate([sourceUV[f.loop_start:f.loop_start+f.loop_total] for f in branchFaces]))
 out=bpy.data.meshes.new(me.name+'_FullCrown');out.from_pydata(np.concatenate(vs).tolist(),[],fs);out.update()
 for m in me.materials:out.materials.append(m)
 out.uv_layers.new(name='UVMap').data.foreach_set('uv',np.concatenate(uvs).ravel())
 for f in out.polygons:f.use_smooth=True
 return out
scene=bpy.data.scenes.new('Conifer_Representative_Study');scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True;scene.render.resolution_x=768;scene.render.resolution_y=1024;scene.render.resolution_percentage=100
world=bpy.data.worlds.new('Study_World');world.use_nodes=True;world.node_tree.nodes.get('Background').inputs[0].default_value=(.48,.62,.8,1);world.node_tree.nodes.get('Background').inputs[1].default_value=.6;scene.world=world
for prefix in ['Spruce_Wood_Prototype_','Spruce_Foliage_Prototype_']:
 me=bpy.data.meshes[prefix+'0_Irregular_0'];new=densify(me,'Wood' in prefix);ob=bpy.data.objects.new('Study_'+prefix,new);scene.collection.objects.link(ob)
sunData=bpy.data.lights.new('Study_Sunset','SUN');sunData.energy=3;sunData.angle=.08;sunData.color=(1,.73,.48);sun=bpy.data.objects.new('Study_Sunset',sunData);sun.rotation_euler=(.6,-.5,-.7);scene.collection.objects.link(sun)
cameraData=bpy.data.cameras.new('Study_Camera');camera=bpy.data.objects.new('Study_Camera',cameraData);scene.collection.objects.link(camera);camera.location=(13,-20,7);camera.rotation_euler=(Vector((0,0,5.7))-camera.location).to_track_quat('-Z','Y').to_euler();cameraData.lens=55;scene.camera=camera
try:
 prefs=bpy.context.preferences.addons['cycles'].preferences;prefs.compute_device_type='OPTIX';prefs.get_devices()
 for d in prefs.devices:d.use=d.type!='CPU'
 scene.cycles.device='GPU'
except Exception:pass
scene.render.filepath=str(R/'renders/tree_representative.png');bpy.ops.render.render(write_still=True,scene=scene.name)
print('TREE_REPRESENTATIVE_RENDERED',flush=True)
