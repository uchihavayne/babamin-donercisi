"""Create editable Pixelorama projects from the game-authored PNG atlases.

Uses Pixelorama's documented ZIP/data.json + raw RGBA cel format. This is an
explicit authoring step, never part of game startup. Existing projects are kept
unless --replace is passed.
"""
from pathlib import Path
from PIL import Image
import io
import json
import sys
import zipfile
import argparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('names', nargs='*', help='PNG atlas names, without extension; default: all')
parser.add_argument('--replace', action='store_true')
args = parser.parse_args()

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'assets/sprites'
OUT = ROOT / 'art/pixelorama'
OUT.mkdir(parents=True, exist_ok=True)
manifest = json.loads((SOURCE / 'manifest.json').read_text())
for path in sorted(SOURCE.glob('*.png')):
    if args.names and path.stem not in args.names:
        continue
    output = OUT / (path.stem + '.pxo')
    if output.exists() and not args.replace:
        print('Kept', output.name)
        continue
    image = Image.open(path).convert('RGBA')
    entries = [(key, value) for key, value in manifest.items() if value['sheet'] == path.name]
    layers, images = [], []
    for key, entry in entries:
        x, y, w, h = entry['region']
        layer = Image.new('RGBA', image.size)
        layer.paste(image.crop((x, y, x+w, y+h)), (x, y))
        images.append(layer)
        layers.append({'type': 0, 'name': key, 'visible': True, 'locked': False,
                       'blend_mode': 0, 'opacity': 1, 'parent': -1})
    data = {'pixelorama_version': 'v1.2.3-stable', 'pxo_version': 6,
            'size_x': image.width, 'size_y': image.height, 'color_mode': 5,
            'layers': layers,
            'frames': [{'cels': [{'opacity': 1, 'z_index': 0} for _ in layers], 'duration': 1}],
            'current_frame': 0, 'current_layer': 0, 'fps': 6,
            'user_data': 'Babamin Donercisi. Keep canvas size and sprite positions. Export as PNG into assets/sprites/'+path.name}
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        archive.writestr('data.json', json.dumps(data, ensure_ascii=False))
        for index, layer in enumerate(images, 1):
            archive.writestr(f'image_data/frames/1/layer_{index}', layer.tobytes())
        preview = image.copy()
        preview.thumbnail((256, 256), Image.Resampling.NEAREST)
        buf = io.BytesIO(); preview.save(buf, format='PNG')
        archive.writestr('preview.png', buf.getvalue())
    print(output.name, len(layers), 'layers')
