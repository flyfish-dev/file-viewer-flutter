import 'package:file_viewer_flutter_linux/src/webview.dart';

/// Receives the current page title after CEF reports a title change.
typedef TitleChangeCb = void Function(String title);
/// Receives the browser URL after navigation changes it.
typedef UrlChangeCb = void Function(String url);
/* Log severity levels. from CEF include/internal/cef_types.h
  0:default logging (currently info logging)
  1:verbose logging or debug logging
  2:info logging
  3:warning logging
  4:error logging
  5:fatal logging
  99:disable logging to file for all messages, and to stderr for messages with severity less than fatal
 */
/// Receives the controller and URL when native document loading begins.
typedef LoadStartCb = void Function(WebViewController controller, String url);
/// Receives the controller and URL when native document loading completes.
typedef LoadStopCb = void Function(WebViewController controller, String url);

/// Receives CEF console severity, message, source and source-line number.
typedef OnConsoleMessage = void Function(
    int level, String message, String source, int line);

/// Optional callbacks for native browser navigation, loading and process events.
class WebviewEventsListener {
  /// Called when the page title changes.
  TitleChangeCb? onTitleChanged;
  /// Called when the browser's current URL changes.
  UrlChangeCb? onUrlChanged;
  /// Called for browser console diagnostics; avoid logging sensitive content.
  OnConsoleMessage? onConsoleMessage;
  /// Called when document loading begins.
  LoadStartCb? onLoadStart;
  /// Called when native document loading ends, before application-specific readiness.
  LoadStopCb? onLoadEnd;
  /// Called with CEF's termination status if the renderer process exits.
  void Function(int status)? onProcessTerminated;

  /// Selects the native events the application or adapter needs to observe.
  WebviewEventsListener({
    this.onTitleChanged,
    this.onUrlChanged,
    this.onConsoleMessage,
    this.onLoadStart,
    this.onLoadEnd,
    this.onProcessTerminated,
  });
}
