"""Reference-driven revision of independently copied, editable alpine assets."""
import bpy, math, json, numpy as np, random
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1]
s=bpy.context.scene
def coords(me):
 a=np.empty(len(me.vertices)*3,np.float32);me.vertices.foreach_get('co',a);return a.reshape(-1,3)
def setcoords(me,a):me.vertices.foreach_set('co',np.asarray(a,np.float32).ravel());me.update()
def smooth(t):
 t=np.clip(t,0,1);return t*t*(3-2*t)
cam=bpy.data.objects['Reference_Camera'];s.camera=cam
s.render.resolution_x=1672;s.render.resolution_y=941;s.render.resolution_percentage=100
P=np.array(cam.calc_matrix_camera(bpy.context.evaluated_depsgraph_get(),x=1672,y=941))@np.array(cam.matrix_world.inverted())
def project(v):
 clip=np.column_stack([v,np.ones(len(v))])@P.T
 return clip[:,:2]/clip[:,3,None]*.5+.5,clip
me=bpy.data.objects['Alpine_Massif_Measured'].data;a=coords(me);before=a.copy();uv,clip=project(a)
# Top-origin observations from the actual supplied image, not a generated concept.
anchors=np.array([[-.15,.36],[0,.34],[.08,.33],[.13,.30],[.17,.283],[.20,.271],[.218,.246],[.237,.235],[.25,.206],[.26,.197],[.272,.219],[.282,.237],[.30,.245],[.316,.219],[.33,.235],[.348,.201],[.362,.183],[.375,.19],[.389,.20],[.407,.166],[.418,.188],[.434,.183],[.45,.17],[.465,.158],[.482,.12],[.494,.13],[.506,.10],[.518,.077],[.534,.046],[.542,.047],[.554,.072],[.564,.087],[.574,.113],[.585,.085],[.595,.103],[.608,.149],[.619,.13],[.635,.149],[.65,.164],[.67,.108],[.681,.10],[.691,.125],[.71,.163],[.725,.169],[.74,.151],[.752,.166],[.764,.144],[.777,.178],[.79,.203],[.806,.181],[.824,.207],[.839,.178],[.854,.201],[.874,.219],[.893,.233],[.91,.24],[.93,.223],[.95,.207],[.975,.16],[1,.13],[1.15,.08]])
bins=2400;ix=np.clip((uv[:,0]*bins).astype(int),0,bins-1);env=np.full(bins,-10.);np.maximum.at(env,ix,uv[:,1]);good=env>-.5;env=np.interp(np.arange(bins),np.flatnonzero(good),env[good]);env=np.convolve(np.pad(env,(2,2),mode='edge'),np.ones(5)/5,mode='valid')
current=np.interp(uv[:,0],np.arange(bins)/bins,env);desired=1-np.interp(uv[:,0],anchors[:,0],anchors[:,1]);base=.46
weight=np.clip((uv[:,1]-base)/np.maximum(current-base,.02),0,1)**1.15*smooth((a[:,1]-190)/90)
target=2*(uv[:,1]+(desired-current)*weight)-1
dz=(target*clip[:,3]-clip[:,1])/(P[1,2]-target*P[3,2]);a[:,2]+=dz
setcoords(me,a)
print('RIDGE_RECOMPOSED',float(abs(dz).max()),flush=True)
# Supported snow in high concave bowls and gullies; exposed ribs remain rock.
grid=a.reshape(1280,1280,3);z=grid[:,:,2];x=grid[:,:,0];y=grid[:,:,1]
sy,sx=np.gradient(z,.72,.72);slope=np.hypot(sx,sy)
radius=8;p=np.pad(z,((radius,radius),(radius,radius)),mode='edge');integral=np.pad(p,((1,0),(1,0))).cumsum(0).cumsum(1);w=radius*2+1
blur=(integral[w:,w:]-integral[:-w,w:]-integral[w:,:-w]+integral[:-w,:-w])/(w*w)
conc=np.clip((blur-z)*.75+.43,0,1)
old=np.empty(len(me.vertices)*4,np.float32);me.color_attributes['Color'].data.foreach_get('color',old);old=old.reshape(-1,4)
alt=smooth((z-62)/87)
hold=1-smooth((slope-1.15)/2.4)
# Snow-filled channels follow downhill curvature, with bare sharp convex spines.
snow=np.clip(alt*(.24+.92*conc)*(.24+.76*hold),0,1)
snow=np.maximum(snow,old[:,0].reshape(z.shape)*.85)
snow*=smooth((z-48)/28)
old[:,0]=snow.ravel();old[:,1]*=1-smooth((z.ravel()-45)/40)
me.color_attributes['Color'].data.foreach_set('color',old.ravel())
previous=bpy.data.objects['Alpine_Snowpack_Deposits'];snowMat=previous.data.materials[0];targetCollection=previous.users_collection[0];bpy.data.objects.remove(previous,do_unlink=True)
active=(snow[:-1,:-1]+snow[1:,:-1]+snow[:-1,1:]+snow[1:,1:])*.25>.57
cells=np.argwhere(active);k=cells[:,0]*1280+cells[:,1];quads=np.stack([k,k+1280,k+1281,k+1],1);used=np.unique(quads);remap=np.full(len(a),-1,np.int32);remap[used]=np.arange(len(used));L=len(used)
upper=a[used].copy();upper[:,2]+=.18+.45*np.clip((snow.ravel()[used]-.57)/.43,0,1);bottom=a[used].copy();bottom[:,2]-=.045
verts=np.concatenate([upper,bottom]);faces=remap[quads].tolist()
for j,i in cells:
 k=j*1280+i;edges=[]
 if j==0 or not active[j-1,i]:edges.append((k,k+1))
 if j==1278 or not active[j+1,i]:edges.append((k+1281,k+1280))
 if i==0 or not active[j,i-1]:edges.append((k+1280,k))
 if i==1278 or not active[j,i+1]:edges.append((k+1,k+1281))
 for aa,bb in edges:
  aa=int(remap[aa]);bb=int(remap[bb]);faces.append((aa,bb,bb+L,aa+L))
