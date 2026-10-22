from pathlib import Path
from PIL import Image
import json

root = Path(__file__).resolve().parents[1] / 'viewer/public/assets/tree-impostors'
manifest = json.loads((root / 'manifest.json').read_text())
for mode in ['albedo', 'normal']:
    with (root / (mode + '.bin')).open('wb') as out:
        for layer in manifest['layers']:
            atlas = Image.new('RGBA', (1024, 1024))
            for angle in range(8):
                tile = Image.open(root / (f'{mode}_{layer["id"]:02d}_{angle}.png')).convert('RGBA')
                atlas.paste(tile, ((angle % 4) * 256, (angle // 4) * 512))
            out.write(atlas.tobytes())
