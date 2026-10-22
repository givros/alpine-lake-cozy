import bpy,json,numpy as np
from pathlib import Path
R=Path('E:/Dev/cosy-lake-cosy-2/artifacts/alpine-reference')
s=bpy.context.scene
def record(o):
 return {'name':o.name,'mesh':o.data.name if o.type=='MESH' else None,'position':list(o.location),'size':list(o.dimensions),'scale':list(o.scale),'vertices':len(o.data.vertices) if o.type=='MESH' else 0,'materials':[m.name for m in o.data.materials if m] if o.type=='MESH' else []}
names=['Reference_Camera','Terrain_Continuous_Shore','Valley_Continuation','Alpine_Massif_Measured','Alpine_Snowpack_Deposits','Lake_Surface']
report={'blender':bpy.app.version_string,'objects':len(s.objects),'camera':record(s.camera),'named':[record(bpy.data.objects[n]) for n in names if n in bpy.data.objects], 'native':[record(o) for o in s.objects if o.name.startswith('Native_Adult_Fir_')][:4],'bridge':[record(o) for o in s.objects if 'Bridge' in o.name][:8]}
(R/'source_inspection.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report),flush=True)
