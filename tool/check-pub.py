#!/usr/bin/env python3
"""Validate isolated pub packages; ancestor monorepo ignores must not hide them."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--flutter', default='flutter')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
output = root / '.release' / 'pub-dry-run'
output.mkdir(parents=True, exist_ok=True)
packages = sorted((root / 'packages').glob('file_viewer_flutter_*'))
skip = shutil.ignore_patterns('.dart_tool', 'build', 'pubspec.lock',
                              'pubspec_overrides.yaml', '.git', '__pycache__')
results = []
with tempfile.TemporaryDirectory(prefix='file-viewer-pub-') as temporary:
    staging = Path(temporary)
    for package in packages:
        shutil.copytree(package, staging / package.name, ignore=skip, symlinks=True)
    main = staging / 'file_viewer_flutter'
    main.mkdir()
    for name in ['lib', 'bin', 'windows', 'docs']:
        shutil.copytree(root / name, main / name, ignore=skip, symlinks=True)
    for name in ['pubspec.yaml', '.pubignore', 'README.md', 'CHANGELOG.md', 'LICENSE']:
        shutil.copy2(root / name, main / name)
    (main / 'example').mkdir()
    for name in ['lib', 'assets']:
        shutil.copytree(root / 'example' / name, main / 'example' / name, symlinks=True)
    shutil.copy2(root / 'example/pubspec.yaml', main / 'example/pubspec.yaml')
    # Resolve not-yet-published shards during validation only. This file is
    # explicitly excluded from the root package's published archive.
    overrides = 'dependency_overrides:\n' + ''.join(
        f'  {package.name}:\n    path: {staging / package.name}\n' for package in packages)
    (main / 'pubspec_overrides.yaml').write_text(overrides)
    for path in staging.rglob('*'):
        if path.is_symlink():
            raise RuntimeError(f'Refusing a symlink in publish staging: {path}')
    for package in [*(staging / package.name for package in packages), main]:
        logfile = output / f'{package.name}.log'
        with logfile.open('w') as log:
            result = subprocess.run([args.flutter, 'pub', 'publish', '--dry-run',
                                     '--ignore-warnings'], cwd=package,
                                    stdout=log, stderr=subprocess.STDOUT)
        lines = logfile.read_text().splitlines()
        record = {'package': package.name, 'exitCode': result.returncode,
                  'summary': lines[-6:]}
        results.append(record)
        print(json.dumps(record), flush=True)
(output / 'CURRENT.json').write_text(json.dumps(results, indent=2) + '\n')
raise SystemExit(any(result['exitCode'] for result in results))
