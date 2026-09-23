"""Package only the editable, native Godot game and its verification notes."""
from pathlib import Path
import zipfile
root = Path(__file__).resolve().parent.parent
out = root / 'Babamin_Donercisi_Godot.zip'
paths = [root/'project.godot', root/'README.md', root/'VALIDATION.md']
paths.append(root/'CODE_MAP.md')
paths.append(root/'ECONOMY.md')
paths.extend([root/'export_presets.cfg', root/'PLATFORMLAR.md'])
paths.append(root/'tools/export_pixelorama.py')
paths.append(root/'tools/check_platforms.py')
paths.append(root/'tools/bake_counter_design.gd')
paths.append(root/'tools/bake_sprites.gd')
paths.append(root/'tools/make_pixelorama.py')
# Include the maintained regression suites and empty output folders, so the
# editing guide's checks also work from an extracted source package.
for name in ['module_services', 'module_snapshot', 'module_performance',
             'economy', 'economy_visual',
             'ingredient_input', 'ingredient_input_visual', 'bread_preparation',
             'cutting', 'mouse_slicing', 'stations', 'order_flow', 'runtime_state',
             'platform_input', 'counter_input', 'regression',
             'counter_design_visual', 'order_flow_visual',
             'mouse_slicing_visual', 'stations_visual']:
    paths.append(root/'tests'/f'{name}.gd')
paths.extend((root/'artifacts').rglob('.gitkeep'))
paths.append(root/'artifacts/.gdignore')
paths.extend((root/'tests/fixtures').glob('*.json'))
for folder in ['scripts', 'scenes', 'data', 'assets', 'validation', 'art']:
    paths.extend(p for p in (root/folder).rglob('*') if p.is_file() and p.name != '.DS_Store')
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
    for path in sorted(paths):
        archive.write(path, 'Babamin_Donercisi_Godot/' + path.relative_to(root).as_posix())
print(out, out.stat().st_size, 'bytes;', len(paths), 'files')
