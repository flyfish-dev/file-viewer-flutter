import 'dart:convert';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:path_provider/path_provider.dart';

import '../models.dart';
import '../resources/resource_host.dart';
import 'linux_surface.dart';
import 'navigation.dart';
import 'surface.dart';

FileViewerSurface createSurface() =>
    Platform.isLinux ? LinuxViewerSurface() : NativeViewerSurface();

class NativeViewerSurface implements FileViewerSurface {
  final _keepAlive = InAppWebViewKeepAlive();
  PlatformHeadlessInAppWebView? _headless;
  PlatformInAppWebViewController? _controller;
  PlatformWebViewEnvironment? _environment;
  late ViewerResourceHost _resources;
  late BridgeMessageHandler _onMessage;
  bool _transferred = false;
  bool _disposed = false;

  @override
  Future<void> initialize(
    ViewerResourceHost resources,
    BridgeMessageHandler onMessage,
  ) async {
    _resources = resources;
    _onMessage = onMessage;
    if (InAppWebViewPlatform.instance == null) {
      if (Platform.isAndroid) AndroidInAppWebViewPlatform.registerWith();
      if (Platform.isIOS) IOSInAppWebViewPlatform.registerWith();
      if (Platform.isMacOS) MacOSInAppWebViewPlatform.registerWith();
      if (Platform.isWindows) WindowsInAppWebViewPlatform.registerWith();
    }
    _trace('initialize');
    if (Platform.isWindows) {
      const channel = MethodChannel('file_viewer_flutter/runtime');
      final runtimePath = await channel.invokeMethod<String>(
        'getBundledRuntimePath',
      );
      if (runtimePath == null) {
        throw const FileViewerException(
          FileViewerErrorCode.incompatibleRuntime,
          'WebView2 is missing. Build the Windows offline runtime bundle before distribution.',
        );
      }
      final support = await getApplicationSupportDirectory();
      final dataDirectory = Directory('${support.path}/FileViewerWebView2');
      await dataDirectory.create(recursive: true);
      _environment = await PlatformWebViewEnvironment.static().create(
        settings: WebViewEnvironmentSettings(
          userDataFolder: dataDirectory.path,
          browserExecutableFolder: runtimePath,
        ),
      );
    }
    if (_disposed) {
      await _environment?.dispose();
      return;
    }
    _headless = PlatformHeadlessInAppWebView(
      PlatformHeadlessInAppWebViewCreationParams(
        initialUserScripts: UnmodifiableListView([
          UserScript(
            source: "window.addEventListener('error', event => console.error(event.error?.stack || event.message || ('resource failed: ' + event.target?.tagName)), true); window.addEventListener('unhandledrejection', event => console.error(event.reason?.stack || String(event.reason))); document.addEventListener('securitypolicyviolation', event => console.error('CSP: ' + event.violatedDirective));",
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          ),
        ]),
        initialSize: const Size(800, 600),
        webViewEnvironment: _environment,
        initialUrlRequest: URLRequest(
          url: WebUri(resources.shellUri.toString()),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          isInspectable: kDebugMode,
          transparentBackground: true,
          supportZoom: false,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: true,
          allowsInlineMediaPlayback: true,
          javaScriptHandlersForMainFrameOnly: true,
          javaScriptBridgeForMainFrameOnly: true,
          javaScriptHandlersOriginAllowList: {
            '^${RegExp.escape(resources.shellUri.origin)}\$',
          },
        ),
        onWebViewCreated: _onCreated,
        onLoadStart: (_, _) => _trace('load started'),
        onLoadStop: _onLoadStop,
        onConsoleMessage: (_, message) => _trace('console: ${message.message}'),
        onReceivedHttpError: (_, _, response) =>
            _trace('HTTP ${response.statusCode}'),
        onReceivedError: (_, request, error) {
          if (request.isForMainFrame == true && !_disposed) {
            _onMessage({
              'protocolVersion': 1,
              'type': 'surfaceError',
              'message': error.description,
            });
          }
        },
        shouldOverrideUrlLoading: _navigation,
        onCreateWindow: (_, _) async => false,
        onWebContentProcessDidTerminate: (_) async => _terminated(),
        onRenderProcessGone: (_, _) async {
          _terminated();
          return;
        },
      ),
    );
    await _headless!.run();
    _trace('headless started');
  }

  void _trace(String message) {
    if (kDebugMode && const bool.fromEnvironment('FILE_VIEWER_DIAGNOSTICS')) {
      debugPrint('FileViewer surface: $message');
    }
  }

