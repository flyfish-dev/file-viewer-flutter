#!/usr/bin/env python3
"""Build a complete path-dependency SDK from reviewed source and asset shards."""
import hashlib
import gzip
import json
from pathlib import Path
import re
import shutil
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = (ROOT / 'pubspec.yaml').read_text()
VERSION = re.search(r'^version: (.+)$', PUBSPEC, re.M).group(1)
OUTPUT = ROOT / '.release' / 'sdk' / f'file_viewer_flutter-{VERSION}'
PACKAGES = [
    'file_viewer_flutter_assets', 'file_viewer_flutter_assets_cad',
    'file_viewer_flutter_assets_drawing', 'file_viewer_flutter_assets_typst',
    'file_viewer_flutter_linux', 'file_viewer_flutter_macos',
]
SKIP = {'.git', '.dart_tool', 'build', 'Pods', 'ephemeral', '.gradle', '.kotlin',
        '__pycache__', '.DS_Store', 'local.properties', 'Generated.xcconfig',
        'flutter_export_environment.sh', '.flutter-plugins-dependencies',
        'pubspec_overrides.yaml', 'pubspec.lock', '.symlinks', '.swiftpm'}
TRACKED = set(subprocess.check_output(
    ['git', '-C', str(ROOT), 'ls-files', '-z'], text=True).split('\0')) - {''}
TRACKED_DIRECTORIES = {
    parent.as_posix() for name in TRACKED for parent in Path(name).parents
}


def ignore(directory, names):
    relative = Path(directory).relative_to(ROOT)
    return [name for name in names if name in SKIP or name.endswith('.pyc') or
            ((relative / name).as_posix() not in TRACKED and
             (relative / name).as_posix() not in TRACKED_DIRECTORIES)]


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
for name in PACKAGES:
    if not name.startswith('file_viewer_flutter_assets'):
        continue
    assets = OUTPUT / 'packages' / name / 'assets'
    manifest = json.loads((assets / 'manifest.json').read_text())
    if manifest['package'] != name or manifest['protocolVersion'] != 1:
        raise RuntimeError(f'Incompatible SDK resource manifest: {name}')
    for entry in manifest['files']:
        path = assets / entry['path']
        if not path.resolve().is_relative_to(assets.resolve()):
            raise RuntimeError('Resource path escapes its SDK asset package.')
        data = path.read_bytes()
        if len(data) != entry['size'] or hashlib.sha256(data).hexdigest() != entry['sha256']:
            raise RuntimeError(f'SDK resource checksum mismatch: {name}/{entry["path"]}')
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
epoch = int(json.loads((ROOT / 'runtime/package.json').read_text())['sourceDateEpoch'])
def canonical(info):
    info.uid = info.gid = 0
    info.uname = info.gname = ''
    info.mtime = epoch
    info.mode = 0o755 if info.isdir() or info.mode & 0o111 else 0o644
    info.pax_headers = {}
    return info
with archive.open('wb') as destination:
    with gzip.GzipFile(fileobj=destination, mode='wb', filename='', mtime=epoch) as compressed:
        with tarfile.open(fileobj=compressed, mode='w', format=tarfile.PAX_FORMAT) as package:
            package.add(OUTPUT, arcname=OUTPUT.name, filter=canonical)
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
archive.with_suffix(archive.suffix + '.sha256').write_text(f'{digest}  {archive.name}\n')
print(json.dumps({'archive': str(archive), 'sha256': digest, 'files': len(entries),
                  'size': archive.stat().st_size}))
