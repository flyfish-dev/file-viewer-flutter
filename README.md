# File Viewer Flutter

An offline Flutter document viewer, backed by the public [File Viewer](https://github.com/flyfish-dev/file-viewer) rendering core. This repository contains the Flutter API, lifecycle management, packaged web resources, native adapters and a runnable example.

**Development preview: `0.1.0-dev.1`.** Android, iOS, Web, Windows, macOS and Linux are the delivery targets. A target is supported only after its native build, document rendering and lifecycle tests pass. See [the qualification matrix](docs/qualification.md); platform declarations alone are not test evidence.

## Integrate

Until the package family is published on pub.dev, use a complete local SDK bundle. A checkout uses the included dependency overrides for development:

For a delivered SDK archive, extract it next to your application and add this dependency; the archive rewrites all internal resource dependencies to local paths:

```yaml
dependencies:
  file_viewer_flutter:
    path: ../file_viewer_flutter-0.1.0-dev.1
```

For repository development:

```sh
git clone https://github.com/flyfish-dev/file-viewer-flutter.git
cd file-viewer-flutter
flutter pub get
cd example
flutter pub get
dart run file_viewer_flutter:setup --project . --apply
flutter run
```

Configure the application once with the setup command. `--check` prints proposed changes without writing. The command preserves existing application settings and adds only the local networking and platform initialization needed by the selected platforms.

At the application root, one line starts application-scoped prewarming after the first Flutter frame:

```dart
runApp(FileViewerHost(child: MyApp()));
```

In a bounded layout, one line displays a document:

```dart
FileViewer(source: FileViewerSource.asset('assets/example.pdf'))
```

Import `package:file_viewer_flutter/file_viewer_flutter.dart`. Declare your own asset documents in your application's `pubspec.yaml`. Native file paths, in-memory bytes and HTTP(S) URLs are also available through `FileViewerSource.file`, `.bytes` and `.url`. Web cannot open arbitrary native paths; use bytes from the browser file picker.

## Warm up and reuse

The host keeps one spare viewer. Leaving a preview route retains its engine and document; opening the same source reuses that session. Simultaneous previews receive separate native views. Memory pressure releases idle viewers. Backgrounding pauses work; the operating system may suspend or reclaim the process. Returning to the foreground resumes the session or recreates a terminated renderer.

`warmUp()` initializes the shell and common parser modules. It does not claim that every Worker, WASM engine, font or document is already parsed. To parse a known upcoming document before navigation:

```dart
await FileViewerRuntime.instance.preload(source);
```

Use a controller for search, zoom, fit, view state, capabilities, reload and close. Call `clearSessions()` on logout to remove active documents and idle previews. Call `shutdown()` when disposing an explicitly owned runtime. Remote authorization headers remain in Dart and are sent by the local resource proxy; they are not included in JavaScript messages.

## Offline distribution

All rendering resources come from the pinned public File Viewer `3.3.0` distribution. The four asset packages are version locked and installed together: base, CAD, drawing and Typst. The current resources total approximately 225 MiB before application compression. Customer applications need Flutter tooling; Node.js is a maintainer build dependency only.

Android, iOS and macOS use the installed system WebView. Windows bundles a checksum-locked WebView2 Fixed Version runtime. Linux bundles a checksum-locked CEF runtime with its sandbox enabled. These desktop engines increase the installed application size. Build machines need the locked archives or a prepopulated cache; runtime use does not download engines. Set `FILE_VIEWER_OFFLINE_BUILD=1` to fail a desktop build when its archive cache is missing.

Rendering is local. A remote source, an embedded remote image/link, browser policy, installed system WebView version or an unsupported document codec can still affect a particular file. Validate your required file corpus and devices before production adoption. Print/download/browser-export controls are hidden in this preview while host-native output integration is being qualified.

## Development

The pinned toolchain is Flutter `3.47.4` and Dart `3.13.3` (`.fvmrc`).

The native adapters are pinned to the compatible InAppWebView `1.2.0-beta.3` family (Windows `0.7.0-beta.3`), including the Android AGP 9 fix. The SDK uses the federated platform APIs directly and does not install an unused second Linux engine. This prerelease dependency is another reason to keep the SDK at development-preview status.

```sh
flutter pub get
flutter analyze
flutter test
cd runtime
npm ci
node --test test/*.test.mjs
cd ..
node tool/build-runtime.mjs
```

Run `example/integration_test/viewer_test.dart` on actual platform WebViews. `tool/verify-web.mjs` tests a built Flutter Web application in Chrome with external HTTP requests blocked. Generated evidence and screenshots stay under `.release/` and are excluded from source control. [Architecture and release gates](docs/architecture.md) describe resource routing, lifecycle, security boundaries and remaining qualification work.

## Licenses

The adapter uses Apache-2.0. Keep the upstream resource license ledgers, notices and source offers included in every asset package. Linux also retains the original `webview_cef` and CEF notices. The legacy PPT renderer's watermark is preserved. Native engine distributions carry their own license terms; include the complete bundled runtime directories when distributing an application.
