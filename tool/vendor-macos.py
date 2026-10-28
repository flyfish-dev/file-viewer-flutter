#!/usr/bin/env python3
"""Reproduce the isolated WKWebView adapter from a checksum-locked pub archive."""
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
NAME = 'file_viewer_flutter_macos'
UPSTREAM = 'flutter_inappwebview_macos'
VERSION = '1.2.0-beta.3'
SHA256 = '545148cb5c46475ce669ab21621e9f2ad66e05f8e80b2cf49d4018879ab52393'
URL = f'https://pub.dev/api/archives/{UPSTREAM}-{VERSION}.tar.gz'
archive = urllib.request.urlopen(URL, timeout=60).read()
if hashlib.sha256(archive).hexdigest() != SHA256:
    raise RuntimeError('The macOS adapter archive SHA-256 does not match.')
destination = ROOT / 'packages' / NAME
destination.mkdir(parents=True, exist_ok=True)
with tarfile.open(fileobj=io.BytesIO(archive), mode='r:gz') as source:
    for member in source.getmembers():
        path = PurePosixPath(member.name)
        if path.is_absolute() or '..' in path.parts:
            raise RuntimeError('Unsafe upstream archive path.')
        if not member.isfile() or not (path.parts[0] in {'lib', 'macos'} or member.name in {'LICENSE', 'analysis_options.yaml'}):
            continue
        data = source.extractfile(member).read()
        output_name = member.name.replace(UPSTREAM, NAME).replace(
            'InAppWebViewFlutterPlugin', 'FileViewerFlutterMacosPlugin')
        if member.name != 'LICENSE':
            text = data.decode('utf-8').replace('\r\n', '\n')
            text = text.replace(UPSTREAM, NAME).replace(
                'flutter-inappwebview-macos', 'file-viewer-flutter-macos')
            text = text.replace('InAppWebViewFlutterPlugin', 'FileViewerFlutterMacosPlugin')
            # Isolate both platform-view IDs and native method/event channels.
            # Keep upstream's per-WebView JavaScript API names unchanged.
            text = text.replace('com.pichillilorenzo/flutter_', 'dev.flyfish/file_viewer_flutter_macos/')
            if member.name == 'analysis_options.yaml':
                text = text.replace('include: package:flutter_lints/flutter.yaml',
                    '# Preserve upstream analyzer diagnostics without restyling vendored sources.')
            if member.name.endswith('.podspec'):
                text = text.replace("s.version          = '0.0.1'", "s.version          = '0.1.0'")
                text = text.replace('A new Flutter plugin project.', 'Retained WKWebView adapter for File Viewer Flutter.')
                text = text.replace('http://example.com', 'https://github.com/flyfish-dev/file-viewer-flutter')
                text = text.replace("{ 'Your Company' => 'email@example.com' }",
                    "{ 'Flyfish Dev' => 'https://github.com/flyfish-dev' }")
            if member.name.endswith('/FlutterWebViewFactory.swift'):
                before = '        return flutterWebView!\n'
                if text.count(before) != 1:
                    raise RuntimeError('The upstream factory ownership context changed.')
                text = text.replace(before, '''        // Flutter can defer disposal of an old platform-view ID until a later
        // compositor frame. Never register the retained WKWebView's NSView under
        // two IDs: a delayed old-ID removal would detach the new attachment.
        // Each ID owns a fresh container; only its retained child moves.
        let container = NSView(frame: .zero)
        let retainedView = flutterWebView!
        retainedView.removeFromSuperview()
        retainedView.frame = container.bounds
        retainedView.autoresizingMask = [.width, .height]
        retainedView.translatesAutoresizingMaskIntoConstraints = true
        container.addSubview(retainedView)
        return container
''')
            data = text.encode('utf-8')
        target = destination / output_name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
manifest = {
    'upstream': UPSTREAM, 'version': VERSION, 'archive': URL, 'sha256': SHA256,
    'changes': [
        'Separate package, native plugin class, platform-view and channel namespaces',
        'Fresh NSView container for each Flutter platform-view ID',
        'Retain and reparent the warmed WKWebView inside that container',
        'Normalize generated source line endings; retain the original license bytes',
        'Package metadata and vendor-scoped analyzer options',
    ],
}
(destination / 'UPSTREAM.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(f'Vendored {UPSTREAM} {VERSION}; verified SHA-256 {SHA256}')
