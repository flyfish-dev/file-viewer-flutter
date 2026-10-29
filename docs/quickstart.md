# Quick start

Add file previews to a Flutter screen. `FileViewerHost` owns application-scoped warm-up, `FileViewer` displays a document, and offline resources ship with your application.

## Before you begin

Use Flutter **3.47 or later** and Dart **3.13 or later**. The published release is `0.1.0-dev.1`, a development preview. See [platform setup](platforms.md) for the measured Android, iOS, Web, Windows, macOS and Linux scope. The pinned qualification toolchain is Flutter 3.47.4 / Dart 3.13.3.

Customer applications need Flutter tooling. They do not need Node.js or a JavaScript source build.

## 1. Install the package

Add the dependency to your application's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  file_viewer_flutter: 0.1.0-dev.1
```

```sh
flutter pub get
```

The entry package installs four matching offline asset packages and two first-party platform adapters. Keep your application's `pubspec.lock`; do not override an individual resource package to another version.

## 2. Configure your host

Run once from the customer application's root:

```sh
dart run file_viewer_flutter:setup --project . --check
dart run file_viewer_flutter:setup --project . --apply
```

`--check` previews the diff; only `--apply` writes changes. The command preserves existing settings and adds local-resource configuration and platform initialization for platform directories that exist in the application. Use `--platform android,ios` to select a subset. Web needs no configuration changes from this command.

Perform a full rebuild afterward. Hot reload does not apply native host changes. See [platform setup](platforms.md) for operating-system and build requirements.

## 3. Add a document

Place a PDF at `assets/example.pdf` and declare it in the same `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/example.pdf
```

You can also download the repository's [owned PDF fixture](https://raw.githubusercontent.com/flyfish-dev/file-viewer-flutter/main/example/assets/sample.pdf) to that path. Keep customer documents out of public repositories.

## 4. Display it

Place this complete example in `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

void main() {
  runApp(const FileViewerHost(child: PreviewApp()));
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Viewer Flutter',
      home: Scaffold(
        appBar: AppBar(title: const Text('File preview')),
        body: const FileViewer(
          source: FileViewerSource.asset('assets/example.pdf'),
        ),
      ),
    );
  }
}
```

```sh
flutter run
```

`Scaffold.body` gives the viewer a bounded layout. Use `Expanded` inside a `Column`, or give another parent an explicit size. Keep the application Host across preview routes.

## Continue integrating

- [Document sources](file-sources.md): bundled assets, native paths, bytes and authenticated URLs.
- [Warm-up and lifecycle](runtime.md): preloading, route reuse, concurrency and logout.
- [Controllers and events](controller.md): readiness, search, zoom, reload and recovery.
- [Offline delivery](deployment.md): Web assets, desktop engines, package size and licenses.

To run the complete example, clone the [independent repository](https://github.com/flyfish-dev/file-viewer-flutter), run `flutter pub get` in both the repository root and `example/`, then run the host setup command and `flutter run` from `example/`.
