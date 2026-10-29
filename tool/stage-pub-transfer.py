#!/usr/bin/env python3
"""Transfer a public source archive, without granting CI pub publishing access.

The release machine supplies only pub.dev's short-lived Google Storage form.
CI cannot finalize publication. Download the resulting archive, verify its
payload against validated local staging, then finalize on the release machine.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = 'file_viewer_flutter_assets'
VERSION = json.loads((ROOT / 'runtime/package.json').read_text())['version']
ticket = json.loads(os.environ.pop('PUB_UPLOAD_FORM'))
commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
if ticket.get('sourceCommit') != commit or ticket.get('package') != PACKAGE or ticket.get('version') != VERSION:
    raise RuntimeError('Storage ticket does not match this public source revision.')
parameters = ticket['upload']
if set(parameters) != {'url', 'fields'}:
    raise RuntimeError('Only a signed storage form may be supplied; no publishing credentials.')
target = urlsplit(parameters['url'])
if target.scheme != 'https' or not (target.netloc == 'storage.googleapis.com' or
                                   target.netloc.endswith('.storage.googleapis.com')):
    raise RuntimeError('Unexpected storage origin.')
fields = parameters['fields']
if set(fields) != {'key', 'Expires', 'GoogleAccessId', 'policy', 'signature', 'success_action_redirect'}:
    raise RuntimeError('Unexpected upload form fields.')
callback = urlsplit(fields['success_action_redirect'])
if callback.scheme != 'https' or callback.netloc != 'pub.dev':
    raise RuntimeError('Unexpected publication callback origin.')
output = ROOT / '.release/pub-transfer'
output.mkdir(parents=True, exist_ok=True)
archive = output / f'{PACKAGE}-{VERSION}.tar.gz'
with tempfile.TemporaryDirectory(prefix='pub-base-') as temporary:
    stage = Path(temporary) / PACKAGE
    shutil.copytree(ROOT / 'packages' / PACKAGE, stage,
                    ignore=shutil.ignore_patterns('.dart_tool', 'build', 'pubspec.lock', 'pubspec_overrides.yaml'))
    if any(path.is_symlink() for path in stage.rglob('*')):
        raise RuntimeError('Symlinks are not allowed in publication staging.')
    subprocess.run(['flutter', 'pub', 'publish', '--to-archive', str(archive)], cwd=stage, check=True)
quote = lambda value: json.dumps(str(value), ensure_ascii=False)
headers = Path(tempfile.mkstemp(prefix='pub-storage-headers-')[1])
body = Path(tempfile.mkstemp(prefix='pub-storage-response-')[1])
configuration = [
    'url = ' + quote(parameters['url']), 'http2', 'silent', 'show-error',
    'connect-timeout = 30', 'max-time = 600',
    'dump-header = ' + quote(headers), 'output = ' + quote(body),
    'write-out = "%{http_code} %{speed_upload}\\n"',
]
for key, value in fields.items():
    if not isinstance(key, str) or not isinstance(value, str):
        raise RuntimeError('Unexpected upload field type.')
    configuration.append('form-string = ' + quote(f'{key}={value}'))
configuration.append('form = ' + quote(f'file=@{archive};filename=package.tar.gz;type=application/octet-stream'))
upload = subprocess.run(['curl', '--no-insecure', '--config', '-'],
                        input='\n'.join(configuration) + '\n', text=True,
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
if upload.returncode:
    raise RuntimeError(f'Storage transfer failed with curl exit {upload.returncode}.')
locations = [line.split(':', 1)[1].strip() for line in headers.read_text().splitlines()
             if line.lower().startswith('location:')]
if not locations or not upload.stdout.startswith('303 '):
    raise RuntimeError('Storage did not acknowledge the archive transfer.')
finalize = urlsplit(locations[-1])
if finalize.scheme != 'https' or finalize.netloc != 'pub.dev':
    raise RuntimeError('Unexpected storage response callback.')
record = {'package': PACKAGE, 'version': VERSION, 'sourceCommit': commit,
          'archiveSha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
          'archiveBytes': archive.stat().st_size,
          'finalizeUrl': locations[-1], 'transferResult': upload.stdout.strip()}
(output / 'transfer.json').write_text(json.dumps(record, indent=2) + '\n')
headers.unlink()
body.unlink()
print(json.dumps({key: value for key, value in record.items() if key != 'finalizeUrl'}))
