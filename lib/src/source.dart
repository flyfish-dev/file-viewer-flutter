import 'package:flutter/foundation.dart';

enum FileViewerSourceKind { asset, file, bytes, url }

/// Sources stay in Dart. Native paths and authorization headers are never sent
/// to the JavaScript bridge; the resource host exposes scoped document URLs.
@immutable
class FileViewerSource {
  const FileViewerSource.asset(this.location, {this.name, this.mimeType})
    : kind = FileViewerSourceKind.asset,
      data = null,
      headers = const {};

  const FileViewerSource.file(this.location, {this.name, this.mimeType})
    : kind = FileViewerSourceKind.file,
      data = null,
      headers = const {};

  FileViewerSource.bytes(Uint8List bytes, {required this.name, this.mimeType})
    : kind = FileViewerSourceKind.bytes,
      location = '',
      data = Uint8List.fromList(bytes).asUnmodifiableView(),
      headers = const {};

  FileViewerSource.url(
    Uri url, {
    this.name,
    this.mimeType,
    Map<String, String> headers = const {},
  }) : kind = FileViewerSourceKind.url,
       location = url.toString(),
       data = null,
       headers = Map.unmodifiable(headers) {
    if (url.scheme != 'https' && url.scheme != 'http') {
      throw ArgumentError.value(url, 'url', 'Expected an HTTP(S) URL');
    }
  }

  final FileViewerSourceKind kind;
  final String location;
  final String? name;
  final String? mimeType;
  final Uint8List? data;
  final Map<String, String> headers;

  String get filename {
    String basename(String value) =>
        value
            .replaceAll(String.fromCharCode(92), '/')
            .split('/')
            .where((part) => part.isNotEmpty)
            .lastOrNull ??
        'document';
    if (name?.isNotEmpty == true) return basename(name!);
    if (kind == FileViewerSourceKind.url || location.startsWith('file:')) {
      return basename(
        Uri.tryParse(location)?.pathSegments.lastOrNull ?? 'document',
      );
    }
    return basename(location);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileViewerSource &&
          kind == other.kind &&
          location == other.location &&
          name == other.name &&
          mimeType == other.mimeType &&
          identical(data, other.data) &&
          mapEquals(headers, other.headers);

  @override
  int get hashCode => Object.hash(
    kind,
    location,
    name,
    mimeType,
    identityHashCode(data),
    Object.hashAllUnordered(
      headers.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}
