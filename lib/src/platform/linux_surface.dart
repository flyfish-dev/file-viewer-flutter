import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:file_viewer_flutter_linux/file_viewer_flutter_linux.dart'
    as cef;

import '../models.dart';
import '../resources/resource_host.dart';
import 'surface.dart';

/// Adapts one packaged Linux CEF view to the shared session protocol.
class LinuxViewerSurface implements FileViewerSurface {
  static Future<void>? _managerReady;
  cef.WebViewController? _controller;
  bool _disposed = false;

  @override
  Future<void> initialize(
    ViewerResourceHost resources,
    BridgeMessageHandler onMessage,
  ) async {
    await (_managerReady ??= cef.WebviewManager().initialize());
    if (_disposed) return;
    final controller = cef.WebviewManager().createWebView();
    _controller = controller;
    controller.setWebviewListener(
      cef.WebviewEventsListener(
        onProcessTerminated: (_) {
          if (!_disposed) {
            onMessage({'protocolVersion': 1, 'type': 'surfaceTerminated'});
          }
        },
      ),
    );
    await controller.initialize(resources.shellUri.toString());
    if (_disposed) {
      await controller.dispose();
      return;
    }
    await controller.setJavaScriptChannels({
      cef.JavascriptChannel(
        name: 'FileViewerCef',
        onMessageReceived: (message) {
          if (_disposed) return;
          final data = jsonDecode(message.message);
          if (data is Map) onMessage(Map<String, dynamic>.from(data));
          unawaited(
            controller.sendJavaScriptChannelCallBack(
              false,
              'null',
              message.callbackId,
              message.frameId,
            ),
          );
        },
      ),
    });
    final config = jsonEncode({'assetBases': resources.assetBases});
    await controller.executeJavaScript('''
      (() => {
        let attempts = 0;
        function initialize() {
          if (globalThis.FileViewerFlutter && globalThis.FileViewerCef) {
            globalThis.FileViewerFlutter.bootstrapNative($config);
          } else if (++attempts < 600) {
            setTimeout(initialize, 50);
          }
        }
        initialize();
      })();
    ''');
  }

  @override
  Widget buildView(BuildContext context) => _controller!.webviewWidget;

  @override
  Future<void> dispatch(Map<String, Object?> message) async {
    final controller = _controller;
    if (_disposed || controller == null) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Linux viewer surface is unavailable.',
      );
    }
    await controller.executeJavaScript(
      'globalThis.__fileViewerFlutterDispatch(${jsonEncode(message)});',
    );
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _controller?.dispose();
    _controller = null;
  }
}
