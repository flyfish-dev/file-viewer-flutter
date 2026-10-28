# File Viewer Flutter macOS adapter

Internal WKWebView adapter for `file_viewer_flutter`. Use the app-facing package
instead of depending on this implementation directly.

The retained WKWebView moves between fresh native containers when Flutter
routes reattach. A deferred disposal of an old platform-view ID can therefore
only remove its old container. The rendering engine and document stay alive.

Derived from the immutable public `flutter_inappwebview_macos` 1.2.0-beta.3
release under Apache-2.0. See `LICENSE` and `UPSTREAM.json`. Reproduce the sources
with `python3 tool/vendor-macos.py` from the repository root. The package, native
plugin class and platform channel namespaces are isolated from the upstream
plugin so applications can also use another InAppWebView instance.
