import bpy,json,os
from pathlib import Path
R=Path(__file__).resolve().parents[1];s=bpy.context.scene
try:
 prefs=bpy.context.preferences.addons['cycles'].preferences;prefs.compute_device_type='OPTIX';prefs.get_devices()
 for d in prefs.devices:d.use=d.type!='CPU'
 s.cycles.device='GPU'
except Exception:pass
s.render.engine='CYCLES';s.cycles.samples=16;s.cycles.use_denoising=True;s.render.resolution_x=1024;s.render.resolution_y=576;s.render.resolution_percentage=100;s.render.image_settings.file_format='PNG'
names=['Reference_Camera','Inspection_Aerial','Inspection_West','Inspection_East','Inspection_Reverse','Inspection_Cabin','Inspection_Bridge','Inspection_Forest','Inspection_Shore']
if os.environ.get('SCENE_RENDER_VIEWS'):names=os.environ['SCENE_RENDER_VIEWS'].split(',')
results=[]
for name in names:
 s.camera=bpy.data.objects[name];s.render.filepath=str(R/'renders'/('blender_'+name+'.png'));bpy.ops.render.render(write_still=True);results.append(name);print('SOURCE_VIEW',name,flush=True)
(R/'reopen_validation.json').write_text(json.dumps({'fresh_process':True,'loaded_file':bpy.data.filepath,'blender':bpy.app.version_string,'rendered_cameras':results,'engine':s.render.engine,'device':s.cycles.device,'samples':s.cycles.samples,'resolution':[1024,576],'all_requested_source_views_rendered':len(results)==len(names)},indent=2))
