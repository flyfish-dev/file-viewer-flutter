import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../models.dart';
import '../resources/resource_host.dart';
import 'surface.dart';

@JS('FileViewerFlutter')
external _BrowserRuntime? get _browserRuntime;

extension type _BrowserRuntime(JSObject _) implements JSObject {
  external _BrowserSession create(
    JSObject container,
    JSObject configuration,
    JSFunction callback,
  );
}

extension type _BrowserSession(JSObject _) implements JSObject {
  external JSPromise<JSAny?> dispatch(JSObject message);
  external void destroy();
}

/// Creates a browser DOM surface backed by the packaged JavaScript runtime.
FileViewerSurface createSurface() => WebViewerSurface();

/// Owns one browser runtime session and its embeddable HTML container.
class WebViewerSurface implements FileViewerSurface {
  static Future<void>? _loading;
  final _container = web.HTMLDivElement();
  _BrowserSession? _session;
  bool _disposed = false;

  static Future<void> _loadRuntime(Uri uri) {
    if (_browserRuntime != null) return Future.value();
    return _loading ??= () async {
      final completion = Completer<void>();
      final script = web.HTMLScriptElement()
        ..type = 'module'
        ..src = uri.toString();
      script.onLoad.first.then((_) {
        if (!completion.isCompleted) completion.complete();
      });
      script.onError.first.then((_) {
        if (!completion.isCompleted) {
          completion.completeError(
            const FileViewerException(
              FileViewerErrorCode.missingResources,
              'The offline JavaScript runtime failed to load.',
            ),
          );
        }
      });
      web.document.head!.append(script);
      try {
        await completion.future.timeout(const Duration(seconds: 30));
        if (_browserRuntime == null) {
          throw const FileViewerException(
            FileViewerErrorCode.protocol,
            'Viewer runtime did not register its bridge.',
          );
        }
      } catch (_) {
        script.remove();
        _loading = null;
        rethrow;
      }
    }();
  }

  @override
  Future<void> initialize(
    ViewerResourceHost resources,
    BridgeMessageHandler onMessage,
  ) async {
    await _loadRuntime(
      Uri.parse(resources.assetBases['base']!).resolve('runtime.mjs'),
    );
    if (_disposed) return;
    _container.style
      ..width = '100%'
      ..height = '100%'
      ..overflow = 'hidden';
    _session = _browserRuntime!.create(
      _container,
      {'assetBases': resources.assetBases}.jsify() as JSObject,
      ((JSString message) {
        if (!_disposed) {
          onMessage(
            Map<String, dynamic>.from(jsonDecode(message.toDart) as Map),
          );
        }
      }).toJS,
    );
  }

  @override
  Widget buildView(BuildContext context) => HtmlElementView.fromTagName(
    tagName: 'div',
    onElementCreated: (element) {
      final host = element as web.HTMLElement;
      host.style
        ..width = '100%'
        ..height = '100%';
      host.append(_container);
    },
  );

  @override
  Future<void> dispatch(Map<String, Object?> message) async {
    if (_disposed || _session == null) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Viewer surface is disposed.',
      );
    }
    await _session!.dispatch(message.jsify() as JSObject).toDart;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _session?.destroy();
    _session = null;
    _container.remove();
  }
}
