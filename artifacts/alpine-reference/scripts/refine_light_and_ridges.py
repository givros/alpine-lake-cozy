import bpy,numpy as np,json
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];s=bpy.context.scene
def coords(me):
 a=np.empty(len(me.vertices)*3,np.float32);me.vertices.foreach_get('co',a);return a.reshape(-1,3)
me=bpy.data.objects['Alpine_Massif_Measured'].data;a=coords(me);grid=a.reshape(1280,1280,3);z=grid[:,:,2];r=3;p=np.pad(z,((r,r),(r,r)),mode='edge');I=np.pad(p,((1,0),(1,0))).cumsum(0).cumsum(1);w=2*r+1;blur=(I[w:,w:]-I[:-w,w:]-I[w:,:-w]+I[:-w,:-w])/(w*w)
weight=np.clip((z-55)/40,0,1)*np.clip((grid[:,:,1]-190)/70,0,1);delta=(blur-z)*.68*weight
a[:,2]+=delta.ravel();me.vertices.foreach_set('co',a.ravel());me.update()
snow=bpy.data.objects['Alpine_Snowpack_Deposits'].data;b=coords(snow);keys=np.ascontiguousarray(a[:,:2]).view(np.uint64).ravel();query=np.ascontiguousarray(b[:,:2]).view(np.uint64).ravel();order=np.argsort(keys);idx=order[np.searchsorted(keys[order],query)];assert np.all(keys[idx]==query);b[:,2]+=delta.ravel()[idx];snow.vertices.foreach_set('co',b.ravel());snow.update()
me.calc_loop_triangles();bv=BVHTree.FromPolygons(a.tolist(),[t.vertices[:] for t in me.loop_triangles],all_triangles=True);regrounded=0
navPath=R/'viewer/public/assets/navigation.json';nav=json.loads(navPath.read_text());byId={t.get('id'):t for t in nav['trees']}
lo=a.min(0);hi=a.max(0)
for ob in s.objects:
 if ob.type!='MESH' or ob.hide_render or not ob.data.name.startswith('Spruce_Wood_Prototype_'):continue
 x,y=ob.location.xy
 if not(lo[0]<=x<=hi[0] and lo[1]<=y<=hi[1]):continue
 hit=bv.ray_cast(Vector((x,y,600)),Vector((0,0,-1)),1200)[0]
 if hit is None:continue
 ob.location.z=hit.z-.12;leaf=bpy.data.objects.get(ob.name[:-5]+'_Needles') if ob.name.endswith('_Wood') else None
 if leaf:leaf.location.z=ob.location.z
 if ob.name in byId:byId[ob.name]['position']=list(ob.location);byId[ob.name]['soil_datum']=hit.z
 regrounded+=1
navPath.write_text(json.dumps(nav,separators=(',',':')))
# Compress the photographed upper sky's angular placement without replacing
# any environmental object by an image. The original texture remains unchanged.
nodes=s.world.node_tree.nodes;links=s.world.node_tree.links;env=next(n for n in nodes if n.type=='TEX_ENVIRONMENT');mapping=next(n for n in nodes if n.type=='MAPPING');add=nodes.new('ShaderNodeVectorMath');add.operation='ADD';add.inputs[1].default_value=(0,0,.23);links.new(mapping.outputs[0],add.inputs[0]);norm=nodes.new('ShaderNodeVectorMath');norm.operation='NORMALIZE';links.new(add.outputs[0],norm.inputs[0]);links.new(norm.outputs[0],env.inputs[0])
# LDR panorama carries appearance, not calibrated HDR energy. Separate camera
# radiance from diffuse sky illumination, retaining the observed shaded colors.
bg=next(n for n in nodes if n.type=='BACKGROUND');bg.inputs[1].default_value=.8;fill=nodes.new('ShaderNodeBackground');fill.inputs[1].default_value=3.4;links.new(env.outputs[0],fill.inputs[0]);lightpath=nodes.new('ShaderNodeLightPath');mix=nodes.new('ShaderNodeMixShader');links.new(lightpath.outputs['Is Camera Ray'],mix.inputs[0]);links.new(fill.outputs[0],mix.inputs[1]);links.new(bg.outputs[0],mix.inputs[2]);out=next(n for n in nodes if n.type=='OUTPUT_WORLD');links.new(mix.outputs[0],out.inputs[0])
s.view_settings.exposure=.25
(R/'lighting_landform_revision.json').write_text(json.dumps({'revision':'reference_04','ridge_smoothing_maximum_metres':float(abs(delta).max()),'snow_support_correspondence':'Exact source XY mapping, original deposit thickness retained','regrounded_trees':regrounded,'sky_angular_offset':.23,'source_camera_background_strength':.8,'source_diffuse_sky_strength':3.4,'reason':'Correct thin warped spires and missing diffuse sky fill without globally brightening the sky or reducing source detail'},indent=2))
s.camera=bpy.data.objects['Reference_Camera'];bpy.ops.wm.save_as_mainfile(filepath=str(R/'checkpoints/04_ridges_and_diffuse_light.blend'));bpy.ops.wm.save_as_mainfile(filepath=str(R/'Alpine_Lake.blend'))
exec(compile((R/'scripts/export_current.py').read_text(),str(R/'scripts/export_current.py'),'exec'))
exec(compile((R/'scripts/preserve_float_colors.py').read_text(),str(R/'scripts/preserve_float_colors.py'),'exec'))
print('LIGHT_AND_RIDGES_EXPORTED',flush=True)
