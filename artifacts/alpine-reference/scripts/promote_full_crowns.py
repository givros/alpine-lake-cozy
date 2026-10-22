import bpy,json,re
from pathlib import Path
R=Path(__file__).resolve().parents[1]
source=(R/'scripts/dense_tree_study.py').read_text()
exec(compile(source.split("scene=bpy.data.scenes.new")[0],str(R/'scripts/dense_tree_study.py'),'exec'))
records=[]
meshes=[me for me in bpy.data.meshes if re.fullmatch(r'Spruce_(?:Wood|Foliage)_Prototype_\d+_Irregular_\d+',me.name)]
for me in meshes:
 oldname=me.name;variant=int(oldname.split('_')[-1]);new=densify(me,'Wood' in oldname,variant)
 owners=[o for o in bpy.data.objects if o.type=='MESH' and o.data==me]
 for ob in owners:ob.data=new
 me.name=oldname+'_Original';new.name=oldname
 records.append({'mesh':oldname,'owners':len(owners),'source_vertices':len(me.vertices),'new_vertices':len(new.vertices),'construction':'Original branching stem with two subordinate complete bough systems, real twig sprays and attached branches; no crown proxy volume.'})
(R/'tree_construction_revision.json').write_text(json.dumps({'representative_evidence':'renders/tree_representative.png','families':records},indent=2))
bpy.context.scene.camera=bpy.data.objects['Reference_Camera']
bpy.ops.wm.save_as_mainfile(filepath=str(R/'checkpoints/02_constructed_full_crowns.blend'))
bpy.ops.wm.save_as_mainfile(filepath=str(R/'Alpine_Lake.blend'))
exec(compile((R/'scripts/bake_tree_impostors.py').read_text(),str(R/'scripts/bake_tree_impostors.py'),'exec'))
