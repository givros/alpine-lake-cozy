import bpy
from pathlib import Path
R=Path('E:/Dev/cosy-lake-cosy-2/artifacts/alpine-reference');visible=[o for o in bpy.context.scene.objects if o.type=='MESH' and not o.hide_render]
for me in {o.data for o in visible}:me.calc_loop_triangles()
print('CURRENT_TRIANGLES',sum(len(o.data.loop_triangles) for o in visible),'OBJECTS',len(visible),flush=True)
visible_set=set(visible)
for o in bpy.context.scene.objects:o.select_set(o in visible_set)
bpy.ops.export_scene.gltf(filepath=str(R/'viewer/public/assets/alpine-lake.glb'),export_format='GLB',use_selection=True,export_gpu_instances=True,export_yup=True,export_extras=True,export_apply=True)
print('FULL_EXPORT_COMPLETE',flush=True)
