#!/usr/bin/env python3
"""Upload a Dart-validated archive through pub.dev's official HTTP/2 flow.

Protocol: dart-lang/pub lib/src/command/lish.dart. Credentials stay in memory;
only pub.dev receives the OAuth token. Google Storage receives signed form
fields from pub.dev. Generate archives with `dart pub publish --to-archive`.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile
import urllib.error
import urllib.request
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / '.release/pub-release'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('package')
parser.add_argument('archive', type=Path)
parser.add_argument('--proxy', help='Use an existing local HTTP proxy without changing system settings.')
args = parser.parse_args()
release = json.loads((OUTPUT / 'staging.json').read_text())
allowed = {'file_viewer_flutter', 'file_viewer_flutter_assets',
           'file_viewer_flutter_assets_cad', 'file_viewer_flutter_assets_drawing',
           'file_viewer_flutter_assets_typst', 'file_viewer_flutter_linux',
           'file_viewer_flutter_macos'}
if args.package not in allowed or release['publisher'] != 'flyfish.dev':
    raise RuntimeError('The requested package or publisher is outside this release.')
staging = Path(release['directory']) / args.package
archive = args.archive.resolve(strict=True)
archive_hash = hashlib.sha256(archive.read_bytes()).hexdigest()
with tarfile.open(archive) as package:
    names = []
    for member in package:
        path = PurePosixPath(member.name)
        if path.is_absolute() or '..' in path.parts or member.issym() or member.islnk():
            raise RuntimeError('Unsafe archive entry.')
        if member.isfile():
            original = staging / member.name
            data = package.extractfile(member).read()
            if not original.is_file() or original.read_bytes() != data:
                raise RuntimeError(f'Archive differs from validated staging: {member.name}')
            names.append(member.name)
    if 'pubspec.yaml' not in names or 'LICENSE' not in names:
        raise RuntimeError('The archive is missing release metadata or its license.')
spec = (staging / 'pubspec.yaml').read_text()
if f'name: {args.package}\n' not in spec or f'version: {release["version"]}\n' not in spec:
    raise RuntimeError('Unexpected package identity or version.')
version_url = f'https://pub.dev/api/packages/{args.package}/versions/{release["version"]}'
try:
    urllib.request.urlopen(version_url, timeout=30).close()
except urllib.error.HTTPError as error:
    if error.code != 404:
        raise
else:
    raise RuntimeError('This version is already published; verify it instead of uploading again.')

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *unused, **kwargs):
        return None

credentials = next((p for p in [
    Path.home() / 'Library/Application Support/dart/pub-credentials.json',
    Path.home() / '.config/dart/pub-credentials.json',
    Path.home() / '.pub-cache/credentials.json',
] if p.exists()), None)
if credentials is None:
    raise RuntimeError('Log in using the official Dart pub client first.')
client = urllib.request.build_opener(NoRedirect())

def pub_request(url):
    parsed = urlsplit(url)
    if parsed.scheme != 'https' or parsed.netloc != 'pub.dev':
        raise RuntimeError('Refusing to send pub credentials to another origin.')
    request = urllib.request.Request(url, headers={
        'Authorization': 'Bearer ' + json.loads(credentials.read_text())['accessToken'],
        'Accept': 'application/vnd.pub.v2+json',
        'Content-Type': 'application/json',
        'User-Agent': 'file-viewer-flutter-release/0.1.0-dev.1',
    })
    with client.open(request, timeout=60) as response:
        return json.load(response)

parameters = pub_request('https://pub.dev/api/packages/versions/new')
target = urlsplit(parameters['url'])
if target.scheme != 'https' or not (target.netloc == 'storage.googleapis.com' or
                                   target.netloc.endswith('.storage.googleapis.com')):
    raise RuntimeError('Unexpected pub.dev storage upload origin.')
upload_url = parameters['url']
headers = OUTPUT / f'{args.package}.upload-headers'
body = OUTPUT / f'{args.package}.upload-response'
quote = lambda value: json.dumps(str(value), ensure_ascii=False)
configuration = [
    'url = ' + quote(upload_url), 'http2', 'silent', 'show-error',
    'connect-timeout = 30', 'max-time = 7200',
    'dump-header = ' + quote(headers), 'output = ' + quote(body),
    'write-out = "%{http_code} %{speed_upload}\\n"',
]
if args.proxy:
    proxy = urlsplit(args.proxy)
    if proxy.scheme != 'http' or proxy.hostname not in {'127.0.0.1', 'localhost'} or not proxy.port:
        raise RuntimeError('Only an explicitly configured loopback HTTP proxy is accepted.')
    configuration.append('proxy = ' + quote(args.proxy))
for key, value in parameters['fields'].items():
    if not isinstance(key, str) or not isinstance(value, str):
        raise RuntimeError('Unexpected storage upload field type.')
    configuration.append('form-string = ' + quote(f'{key}={value}'))
configuration.append('form = ' + quote(f'file=@{archive};filename=package.tar.gz;type=application/octet-stream'))
print(json.dumps({'package': args.package, 'phase': 'uploading',
                  'archiveBytes': archive.stat().st_size, 'sha256': archive_hash,
                  'storageHost': urlsplit(upload_url).hostname}), flush=True)
upload = subprocess.run(['curl', '--no-insecure', '--config', '-'],
                        input='\n'.join(configuration) + '\n', text=True,
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
if upload.returncode:
    raise RuntimeError(f'Package transfer failed with curl exit {upload.returncode}.')
locations = [line.split(':', 1)[1].strip() for line in headers.read_text().splitlines()
             if line.lower().startswith('location:')]
if not locations:
    raise RuntimeError(f'Upload returned no finalize URL; HTTP result: {upload.stdout.strip()}')
result = pub_request(locations[-1])
if 'success' not in result:
    raise RuntimeError('pub.dev did not confirm successful publication.')
with urllib.request.urlopen(
        f'https://pub.dev/api/packages/{args.package}/versions/{release["version"]}',
        timeout=60) as response:
    published = json.load(response)
if published['archive_sha256'] != archive_hash:
    raise RuntimeError('The registry archive hash differs from the uploaded archive.')
publisher_url = f'https://pub.dev/api/packages/{args.package}/publisher'
ownership = pub_request(publisher_url)
# Publisher transfers require the authenticated pub.dev web administration
# session. The Dart client's upload credential does not grant that operation.
if ownership.get('publisherId') not in {None, release['publisher']}:
    raise RuntimeError('Unexpected package publisher.')
record = {'package': args.package, 'version': release['version'],
          'sourceCommit': release['sourceCommit'], 'archiveSha256': archive_hash,
          'filesVerified': len(names), 'registry': published,
          'publisherId': ownership.get('publisherId'),
          'publisherTransferRequired': ownership.get('publisherId') is None,
          'transferResult': upload.stdout.strip()}
(OUTPUT / f'{args.package}.published.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({'package': args.package, 'phase': 'published',
                  'version': release['version'], 'archiveSha256': archive_hash,
                  'publisherId': ownership.get('publisherId'),
                  'publisherTransferRequired': ownership.get('publisherId') is None,
                  'transfer': upload.stdout.strip()}), flush=True)
