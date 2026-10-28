#!/usr/bin/env python3
"""Reproduce the reviewed, Linux-only CEF adapter from a public pub archive.

Retain upstream attribution, exclude its other native platforms, and prevent
its CMake build from silently patching the host application's runner sources.
"""
import hashlib
import io
import json
import pathlib
import tarfile
import urllib.request
from linux_patches import harden

ROOT = pathlib.Path(__file__).resolve().parent.parent
NAME = 'file_viewer_flutter_linux'
VERSION = '0.6.2'
EXPECTED_SHA256 = '1e028859e6fe4f52a82349a0acaa6594c1bd8317738df5764fd4365d6aebf6cc'
API = f'https://pub.dev/api/packages/webview_cef/versions/{VERSION}'
metadata = json.load(urllib.request.urlopen(API, timeout=30))
archive = urllib.request.urlopen(metadata['archive_url'], timeout=60).read()
digest = hashlib.sha256(archive).hexdigest()
if digest != metadata['archive_sha256'] or digest != EXPECTED_SHA256:
    raise RuntimeError('Upstream pub archive SHA-256 does not match the registry.')
destination = ROOT / 'packages' / NAME
destination.mkdir(parents=True, exist_ok=True)
with tarfile.open(fileobj=io.BytesIO(archive), mode='r:gz') as source:
    for member in source.getmembers():
        path = pathlib.PurePosixPath(member.name)
        if path.is_absolute() or '..' in path.parts:
            raise RuntimeError('Unsafe upstream archive path.')
        if not member.isfile() or not (path.parts[0] in {'lib', 'linux', 'common', 'third'} or member.name == 'LICENSE'):
            continue
        if path.parts[0] == 'third' and member.name != 'third/download.cmake':
            continue
        data = source.extractfile(member).read()
        output_name = member.name.replace('webview_cef', NAME)
        if member.name != 'LICENSE':
            text = data.decode('utf-8').replace('webview_cef', NAME).replace('WebviewCefPlugin', 'FileViewerFlutterLinuxPlugin')
            text = harden(member.name, text)
            if member.name == 'linux/CMakeLists.txt':
                start = text.index('# Auto setup Linux target')
                end = text.index('# Setup CEF', start)
                text = text[:start] + '''# Host changes are explicit and reviewed via the setup CLI.
if(NOT FILE_VIEWER_FLUTTER_LINUX_RUNNER_CONFIGURED)
  message(FATAL_ERROR "Run dart run file_viewer_flutter:setup --platform linux --apply before building the Linux adapter.")
endif()

''' + text[end:]
                text = text.replace('prepare_prebuilt_files(${CMAKE_CURRENT_SOURCE_DIR}/../third/cef)',
                    'set(FILE_VIEWER_CEF_ROOT "${CMAKE_BINARY_DIR}/file_viewer_flutter_cef/${CMAKE_SYSTEM_PROCESSOR}")\nprepare_prebuilt_files("${FILE_VIEWER_CEF_ROOT}")')
                text = text.replace('set(CEF_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../third/cef")',
                    'set(CEF_ROOT "${FILE_VIEWER_CEF_ROOT}")')
            if member.name == 'third/download.cmake':
                # Use the audited replacement, not upstream's unchecked download.
                continue
            data = text.encode('utf-8')
        target = destination / output_name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
manifest = {'upstream': 'webview_cef', 'version': VERSION,
            'archive': metadata['archive_url'], 'sha256': digest,
            'changes': ['Linux-only platform registration and namespace',
                        'explicit host runner setup', 'verified runtime preparation',
                        'Dart 3.13 formal parameter compatibility',
                        'preserve web security and sandbox defaults',
                        'main-frame navigation and bridge restrictions',
                        'renderer process termination event',
                        'retained view state cleanup',
                        'CEF 149 frame token callback matching',
                        'minimal runtime Debug/Profile path mapping',
                        'bundle complete CEF and Chromium notices',
                        'install the CEF sandbox helper as an executable']}
(destination / 'UPSTREAM.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(f'Vendored webview_cef {VERSION} Linux sources; verified SHA-256 {digest}')