sm=bpy.data.meshes.new('Reference_Supported_Snow');sm.from_pydata(verts.tolist(),[],faces);sm.materials.append(snowMat);sm.update();so=bpy.data.objects.new('Alpine_Snowpack_Deposits',sm);targetCollection.objects.link(so)
for f in sm.polygons:f.use_smooth=True
tex=sm.uv_layers.new(name='UVMap');ids=np.empty(len(sm.loops),np.int32);sm.loops.foreach_get('vertex_index',ids);tex.data.foreach_set('uv',(verts[ids,:2]*.025).astype(np.float32).ravel())
print('SUPPORTED_SNOW',len(cells),flush=True)
# Actual final triangles own planting height after the non-affine skyline correction.
me.calc_loop_triangles();bv=BVHTree.FromPolygons(a.tolist(),[t.vertices[:] for t in me.loop_triangles],all_triangles=True)
navPath=R/'viewer/public/assets/navigation.json';nav=json.loads(navPath.read_text());navMap={t.get('id'):t for t in nav['trees']};replanted=[]
for ob in s.objects:
 if ob.type!='MESH' or ob.hide_render or not ob.data.name.startswith('Spruce_Wood_Prototype_'):continue
 X,Y=ob.location.xy
 if not (a[:,0].min()<=X<=a[:,0].max() and a[:,1].min()<=Y<=a[:,1].max()):continue
 hit=bv.ray_cast(Vector((X,Y,700)),Vector((0,0,-1)),1400)[0]
 if hit is None:continue
 ob.location.z=hit.z-.12
 leaf=bpy.data.objects.get(ob.name[:-5]+'_Needles') if ob.name.endswith('_Wood') else None
 if leaf:leaf.location.z=ob.location.z
 if ob.name in navMap:navMap[ob.name]['position']=list(ob.location);navMap[ob.name]['soil_datum']=hit.z
 replanted.append(ob.name)
