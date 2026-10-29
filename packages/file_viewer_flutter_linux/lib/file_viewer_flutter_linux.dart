/// Linux CEF platform adapter used by File Viewer Flutter.
///
/// Most applications should depend on `file_viewer_flutter` and use its widget
/// and runtime. This library exposes the lower-level CEF controller, lifecycle
/// callbacks, JavaScript channels and input integration for platform adapters.
library;

export 'src/webview_manager.dart';
export 'src/webview.dart';
export 'src/webview_events_listener.dart';
export 'src/webview_javascript.dart';
export 'src/webview_textinput.dart';
export 'src/webview_inject_user_script.dart';
