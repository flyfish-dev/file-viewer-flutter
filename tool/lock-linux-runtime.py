#!/usr/bin/env python3
"""Freeze verified CEF minimal distributions for build-time/offline use."""
import concurrent.futures
import hashlib
import json
import pathlib
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
VERSION = '149.0.4+g2f1bfd8+chromium-149.0.7827.156'
index = json.load(urllib.request.urlopen('https://cef-builds.spotifycdn.com/index.json', timeout=60))
cache = ROOT / '.build' / 'native-archives'
cache.mkdir(parents=True, exist_ok=True)

def freeze(arch):
    release = next(item for item in index[arch]['versions'] if item['cef_version'] == VERSION)
    artifact = next(item for item in release['files'] if item['type'] == 'minimal')
    url = 'https://cef-builds.spotifycdn.com/' + urllib.parse.quote(artifact['name'])
    path = cache / artifact['name']
    if not path.exists() or path.stat().st_size != artifact['size']:
        temporary = path.with_suffix('.part')
        with urllib.request.urlopen(url, timeout=90) as response, temporary.open('wb') as output:
            total = 0
            previous = 0
            while chunk := response.read(1024 * 1024):
                output.write(chunk)
                total += len(chunk)
                if total - previous >= 64 * 1024 * 1024:
                    print(f'{arch}: {total // (1024 * 1024)} MiB downloaded', flush=True)
                    previous = total
        temporary.replace(path)
    sha1, sha256 = hashlib.sha1(), hashlib.sha256()
    with path.open('rb') as stream:
        while chunk := stream.read(1024 * 1024):
            sha1.update(chunk)
            sha256.update(chunk)
    if path.stat().st_size != artifact['size'] or sha1.hexdigest() != artifact['sha1']:
        raise RuntimeError(f'{arch}: archive does not match the public CEF index')
    print(f'{arch}: verified published SHA-1 and froze SHA-256 {sha256.hexdigest()}', flush=True)
    return arch, {'url': url, 'filename': artifact['name'], 'size': artifact['size'], 'sha256': sha256.hexdigest()}

with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
    artifacts = dict(executor.map(freeze, ['linux64', 'linuxarm64']))
target = ROOT / 'packages/file_viewer_flutter_linux/native-runtime-lock.json'
target.write_text(json.dumps({'schemaVersion': 1, 'cefVersion': VERSION, 'artifacts': artifacts}, indent=2) + '\n')
print(f'Wrote {target.relative_to(ROOT)}', flush=True)
