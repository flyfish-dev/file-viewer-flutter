#!/usr/bin/env python3
"""Require full Pana points for an exact, Dart-validated publication archive."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tarfile
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('archive', type=Path)
parser.add_argument('--flutter', default='flutter')
parser.add_argument('--report', type=Path,
                    default=Path('.release/pub-score/pana.json'))
args = parser.parse_args()
flutter = shutil.which(args.flutter)
if flutter is None:
    raise RuntimeError('Flutter was not found; pass --flutter /path/to/flutter.')
flutter = Path(flutter).resolve()
dart = flutter.with_name('dart')
installed = subprocess.check_output(
    [str(dart), 'pub', 'global', 'list'], text=True).splitlines()
if 'pana 0.23.19' not in installed:
    raise RuntimeError('Install the pinned scorer: dart pub global activate pana 0.23.19')
archive = args.archive.resolve(strict=True)
report = args.report.resolve()
report.parent.mkdir(parents=True, exist_ok=True)

with tempfile.TemporaryDirectory(prefix='file-viewer-score-') as temporary:
    package = Path(temporary)
    with tarfile.open(archive) as bundle:
        for member in bundle:
            path = PurePosixPath(member.name)
            if (path.is_absolute() or '..' in path.parts or
                    not (member.isfile() or member.isdir()) or
                    any(part in {'.git', '.dart_tool', 'pubspec_overrides.yaml'}
                        for part in path.parts)):
                raise RuntimeError(f'Unsafe or development-only archive entry: {path}')
            target = package / member.name
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(bundle.extractfile(member).read())
    if not (package / 'pubspec.yaml').is_file():
        raise RuntimeError('The archive does not contain a root pubspec.yaml.')
    print('Scoring the validated archive with Pana and dartdoc.', flush=True)
    with report.open('w') as output, report.with_suffix('.log').open('w') as log:
        result = subprocess.run([
            str(dart), 'pub', 'global', 'run', 'pana',
            '--flutter-sdk', str(flutter.parent.parent),
            '--exit-code-threshold', '0', '--json', str(package),
        ], stdout=output, stderr=log,
            env={**os.environ, 'PATH': str(flutter.parent) + os.pathsep + os.environ.get('PATH', '')})

try:
    analysis = json.loads(report.read_text())
except (ValueError, FileNotFoundError) as error:
    raise RuntimeError(f'Pana did not return a report; inspect {report.with_suffix(".log")}') from error
scores = analysis.get('scores', {})
granted, maximum = scores.get('grantedPoints'), scores.get('maxPoints')
full_score = isinstance(maximum, int) and maximum > 0 and granted == maximum
receipt = {
    'archive': str(archive),
    'archiveSha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
    'panaVersion': '0.23.19',
    'scores': scores,
    'passed': result.returncode == 0 and full_score,
}
report.with_suffix('.receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps(receipt), flush=True)
if not receipt['passed']:
    for section in analysis.get('report', {}).get('sections', []):
        if section.get('grantedPoints') != section.get('maxPoints'):
            print(section.get('title', 'Pana section'))
            print(section.get('summary', ''))
raise SystemExit(0 if receipt['passed'] else 1)