print('REGROUNDED',len(replanted),flush=True)
# Native, fully modeled firs strengthen only visible near/middle groves.
terrain=bpy.data.objects['Terrain_Continuous_Shore'];terrain.data.calc_loop_triangles();tv=BVHTree.FromPolygons([v.co[:] for v in terrain.data.vertices],[t.vertices[:] for t in terrain.data.loop_triangles],all_triangles=True)
c=bpy.data.collections.new('Reference_Botanical_Groves');s.collection.children.link(c)
prototypes=[]
for ob in s.objects:
 if ob.name.startswith('Native_Adult_Fir_') and ob.type=='MESH' and ob.data not in [p.data for p in prototypes]:prototypes.append(ob)
placements=[(-44,42,16),(-38,48,19),(-30,53,17),(-21,62,17),(-13,68,19),(-3,77,15),(10,82,19),(16,78,17),(32,73,18),(38,65,20),(44,57,18),(46,47,17),(53,35,18),(58,22,19),(61,5,22),(-61,30,19),(-54,16,20),(-49,5,17)]
rng=random.Random(1022);made=[];removed=[]
woods=[ob for ob in s.objects if ob.type=='MESH' and not ob.hide_render and ob.name.endswith('_Wood') and ob.data.name.startswith('Spruce_Wood_Prototype_')]
for i,(X,Y,H) in enumerate(placements):
 hit=tv.ray_cast(Vector((X,Y,100)),Vector((0,0,-1)),200)[0]
 if hit is None or hit.z<.8:continue
 near=sorted(woods,key=lambda o:(o.location.x-X)**2+(o.location.y-Y)**2)
 if near and math.hypot(near[0].location.x-X,near[0].location.y-Y)<4.5:
  ob=near[0];woods.remove(ob);prefix=ob.name[:-5];leaf=bpy.data.objects.get(prefix+'_Needles');removed.append(prefix)
  for q in [ob,leaf]:
   if q:bpy.data.objects.remove(q,do_unlink=True)
 proto=prototypes[i%len(prototypes)];ob=bpy.data.objects.new('Reference_Native_Fir_'+str(i),proto.data);c.objects.link(ob)
 height=max(v.co.z for v in proto.data.vertices)-min(v.co.z for v in proto.data.vertices);scale=H/height
 ob.scale=(scale*rng.uniform(.9,1.1),scale*rng.uniform(.9,1.1),scale);ob.rotation_euler.z=rng.random()*math.tau;ob.location=(X,Y,hit.z-.08);made.append({'id':ob.name,'position':list(ob.location),'soil_datum':hit.z,'scale':scale,'prototype':ob.data.name})
nav['trees']=[t for t in nav['trees'] if not any(t.get('id','').startswith(p) for p in removed)]+made
navPath.write_text(json.dumps(nav,separators=(',',':')))
print('BOTANICAL_GROVES',len(made),flush=True)
spec=json.loads((R/'scene_spec.json').read_text());spec['reconstruction']={'landmarks_top_origin':anchors.tolist(),'method':'Measured-image skyline constrained over a real measured alpine landform; supported concave snow deposits; native botanical grove replacements','observed_vs_authored':'Image composition is observed; all depth, scale and unseen continuation are authored inferences','source_revision':'reference_01'};(R/'scene_spec.json').write_text(json.dumps(spec,indent=2))
(R/'reconstruction_changes.json').write_text(json.dumps({'source_revision':'reference_01','max_skyline_vertical_change_m':float(abs(dz).max()),'snow_cells':len(cells),'replanted':len(replanted),'native_firs':made,'removed_spruce_assemblies':removed},indent=2))
# Every file is independently packed; no dependency on the former project remains.
for image in bpy.data.images:
 if image.source=='FILE' and not image.packed_file:
  try:image.pack()
  except Exception as e:print('PACK_WARNING',image.name,str(e),flush=True)
bpy.ops.wm.save_as_mainfile(filepath=str(R/'checkpoints/01_reference_landform.blend'))
bpy.ops.wm.save_as_mainfile(filepath=str(R/'Alpine_Lake.blend'))
exec(compile((R/'scripts/export_current.py').read_text(),str(R/'scripts/export_current.py'),'exec'))
exec(compile((R/'scripts/preserve_float_colors.py').read_text(),str(R/'scripts/preserve_float_colors.py'),'exec'))
print('REFERENCE_REVISION_EXPORTED',flush=True)
