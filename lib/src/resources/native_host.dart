import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

import '../models.dart';
import '../source.dart';
import 'manifest.dart';
import 'range.dart';
import 'resource_host.dart';

ViewerResourceHost createResourceHost() => NativeViewerResourceHost();

class NativeViewerResourceHost implements ViewerResourceHost {
  NativeViewerResourceHost({AssetBundle? bundle})
    : manifest = ViewerAssetManifest(bundle: bundle);

  final ViewerAssetManifest manifest;
  final _sources = <String, FileViewerSource>{};
  final _client = HttpClient()..autoUncompress = false;
  final _verifiedAssets = <String>{};
  final _token = base64Url
      .encode(List<int>.generate(32, (_) => Random.secure().nextInt(256)))
      .replaceAll('=', '');
  HttpServer? _server;
  Future<void>? _initializing;
  bool _disposed = false;

  @override
  Future<void> initialize() => _initializing ??= _start();

  Future<void> _start() async {
    await manifest.load();
    if (_disposed) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Resource host is disposed.',
      );
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    if (_disposed) {
      await server.close(force: true);
      return;
    }
    _server = server;
    server.listen((request) {
      _serve(request);
    });
  }

  Uri get _base => Uri.parse('http://localhost:${_server!.port}/$_token/');

  @override
  Uri get shellUri => _base.resolve('assets/index.html');

  @override
  Map<String, String> get assetBases => {
    for (final key in viewerAssetPackages.keys)
      key: _base.resolve('assets/').toString(),
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
    if (source.kind == FileViewerSourceKind.file &&
        !await File(source.location).exists()) {
      throw const FileViewerException(
        FileViewerErrorCode.sourceUnavailable,
        'The selected file is no longer available.',
      );
    }
    _sources[id] = source;
    return {
      'url': _base
          .resolve('documents/$id/${Uri.encodeComponent(source.filename)}')
          .toString(),
      'filename': source.filename,
      if (source.mimeType != null) 'type': source.mimeType,
    };
  }

  @override
  Future<void> releaseSource(String id) async {
    _sources.remove(id);
  }

  Future<void> _serve(HttpRequest request) async {
    final response = request.response;
    try {
      final host = request.headers.value(HttpHeaders.hostHeader);
      final allowedHosts = {
        'localhost:${_server!.port}',
        '127.0.0.1:${_server!.port}',
      };
      if (!allowedHosts.contains(host) ||
          !{'GET', 'HEAD'}.contains(request.method)) {
        response.statusCode = HttpStatus.forbidden;
        return;
      }
      final origin = request.headers.value('origin');
      if (origin != null && origin != _base.origin) {
        response.statusCode = HttpStatus.forbidden;
        return;
      }
      final parts = request.uri.pathSegments;
      if (parts.length < 3 || parts.first != _token || parts.contains('..')) {
        response.statusCode = HttpStatus.notFound;
        return;
      }
      response.headers.set('X-Content-Type-Options', 'nosniff');
      response.headers.set('Referrer-Policy', 'no-referrer');
      if (parts[1] == 'assets') {
        final logical = parts.skip(2).join('/');
        final entry = manifest.entries[logical];
        if (entry == null) {
          response.statusCode = HttpStatus.notFound;
          return;
        }
        final data = await manifest.bundle.load(entry.key);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        if (bytes.length != entry.size ||
            (!_verifiedAssets.contains(entry.key) &&
                await Isolate.run(() => sha256.convert(bytes).toString()) !=
                    entry.sha256)) {
          response.statusCode = HttpStatus.internalServerError;
          return;
        }
        _verifiedAssets.add(entry.key);
        response.headers.set(
          HttpHeaders.cacheControlHeader,
          'private, max-age=31536000, immutable',
        );
        if (logical == 'index.html') {
          response.headers.set(
            'Content-Security-Policy',
            "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' blob: data:; font-src 'self' data:; worker-src 'self' blob:; connect-src 'self'; media-src 'self' blob:; frame-ancestors 'none'; object-src 'none'; base-uri 'none'",
          );
        }
        await _sendBytes(request, bytes, entry.contentType);
      } else if (parts[1] == 'documents') {
        final source = _sources[parts[2]];
        if (source == null) {
          response.statusCode = HttpStatus.notFound;
          return;
        }
        response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
        final type =
            source.mimeType ??
            lookupMimeType(source.filename) ??
            'application/octet-stream';
        switch (source.kind) {
          case FileViewerSourceKind.file:
            final file = File(source.location);
            final length = await file.length();
            final range = _setRange(request, length, type);
            if (range != null && request.method != 'HEAD') {
              await response.addStream(file.openRead(range.start, range.end));
            }
          case FileViewerSourceKind.asset:
            final data = await manifest.bundle.load(source.location);
            await _sendBytes(
              request,
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
              type,
            );
          case FileViewerSourceKind.bytes:
            await _sendBytes(request, source.data!, type);
          case FileViewerSourceKind.url:
            await _proxy(request, source);
        }
      } else {
        response.statusCode = HttpStatus.notFound;
      }
    } catch (error) {
      if (kDebugMode && const bool.fromEnvironment('FILE_VIEWER_DIAGNOSTICS')) {
        debugPrint('FileViewer resource error: $error');
      }
      try {
        response.statusCode = HttpStatus.internalServerError;
      } catch (_) {
        /* Response already started. */
      }
    } finally {
      if (kDebugMode && const bool.fromEnvironment('FILE_VIEWER_DIAGNOSTICS')) {
        debugPrint(
          'FileViewer resource: ${request.uri.pathSegments.last} ${response.statusCode}',
        );
      }
      try {
        await response.close();
      } catch (_) {
        /* Client cancelled the request. */
      }
    }
  }

  ({int start, int end})? _setRange(
    HttpRequest request,
    int length,
    String type,
  ) {
    final response = request.response;
    response.headers.set(HttpHeaders.contentTypeHeader, type);
    response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    final header = request.headers.value(HttpHeaders.rangeHeader);
    final range = parseViewerByteRange(header, length);
    if (range == null) {
      response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
      response.headers.set(HttpHeaders.contentRangeHeader, 'bytes */$length');
      return null;
    }
    response.contentLength = range.end - range.start;
    if (header != null) {
      response.statusCode = HttpStatus.partialContent;
      response.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes ${range.start}-${range.end - 1}/$length',
      );
    }
    return range;
  }

  Future<void> _sendBytes(
    HttpRequest request,
    Uint8List bytes,
    String type,
  ) async {
    final range = _setRange(request, bytes.length, type);
    if (range != null && request.method != 'HEAD') {
      request.response.add(
        Uint8List.sublistView(bytes, range.start, range.end),
      );
    }
  }

  Future<void> _proxy(HttpRequest request, FileViewerSource source) async {
    var uri = Uri.parse(source.location);
    var headers = source.headers;
    for (var redirects = 0; redirects <= 5; redirects++) {
      final upstream = await _client.openUrl(request.method, uri);
      upstream.followRedirects = false;
      headers.forEach(upstream.headers.set);
      upstream.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
      final range = request.headers.value(HttpHeaders.rangeHeader);
      if (range != null) upstream.headers.set(HttpHeaders.rangeHeader, range);
      final result = await upstream.close();
      if ({301, 302, 303, 307, 308}.contains(result.statusCode)) {
        final location = result.headers.value(HttpHeaders.locationHeader);
        await result.drain<void>();
        if (location == null) break;
        final next = uri.resolve(location);
        if (!{'http', 'https'}.contains(next.scheme) ||
            (uri.scheme == 'https' && next.scheme != 'https')) {
          break;
        }
        if (next.origin != uri.origin) headers = const {};
        uri = next;
        continue;
      }
      request.response.statusCode = result.statusCode;
      for (final key in [
        HttpHeaders.contentTypeHeader,
        HttpHeaders.contentLengthHeader,
        HttpHeaders.contentRangeHeader,
        HttpHeaders.acceptRangesHeader,
        HttpHeaders.contentEncodingHeader,
      ]) {
        final value = result.headers.value(key);
        if (value != null) request.response.headers.set(key, value);
      }
      await request.response.addStream(result);
      return;
    }
    request.response.statusCode = HttpStatus.badGateway;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _sources.clear();
    _client.close(force: true);
    await _server?.close(force: true);
  }
}
