# Document sources

Use the same `FileViewer` widget for application assets, native files, bytes or HTTP(S) documents. Sources stay in Dart; native paths and authorization headers are not placed in JavaScript bridge messages.

## Application assets

```dart
const source = FileViewerSource.asset('assets/example.pdf');
```

Declare the file in your application's `pubspec.yaml`. This is the most direct offline integration check; see the complete [quick start](quickstart.md).

## Native file paths

```dart
const source = FileViewerSource.file(
  '/path/to/report.docx',
  name: 'report.docx',
);
```

Your application owns file selection and OS authorization. Pass a path the app can access. Browsers cannot use arbitrary native paths; protected files on platforms such as iOS still require valid application-level access.

## In-memory bytes

```dart
import 'dart:typed_data';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

FileViewer fromBytes(Uint8List bytes) {
  final source = FileViewerSource.bytes(bytes, name: 'report.xlsx');
  return FileViewer(source: source);
}
```

`name` is required. Give it the actual extension and, when needed, a `mimeType`. The constructor copies and protects the byte data. Prefer a native file or URL for large documents to avoid another memory copy.

Byte-source matching depends on the identity of the byte object. Retain and reuse the same `FileViewerSource` when revisiting a document; do not copy a large byte array on every `build()`.

## HTTP(S) URLs

```dart
final source = FileViewerSource.url(
  Uri.parse('https://your-api.example/documents/123'),
  name: 'contract.pdf',
  headers: {'Authorization': 'Bearer <your-session-token>'},
);
```

The URL and token are placeholders; replace them with your endpoint and session credentials. This constructor accepts a `Uri` and allows HTTP or HTTPS only. Set `name` when the endpoint has no extension; `mimeType` is also available.

On native targets, the resource layer fetches remote content and keeps caller headers in Dart. Cross-origin redirects strip those headers and HTTPS downgrades are rejected. Web fetching remains subject to browser CORS; configure your backend accordingly.

Bundled offline assets do not make a remote document available without a network. For offline remote files, let your application own downloads, encrypted storage/cache policy and access checks, then supply a file or byte source.

## Change the document

Update the widget's `source`, or use a ready controller:

```dart
await controller.load(nextSource);
```

Load generations isolate stale responses during rapid document changes. See [controllers and events](controller.md) for readiness, error handling and reload behavior.
