import 'package:flutter/foundation.dart';

/// How the resource host obtains a document's original bytes.
enum FileViewerSourceKind {
  /// A Flutter asset declared in the host application's pubspec.
  asset,

  /// A native filesystem path; unavailable in a browser.
  file,

  /// An immutable snapshot of bytes supplied by the application.
  bytes,

  /// An HTTP or HTTPS resource, optionally using request headers.
  url,
}

/// An immutable description of a document's source, name and media type.
///
/// Sources stay in Dart. Native paths and authorization headers are never sent
/// to the JavaScript bridge; the resource host exposes scoped document URLs.
@immutable
class FileViewerSource {
  /// Reads the Flutter asset at [location].
  ///
  /// Declare the asset in the application's pubspec. [name] overrides its
  /// display name and extension, and [mimeType] overrides media-type detection.
  const FileViewerSource.asset(this.location, {this.name, this.mimeType})
    : kind = FileViewerSourceKind.asset,
      data = null,
      headers = const {};

  /// Reads an existing native filesystem path at [location].
  ///
  /// This source is unavailable on Web. The application remains responsible
  /// for selecting the file and obtaining platform filesystem access.
  const FileViewerSource.file(this.location, {this.name, this.mimeType})
    : kind = FileViewerSourceKind.file,
      data = null,
      headers = const {};

  /// Copies [bytes] into an immutable snapshot with the supplied [name].
  ///
  /// Include a file extension in [name] so the renderer can detect the format.
  /// Reuse the same source instance to reuse a retained byte-backed session.
  FileViewerSource.bytes(Uint8List bytes, {required this.name, this.mimeType})
    : kind = FileViewerSourceKind.bytes,
      location = '',
      data = Uint8List.fromList(bytes).asUnmodifiableView(),
      headers = const {};

  /// Fetches an HTTP(S) [url], optionally using [headers].
  ///
  /// Throws [ArgumentError] for other URI schemes. Browser requests remain
  /// subject to CORS. Native redirects to another origin drop these headers.
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

  /// Mechanism used to obtain the source bytes.
  final FileViewerSourceKind kind;

  /// Asset key, native path or HTTP(S) URL; empty for a byte-backed source.
  final String location;

  /// Optional display-name override, including the document's extension.
  final String? name;

  /// Optional media-type override supplied to the renderer.
  final String? mimeType;

  /// Immutable byte snapshot, present only for [FileViewerSourceKind.bytes].
  final Uint8List? data;

  /// Immutable HTTP request headers; empty for non-URL sources.
  final Map<String, String> headers;

  /// Sanitized basename derived from [name], URL path or native location.
  ///
  /// Directory components are removed. Falls back to `document` when no name
  /// can be derived; supplying an extension improves format detection.
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
