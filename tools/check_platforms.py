"""Report local export prerequisites. Never installs SDKs or modifies signing."""
from pathlib import Path
import argparse
import json
import os
import platform
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    host = platform.system()
    godot = os.environ.get('GODOT_BIN') or shutil.which('godot') or shutil.which('godot4')
    if not godot and host == 'Darwin':
        candidate = Path('/Applications/Godot.app/Contents/MacOS/Godot')
        if candidate.is_file():
            godot = str(candidate)
    version = ''
    if godot:
        run = subprocess.run([godot, '--version'], text=True, capture_output=True, timeout=20)
        version = run.stdout.strip()
    if host == 'Darwin':
        data = Path.home() / 'Library/Application Support/Godot'
    elif host == 'Windows':
        data = Path(os.environ.get('APPDATA', str(Path.home() / 'AppData/Roaming'))) / 'Godot'
    else:
        data = Path(os.environ.get('XDG_DATA_HOME', str(Path.home() / '.local/share'))) / 'godot'
    templates = data / 'export_templates' / '.'.join(version.split('.')[:4])
    required = {
        'Windows': 'windows_release_x86_64.exe',
        'macOS': 'macos.zip',
        'Linux': 'linux_release.x86_64',
        'Linux ARM64': 'linux_release.arm64',
        'Android': 'android_release.apk',
        'iOS': 'ios.zip',
    }
    sdk = os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT')
    if not sdk:
        sdk = str(Path.home() / ('Library/Android/sdk' if host == 'Darwin' else 'Android/Sdk'))
    report = {
        'host': host,
        'godot': godot,
        'version': version,
        'export_presets_present': (root / 'export_presets.cfg').is_file(),
        'template_directory': str(templates),
        'templates': {name: (templates / filename).is_file() for name, filename in required.items()},
        'android_sdk_directory_present': Path(sdk).is_dir(),
        'java_command_present': shutil.which('java') is not None,
        'xcode_present': host == 'Darwin' and Path('/Applications/Xcode.app/Contents/Developer').is_dir(),
        'signing': 'Release signing, bundle identifiers and store accounts must be configured by the project owner.',
        'ps4_ps5': 'Requires an approved Sony developer and a licensed Godot console port/export provider; no console SDK is bundled.',
        'scope': 'Prerequisite inventory only; presence does not verify SDK versions, signing, hardware compatibility or certification.',
    }
    output = json.dumps(report, ensure_ascii=False, indent=2)
    print(output)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output + '\n')


if __name__ == '__main__':
    main()
