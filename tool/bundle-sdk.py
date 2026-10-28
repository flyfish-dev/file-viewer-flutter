#!/usr/bin/env python3
"""Build a complete path-dependency SDK from reviewed source and asset shards."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import tarfile

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = (ROOT / 'pubspec.yaml').read_text()
VERSION = re.search(r'^version: (.+)$', PUBSPEC, re.M).group(1)
OUTPUT = ROOT / '.release' / 'sdk' / f'file_viewer_flutter-{VERSION}'
PACKAGES = [
    'file_viewer_flutter_assets', 'file_viewer_flutter_assets_cad',
    'file_viewer_flutter_assets_drawing', 'file_viewer_flutter_assets_typst',
    'file_viewer_flutter_linux',
]
SKIP = {'.git', '.dart_tool', 'build', 'Pods', 'ephemeral', '.gradle', '.kotlin',
        '__pycache__', '.DS_Store', 'local.properties', 'Generated.xcconfig',
        'flutter_export_environment.sh', '.flutter-plugins-dependencies',
        'pubspec_overrides.yaml', 'pubspec.lock', '.symlinks', '.swiftpm'}


def ignore(_directory, names):
    return [name for name in names if name in SKIP or name.endswith('.pyc')]


if OUTPUT.exists():
    shutil.rmtree(OUTPUT)
OUTPUT.mkdir(parents=True)
for name in ['lib', 'bin', 'windows', 'packages', 'docs', 'example']:
    shutil.copytree(ROOT / name, OUTPUT / name, ignore=ignore, symlinks=True)
for name in ['README.md', 'LICENSE', 'CHANGELOG.md', 'analysis_options.yaml', '.pubignore']:
    shutil.copy2(ROOT / name, OUTPUT / name)
for name in PACKAGES:
    pattern = rf'^  {re.escape(name)}: {re.escape(VERSION)}$'
    PUBSPEC, count = re.subn(pattern, f'  {name}:\n    path: packages/{name}', PUBSPEC, flags=re.M)
    if count != 1:
        raise RuntimeError(f'Missing version-locked dependency: {name}')
(OUTPUT / 'pubspec.yaml').write_text(PUBSPEC)
# The example obtains local transitive dependencies from the bundled root.
example = OUTPUT / 'example' / 'pubspec.yaml'
content = example.read_text()
content = re.sub(r'^dependency_overrides:\n(?:[ \t].*\n|\n)*', '', content, flags=re.M)
example.write_text(content)
entries = []
for path in sorted(OUTPUT.rglob('*')):
    if path.is_symlink():
        raise RuntimeError(f'Symlink is not allowed in SDK bundle: {path.relative_to(OUTPUT)}')
    if path.is_file():
        data = path.read_bytes()
        entries.append({'path': path.relative_to(OUTPUT).as_posix(), 'size': len(data),
                        'sha256': hashlib.sha256(data).hexdigest()})
(OUTPUT / 'SDK-MANIFEST.json').write_text(json.dumps({'version': VERSION, 'files': entries}, indent=2) + '\n')
archive = ROOT / '.release' / f'file_viewer_flutter-{VERSION}-sdk.tar.gz'
with tarfile.open(archive, 'w:gz') as package:
    package.add(OUTPUT, arcname=OUTPUT.name)
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
archive.with_suffix(archive.suffix + '.sha256').write_text(f'{digest}  {archive.name}\n')
print(json.dumps({'archive': str(archive), 'sha256': digest, 'files': len(entries),
                  'size': archive.stat().st_size}))
