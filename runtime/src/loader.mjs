// WKWebView's navigation completion can precede module-graph evaluation.
// Native bootstrap listens for the explicit runtime-ready event instead.
import('./runtime.mjs').catch(error => {
  const message = JSON.stringify({ protocolVersion: 1, type: 'surfaceError',
    message: 'The packaged viewer module could not start.' });
  if (globalThis.flutter_inappwebview?.callHandler) {
    void globalThis.flutter_inappwebview.callHandler('fileViewerEvent', message);
  }
  // Diagnostics are opt-in on the Flutter side; never include document data.
  console.error('File Viewer module initialization failed:', error?.name || 'Error');
});