  void _terminated() {
    if (!_disposed) {
      _onMessage({'protocolVersion': 1, 'type': 'surfaceTerminated'});
    }
  }

  void _onCreated(dynamic value) {
    final controller = value as PlatformInAppWebViewController;
    if (_disposed) {
      controller.dispose();
      return;
    }
    // Widget detachment disposes its Dart controller while the native view
    // survives. Own a separate handle for idle preloading and lifecycle work.
    final previous = _controller;
    _controller = PlatformInAppWebViewController(controller.params);
    previous?.dispose(isKeepAlive: true);
    if (controller.params.webviewParams
        is PlatformInAppWebViewWidgetCreationParams) {
      _transferred = true;
      final headless = _headless;
      if (headless != null) {
        // These pinned adapters mark the headless object stopped on transfer,
        // making its public dispose() a no-op. Release only its now-unused
        // headless event channel; the live WebView channel is separate.
        if (headless is ChannelController) {
          (headless as ChannelController).disposeChannel();
        }
        headless.webViewController?.dispose(isKeepAlive: true);
        _headless = null;
      }
    }
    _trace('created');
    _controller!.addJavaScriptHandler(
      handlerName: 'fileViewerEvent',
      callback: (JavaScriptHandlerFunctionData handler) {
        final arguments = handler.args;
        if (_disposed || arguments.isEmpty) return;
        final data = arguments.first is String
            ? jsonDecode(arguments.first as String)
            : arguments.first;
        if (data is Map) _onMessage(Map<String, dynamic>.from(data));
      },
    );
  }

  Future<void> _onLoadStop(dynamic value, WebUri? url) async {
    final controller = value as PlatformInAppWebViewController;
    _trace('load stopped');
    if (_disposed ||
        !isAllowedViewerNavigation(
          url,
          _resources.shellUri,
          isMainFrame: true,
        )) {
      return;
    }
    final configuration = jsonEncode({'assetBases': _resources.assetBases});
    await controller.evaluateJavascript(
      source:
          '''
(() => {
  if (globalThis.__fileViewerFlutterBootstrapConfigured) return;
  globalThis.__fileViewerFlutterBootstrapConfigured = true;
  const start = () => globalThis.FileViewerFlutter.bootstrapNative($configuration);
  if (globalThis.FileViewerFlutter) start();
  else globalThis.addEventListener('file-viewer-runtime-ready', start, { once: true });
})();
''',
    );
    _trace('bootstrap dispatched');
  }

  Future<NavigationActionPolicy> _navigation(
    dynamic controller,
    NavigationAction action,
  ) async =>
      isAllowedViewerNavigation(
        action.request.url,
        _resources.shellUri,
        isMainFrame: action.isForMainFrame,
      )
      ? NavigationActionPolicy.ALLOW
      : NavigationActionPolicy.CANCEL;

  @override
  Widget buildView(BuildContext context) {
    final headless = _transferred ? null : _headless;
    return _PlatformViewer(
      create: () => PlatformInAppWebViewWidget(
        PlatformInAppWebViewWidgetCreationParams(
          keepAlive: _keepAlive,
          headlessWebView: headless,
          webViewEnvironment: _environment,
          onWebViewCreated: _onCreated,
          onLoadStop: _onLoadStop,
          shouldOverrideUrlLoading: _navigation,
          onCreateWindow: (_, _) async => false,
          onWebContentProcessDidTerminate: (_) async => _terminated(),
          onRenderProcessGone: (_, _) async {
            _terminated();
            return;
          },
        ),
      ),
    );
  }

  @override
  Future<void> dispatch(Map<String, Object?> message) async {
    final controller = _controller;
    if (_disposed || controller == null) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Viewer surface is unavailable.',
      );
    }
    await controller.evaluateJavascript(
      source:
          'globalThis.__fileViewerFlutterDispatch(${jsonEncode(message)}); null;',
    );
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _controller?.dispose();
    if (!_transferred) await _headless?.dispose();
    await PlatformInAppWebViewController.static().disposeKeepAlive(_keepAlive);
    await _environment?.dispose();
    _controller = null;
  }
}

class _PlatformViewer extends StatefulWidget {
  const _PlatformViewer({required this.create});
  final PlatformInAppWebViewWidget Function() create;
  @override
  State<_PlatformViewer> createState() => _PlatformViewerState();
}

class _PlatformViewerState extends State<_PlatformViewer> {
  late final _platform = widget.create();
  @override
  Widget build(BuildContext context) => _platform.build(context);
  @override
  void dispose() {
    _platform.dispose();
    super.dispose();
  }
}
