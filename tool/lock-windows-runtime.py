#!/usr/bin/env python3
"""Freeze Microsoft's official Fixed Version WebView2 runtime for each target."""
import concurrent.futures
import hashlib
import json
import pathlib
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
API = 'https://developer.microsoft.com/microsoft-edge/api/webview2'
releases = json.load(urllib.request.urlopen(API, timeout=45))
release = releases[0]
cache = ROOT / '.build' / 'native-archives'
cache.mkdir(parents=True, exist_ok=True)

def freeze(arch):
    build = next(item for item in release['builds'] if item['architecture'] == arch)
    url = build['url']
    if not url.startswith('https://msedge.sf.dl.delivery.mp.microsoft.com/'):
        raise RuntimeError('Unexpected Microsoft runtime download origin.')
    filename = url.rsplit('/', 1)[-1]
    path = cache / filename
    if not path.exists():
        temporary = path.with_suffix('.part')
        with urllib.request.urlopen(url, timeout=90) as response, temporary.open('wb') as output:
            total, previous = 0, 0
            while chunk := response.read(1024 * 1024):
                output.write(chunk)
                total += len(chunk)
                if total - previous >= 64 * 1024 * 1024:
                    print(f'windows-{arch}: {total // (1024 * 1024)} MiB downloaded', flush=True)
                    previous = total
        temporary.replace(path)
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        if stream.read(4) != b'MSCF':
            raise RuntimeError('Expected a Microsoft Cabinet archive.')
        stream.seek(0)
        while chunk := stream.read(1024 * 1024): digest.update(chunk)
    print(f'windows-{arch}: froze SHA-256 {digest.hexdigest()}', flush=True)
    return arch, {'url': url, 'filename': filename, 'size': path.stat().st_size, 'sha256': digest.hexdigest()}

with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
    artifacts = dict(executor.map(freeze, ['x64', 'arm64']))
target = ROOT / 'windows/native-runtime-lock.json'
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(json.dumps({'schemaVersion': 1, 'version': release['version'], 'source': API, 'artifacts': artifacts}, indent=2) + '\n')
print(f'Wrote {target.relative_to(ROOT)}', flush=True)
