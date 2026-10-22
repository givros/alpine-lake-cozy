import bpy,numpy as np,json,math,random
from pathlib import Path
from mathutils import Vector,Quaternion
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];s=bpy.context.scene
def coords(me):
 a=np.empty(len(me.vertices)*3,np.float32);me.vertices.foreach_get('co',a);return a.reshape(-1,3)
support=[]
for name in ['Terrain_Continuous_Shore','Valley_Continuation']:
 ob=bpy.data.objects[name];ob.data.calc_loop_triangles();support.append(BVHTree.FromPolygons([ob.matrix_world@v.co for v in ob.data.vertices],[t.vertices[:] for t in ob.data.loop_triangles],all_triangles=True))
def ground(x,y):
 for bv in support:
  hit=bv.ray_cast(Vector((x,y,500)),Vector((0,0,-1)),1000)[0]
  if hit is not None:return hit.z
 return None
rocks=[]
for ob in s.objects:
 if ob.type!='MESH' or ob.hide_render or not any(m and m.name in ['rock_moss_set_01','rock_moss_set_02'] for m in ob.data.materials):continue
 x,y=ob.location.xy;h=ground(x,y)
 if h is None:continue
 a=coords(ob.data);matrix=np.array(ob.matrix_world);world=a@matrix[:3,:3].T+matrix[:3,3]
 lo=world[:,2].min();hi=world[:,2].max();desired=h-.14*(hi-lo);dz=desired-lo
 ob.location.z+=dz
 rocks.append({'id':ob.name,'vertical_correction':float(dz),'embed':float(h-desired)})
print('ACTUAL_ROCK_SUPPORT',len(rocks),flush=True)
# Timber grain follows each component's long axis. A narrow photographic strip
# avoids projecting a whole cabinet's repeated board seams across an individual log.
done=set();uvRecords=[]
for ob in s.objects:
 if ob.type!='MESH' or ob.hide_render or ob.data in done or not any(m and m.name in ['Timber_Photographic','Endgrain_Photographic'] for m in ob.data.materials):continue
 me=ob.data;done.add(me);a=coords(me);center=a.mean(0);values,vectors=np.linalg.eigh(np.cov((a-center).T));long=vectors[:,-1];across=vectors[:,-2]
 # Use longitudinal projection for grain; terminal cuts retain a cross-section.
 along=(a-center)@long;cross=(a-center)@across
 seed=sum(ord(c) for c in ob.name);offset=((seed*37)%9+.3)/10
 uv=me.uv_layers.active or me.uv_layers.new(name='UVMap');ids=np.empty(len(me.loops),np.int32);me.loops.foreach_get('vertex_index',ids)
 tex=np.stack([offset+cross*.045,along*.28+(seed%13)*.071],1).astype(np.float32)
 uv.data.foreach_set('uv',tex[ids].ravel());uvRecords.append(ob.name)
