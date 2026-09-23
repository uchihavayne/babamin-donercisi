"""Export selected .pxo projects (or all of them) into the runtime PNG directory.

Usage: python3 tools/export_pixelorama.py [tezgah_esyalari]
Set PIXELORAMA_BIN if Pixelorama is installed in another location.
"""
from pathlib import Path
import os
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
default = '/Applications/Pixelorama.app/Contents/MacOS/Pixelorama' if sys.platform == 'darwin' else 'pixelorama'
binary = os.environ.get('PIXELORAMA_BIN', default)
names = sys.argv[1:]
projects = [root/'art/pixelorama'/f'{name.removesuffix(".pxo")}.pxo' for name in names] if names else sorted((root/'art/pixelorama').glob('*.pxo'))
for project in projects:
    if not project.is_file(): raise SystemExit(f'Missing project: {project}')
    output = root/'assets/sprites'/f'{project.stem}.png'
    previous = output.stat().st_mtime_ns if output.exists() else None
    result = subprocess.run([binary, '--headless', '--quit', '--', '--export', '--output', str(output), str(project)],
                            capture_output=True, text=True, timeout=45)
    if result.returncode != 0 or not output.exists() or output.stat().st_mtime_ns == previous:
        print(result.stdout + result.stderr)
        raise SystemExit(f'Export failed: {project.name}')
    print(f'Exported {output.relative_to(root)}')
