import bpy,struct,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];path=ROOT/'viewer/public/assets/alpine-lake.glb';raw=path.read_bytes();length,kind=struct.unpack_from('<II',raw,12);g=json.loads(raw[20:20+length]);offset=20+length;bl,kind=struct.unpack_from('<II',raw,offset);binary=bytearray(raw[offset+8:offset+8+g['buffers'][0]['byteLength']]);fixed=[]
for mesh in g['meshes']:
 name=mesh.get('name','');source=bpy.data.meshes.get(name)
 if not source or 'Color' not in source.color_attributes:continue
 attr=source.color_attributes['Color'];colors={(float(v.co.x),float(v.co.z),float(-v.co.y)):tuple(attr.data[v.index].color) for v in source.vertices}
 for primitive in mesh['primitives']:
  a=g['accessors'][primitive['attributes']['POSITION']];view=g['bufferViews'][a['bufferView']];start=view.get('byteOffset',0)+a.get('byteOffset',0);stride=view.get('byteStride',12);values=[]
  for i in range(a['count']):
   p=struct.unpack_from('<fff',binary,start+i*stride)
   if p not in colors:raise RuntimeError('Unmatched source colour position: '+name+' '+str(p))
   values.extend(colors[p])
  while len(binary)%4:binary.append(0)
  start=len(binary);binary.extend(struct.pack('<'+'f'*len(values),*values));bi=len(g['bufferViews']);g['bufferViews'].append({'buffer':0,'byteOffset':start,'byteLength':len(values)*4,'target':34962});ai=len(g['accessors']);g['accessors'].append({'bufferView':bi,'componentType':5126,'count':a['count'],'type':'VEC4'})
  keys=[key for key in primitive['attributes'] if key.startswith('COLOR_')]
  for key in keys:primitive['attributes'][key]=ai
  if not keys:primitive['attributes']['COLOR_0']=ai
  fixed.append({'mesh':name,'vertices':a['count'],'active_color_component':'FLOAT32','source_match':'exact source point-colour values'})
g['buffers'][0]['byteLength']=len(binary);j=json.dumps(g,separators=(',',':')).encode()
while len(j)%4:j+=b' '
while len(binary)%4:binary.append(0)
total=12+8+len(j)+8+len(binary);path.write_bytes(struct.pack('<III',0x46546c67,2,total)+struct.pack('<II',len(j),0x4e4f534a)+j+struct.pack('<II',len(binary),0x004e4942)+binary)
(ROOT/'color_transfer_validation.json').write_text(json.dumps({'precision_restored':fixed,'geometry_positions':'unchanged','indices':'unchanged','images':'unchanged'},indent=2));print('FLOAT_COLORS_PRESERVED',flush=True)
