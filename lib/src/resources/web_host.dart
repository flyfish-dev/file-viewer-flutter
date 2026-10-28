import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../models.dart';
import '../source.dart';
import 'manifest.dart';
import 'resource_host.dart';

ViewerResourceHost createResourceHost() => WebViewerResourceHost();

class WebViewerResourceHost implements ViewerResourceHost {
  final _manifest = ViewerAssetManifest();
  final _objectUrls = <String, String>{};
  final _base = Uri.parse(web.document.baseURI);
  bool _disposed = false;

  @override
  Future<void> initialize() => _manifest.load();

  @override
  Uri get shellUri => Uri.parse(assetBases['base']!).resolve('index.html');

  @override
  Map<String, String> get assetBases => {
    for (final pack in viewerAssetPackages.entries)
      pack.key: _base
          .resolve('assets/packages/${pack.value}/assets/')
          .toString(),
  };

  @override
  Future<Map<String, Object?>> registerSource(
    String id,
    FileViewerSource source,
  ) async {
    if (_disposed) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Resource host is disposed.',
      );
    }
    String url;
    switch (source.kind) {
      case FileViewerSourceKind.file:
        throw const FileViewerException(
          FileViewerErrorCode.unsupportedSource,
          'Browsers cannot read native paths. Use FileViewerSource.bytes with a selected file.',
        );
      case FileViewerSourceKind.asset:
        url = _base.resolve('assets/${source.location}').toString();
      case FileViewerSourceKind.bytes:
        url = web.URL.createObjectURL(
          web.Blob(
            [source.data!.toJS].toJS,
            web.BlobPropertyBag(
              type: source.mimeType ?? 'application/octet-stream',
            ),
          ),
        );
        _objectUrls[id] = url;
      case FileViewerSourceKind.url:
        if (source.headers.isEmpty) {
          url = source.location;
        } else {
          final headers = web.Headers();
          source.headers.forEach((name, value) {
            headers.set(name, value);
          });
          final response = await web.window
              .fetch(source.location.toJS, web.RequestInit(headers: headers))
              .toDart;
          if (!response.ok) {
            throw const FileViewerException(
              FileViewerErrorCode.sourceUnavailable,
              'The remote file could not be fetched. Check access and CORS.',
            );
          }
          url = web.URL.createObjectURL(await response.blob().toDart);
          if (_disposed) {
            web.URL.revokeObjectURL(url);
            throw const FileViewerException(
              FileViewerErrorCode.disposed,
              'Resource host is disposed.',
            );
          }
          _objectUrls[id] = url;
        }
    }
    return {
      'url': url,
      'filename': source.filename,
      if (source.mimeType != null) 'type': source.mimeType,
    };
  }

  @override
  Future<void> releaseSource(String id) async {
    final url = _objectUrls.remove(id);
    if (url != null) web.URL.revokeObjectURL(url);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    for (final url in _objectUrls.values) {
      web.URL.revokeObjectURL(url);
    }
    _objectUrls.clear();
  }
}
