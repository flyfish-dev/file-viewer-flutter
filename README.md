<p align="center">
  <a href="https://github.com/flyfish-dev/file-viewer">
    <img src="docs/assets/file-viewer.png" width="92" alt="File Viewer logo">
  </a>
</p>

<h1 align="center">File Viewer for Flutter</h1>

<p align="center">Offline document preview. One Flutter widget.</p>

<p align="center">
  <a href="https://pub.dev/packages/file_viewer_flutter"><img src="https://img.shields.io/pub/v/file_viewer_flutter?include_prereleases&label=pub.dev&color=0891b2" alt="pub.dev package"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%E2%89%A5%203.47-02569B?logo=flutter" alt="Flutter 3.47 or later"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-64748b" alt="Apache 2.0 license"></a>
</p>

<p align="center">
  <a href="https://flutter.file-viewer.app/en/">Website</a> ·
  <a href="https://flutter.file-viewer.app/en/docs/quickstart/">Documentation</a> ·
  <a href="https://pub.dev/packages/file_viewer_flutter">pub.dev</a> ·
  <a href="README.zh-CN.md">简体中文</a>
</p>

<h3 align="center"><a href="https://github.com/flyfish-dev/file-viewer">File Viewer · Main repository ↗</a></h3>

File Viewer for Flutter brings the [File Viewer](https://github.com/flyfish-dev/file-viewer) rendering core to Flutter applications. This repository maintains the Flutter widget, controllers, application lifecycle, native WebView adapters and packaged offline resources. The main repository maintains the shared rendering engines and browser integrations.

> **Development preview — `0.1.0-dev.1`.** The delivery targets are Android, iOS, Web, Windows, macOS and Linux. Build and fixture evidence is recorded in the [qualification matrix](docs/qualification.md); production adoption requires validation against your devices and document corpus.

## Why File Viewer for Flutter

- **A consistent Flutter API** for asset files, local paths, in-memory bytes and authenticated HTTP(S) sources.
- **Local rendering and bundled resources**, without a public CDN, remote preview service or runtime engine download.
- **Application-scoped prewarming** and reusable sessions to reduce repeated initialization when opening previews.
- **Format-aware layout**, with automatic fitting, zoom, search, view-state restoration and controller capability queries.
- **Native platform integration**, using system WebViews on Android, iOS and macOS, bundled WebView2 on Windows and bundled CEF on Linux.

## Quick start

Requires Flutter **3.47+** and Dart **3.13+**. The pinned development toolchain is Flutter `3.47.4` / Dart `3.13.3`.

### 1. Add the package

```yaml
dependencies:
  file_viewer_flutter: 0.1.0-dev.1
```

From your application directory, install dependencies and configure the native host:

```sh
flutter pub get
dart run file_viewer_flutter:setup --project . --check
dart run file_viewer_flutter:setup --project . --apply
```

`--check` previews the required changes; `--apply` writes them while preserving existing application settings. Flutter Web does not require native host configuration. Rebuild the application after applying native changes.

### 2. Add a document

Place a PDF at `assets/example.pdf` and declare it in the application's `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/example.pdf
```

### 3. Display it

```dart
import 'package:flutter/material.dart';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

void main() {
  runApp(const FileViewerHost(
    child: MaterialApp(
      home: Scaffold(
        body: FileViewer(
          source: FileViewerSource.asset('assets/example.pdf'),
        ),
      ),
    ),
  ));
}
```

`FileViewerHost` begins prewarming after the first Flutter frame. `Scaffold.body` provides a bounded viewport; use `Expanded` or explicit dimensions when embedding the viewer in another layout.

Continue with the [full integration guide](https://flutter.file-viewer.app/en/docs/quickstart/).

## Developer guides

| Guide | Covers |
| --- | --- |
| [Platform setup](https://flutter.file-viewer.app/en/docs/platforms/) | Android, iOS, Web, Windows, macOS and Linux configuration |
| [File sources](https://flutter.file-viewer.app/en/docs/file-sources/) | Assets, native paths, bytes, remote URLs and authorization |
| [Prewarming and lifecycle](https://flutter.file-viewer.app/en/docs/runtime/) | Session reuse, preloading, backgrounding and memory pressure |
| [Controllers and events](https://flutter.file-viewer.app/en/docs/controller/) | Readiness, search, fit, zoom, view state and errors |
| [Offline deployment](https://flutter.file-viewer.app/en/docs/deployment/) | Resource packages, desktop engines and local SDK delivery |

The same guides are available in [简体中文](https://flutter.file-viewer.app/zh/docs/quickstart/).

## Lifecycle and layout

Use one `FileViewerHost` at the application root. It keeps one spare viewer; a retained session can reuse its native engine and document after leaving and reopening a preview. Simultaneous previews use separate native views. Memory pressure releases idle instances.

The default automatic fit delegates layout to each shared renderer: documents fit their reading viewport, presentations fit their canvas, and spreadsheets shrink to fit without automatically enlarging a small sheet. Manual zoom is preserved during later viewport changes. Use a `FileViewerController` for explicit automatic, width, page or actual-size fitting and other available operations.

Prewarming initializes the shell and common parser modules. To prepare a specific upcoming document, call `FileViewerRuntime.instance.preload(source)`. Shell readiness, parser warm-up and actual visible content are separate states.

Backgrounding pauses audio/video. The WebView and operating system may suspend or reclaim the process; this SDK does not install a permanent background service. Foregrounding requests layout refresh, and renderer termination triggers a recovery attempt. Media does not resume automatically. Clear sessions on logout with `clearSessions()`.

## Platform and distribution notes

| Target | Rendering surface | Distribution |
| --- | --- | --- |
| Android | System WebView | Bundled viewer resources |
| iOS | WKWebView | Bundled viewer resources |
| Web | Browser | Self-hosted application and viewer resources |
| macOS | Retained WKWebView | Bundled viewer resources |
| Windows | WebView2 | Checksum-locked Fixed Version runtime |
| Linux | CEF | Checksum-locked runtime with sandbox enabled |

All rendering resources come from the immutable public File Viewer `3.3.0` distribution. Four version-locked asset packages—base, CAD, drawing and Typst—are installed together, totaling approximately **225 MiB before application compression**. Bundled Windows and Linux engines add to the installed size. Customer applications need Flutter tooling; Node.js is only required for maintainer builds.

Build machines need the locked desktop archives or a populated archive cache. Set `FILE_VIEWER_OFFLINE_BUILD=1` to fail a desktop build when its cache is missing. Runtime use does not download native engines. Remote documents, embedded external resources, codecs and system WebView versions can still affect individual files.

Print, download and browser-export controls remain hidden in this preview while native output integration is being qualified. See the [qualification matrix](docs/qualification.md) for measured scope and remaining release requirements.

## Run the example

```sh
git clone https://github.com/flyfish-dev/file-viewer-flutter.git
cd file-viewer-flutter
flutter pub get
cd example
flutter pub get
dart run file_viewer_flutter:setup --project . --apply
flutter run
```

The example includes offline PDF, Word, Excel, PowerPoint and text fixtures. Its responsive workspace provides a document sidebar in wide windows and a document selector in compact layouts.

For a local SDK delivery, follow [offline deployment](https://flutter.file-viewer.app/en/docs/deployment/). Repository dependency overrides are for development; delivered SDK bundles rewrite internal dependencies to local paths.

## Contributing

```sh
flutter analyze
flutter test
cd runtime
npm ci
npm test
cd ..
node tool/build-runtime.mjs
python3 tool/check-pub.py
```

Run affected integration tests against actual platform WebViews. Keep generated evidence in `.release/`; never commit customer documents, credentials or signing material. See [architecture and release gates](docs/architecture.md) and the [delivery plan](docs/delivery-plan.zh-CN.md) for ownership and validation requirements.

Rendering fixes belong in the shared [File Viewer main repository](https://github.com/flyfish-dev/file-viewer). Flutter API and native integration issues belong in [this repository](https://github.com/flyfish-dev/file-viewer-flutter/issues).

## License and attribution

The Flutter adapter is licensed under [Apache-2.0](LICENSE). Asset and native engine distributions retain their own licenses, notices and source offers; preserve those files when redistributing an application. The macOS adapter retains its InAppWebView provenance, and the Linux adapter retains its `webview_cef` and CEF notices. The legacy PPT renderer's built-in watermark is preserved.

The logo is the File Viewer project brand, reused from the [main repository](https://github.com/flyfish-dev/file-viewer).