print('TIMBER_GRAIN_ALIGNED',len(uvRecords),flush=True)
# Continuous three-dimensional flowing surface, retaining the original channel.
stream=bpy.data.objects.get('Stream_Flow');streamRecord={}
if stream:
 old=coords(stream.data);pairs=old.reshape(-1,2,3);center=pairs.mean(1);order=np.argsort(center[:,1]);center=center[order];width=np.linalg.norm(pairs[order,1,:2]-pairs[order,0,:2],axis=1)*.5
 ys=np.linspace(center[0,1],center[-1,1],420);cx=np.interp(ys,center[:,1],center[:,0]);cz=np.interp(ys,center[:,1],center[:,2]);ww=np.interp(ys,center[:,1],width)
 verts=[];faces=[]
 for j,y in enumerate(ys):
  for k in range(13):
   t=k/12;xx=cx[j]+(t*2-1)*ww[j];ripple=.018*math.sin(y*4.2+xx*3.1)+.008*math.sin(y*9.3-xx*4.4)
   verts.append((xx,y,cz[j]+ripple))
  if j:
   for k in range(12):i=(j-1)*13+k;faces.append((i,i+1,i+14,i+13))
 material=stream.data.materials[0];me=bpy.data.meshes.new('Stream_Supported_Rippled_Surface');me.from_pydata(verts,[],faces);me.materials.append(material);me.update()
 for f in me.polygons:f.use_smooth=True
 stream.data=me
 oldfoam=[ob for ob in s.objects if ob.type=='MESH' and not ob.hide_render and any(m and m.name=='Foam' for m in ob.data.materials)]
 for ob in oldfoam:bpy.data.objects.remove(ob,do_unlink=True)
 rng=random.Random(724);fv=[];ff=[]
 for k in range(260):
  y=rng.uniform(float(ys[0]),float(ys[-1]));x=float(np.interp(y,ys,cx))+rng.uniform(-.72,.72)*float(np.interp(y,ys,ww));z=float(np.interp(y,ys,cz))+.027
  # Break foam into small irregular groups, leaving most water unobscured.
  if math.sin(y*1.1+.8)<.15 and rng.random()<.8:continue
  rx=rng.uniform(.018,.075);ry=rng.uniform(.06,.23);start=len(fv);fv.append((x,y,z))
  for i in range(8):
   theta=i*math.tau/8;r=rng.uniform(.72,1.18);xx=x+rx*r*math.cos(theta);yy=y+ry*r*math.sin(theta);zz=float(np.interp(yy,ys,cz))+.026+.012*math.sin(yy*4.2+xx*3.1);fv.append((xx,yy,zz))
  for i in range(8):ff.append((start,start+i+1,start+(i+1)%8+1))
 fm=bpy.data.meshes.new('Stream_Foam_Patches');fm.from_pydata(fv,[],ff);fm.materials.append(bpy.data.materials['Foam']);foam=bpy.data.objects.new('Stream_Foam_Patches',fm);stream.users_collection[0].objects.link(foam)
 streamRecord={'channel_vertices':len(verts),'foam_triangles':len(ff),'replaced_graphic_filaments':len(oldfoam),'water_z_range':[float(cz.min()),float(cz.max())]}
print('STREAM_REBUILT',streamRecord,flush=True)
# Match the runtime background to the original generated sky-only panorama.
config=json.loads((R/'viewer/public/assets/photoreal_config.json').read_text());world=s.world;world.use_nodes=True;n=world.node_tree.nodes;lk=world.node_tree.links;n.clear()
tc=n.new('ShaderNodeTexCoord');mapping=n.new('ShaderNodeMapping');q=config['sky']['world_rotation_quaternion_blender'];mapping.inputs['Rotation'].default_value=Quaternion(q).inverted().to_euler();lk.new(tc.outputs['Generated'],mapping.inputs[0]);env=n.new('ShaderNodeTexEnvironment');env.image=bpy.data.images.load(str(R/'references/alpine_sunset_sky.png'),check_existing=True);env.image.pack();lk.new(mapping.outputs[0],env.inputs[0]);bg=n.new('ShaderNodeBackground');bg.inputs[1].default_value=.8;lk.new(env.outputs[0],bg.inputs[0]);out=n.new('ShaderNodeOutputWorld');lk.new(bg.outputs[0],out.inputs['Surface'])
d=Vector(config['sky']['sun_direction_blender']);sun=bpy.data.objects['Sunset_Sun'];sun.rotation_euler=(-d).to_track_quat('-Z','Y').to_euler();sun.data.energy=4;sun.data.color=(1,.65,.36)
for ob in s.objects:
 if ob.type=='LIGHT' and ob!=sun and ob.data.type=='SUN':ob.data.energy=.5
config['materials']['wood_tint_linear']=[.62,.68,.65];(R/'viewer/public/assets/photoreal_config.json').write_text(json.dumps(config,indent=2))
(R/'surface_revision.json').write_text(json.dumps({'rock_support':rocks,'wood_grain_components':uvRecords,'stream':streamRecord,'sky':'Original ImageGen sky only, packed at native resolution'},indent=2))
s.camera=bpy.data.objects['Reference_Camera'];bpy.ops.wm.save_as_mainfile(filepath=str(R/'checkpoints/03_supported_surfaces.blend'));bpy.ops.wm.save_as_mainfile(filepath=str(R/'Alpine_Lake.blend'))
exec(compile((R/'scripts/export_current.py').read_text(),str(R/'scripts/export_current.py'),'exec'))
exec(compile((R/'scripts/preserve_float_colors.py').read_text(),str(R/'scripts/preserve_float_colors.py'),'exec'))
print('SURFACES_EXPORTED',flush=True)
