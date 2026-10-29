# Controllers and events

`FileViewerController` provides document, search, zoom and view-state commands. Use a separate controller for every simultaneously displayed viewer, and dispose it with its owning screen.

## Wait for readiness

This complete screen example enables its action after document loading:

```dart
import 'package:flutter/material.dart';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

class ControlledPreview extends StatefulWidget {
  const ControlledPreview({super.key});

  @override
  State<ControlledPreview> createState() => _ControlledPreviewState();
}

class _ControlledPreviewState extends State<ControlledPreview> {
  final controller = FileViewerController();
  bool documentReady = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File preview'),
        actions: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: documentReady ? () async {
              await controller.zoomIn();
            } : null,
            icon: const Icon(Icons.zoom_in),
          ),
        ],
      ),
      body: FileViewer(
        source: const FileViewerSource.asset('assets/example.pdf'),
        controller: controller,
        onEvent: (event) {
          if (event.type == 'documentReady' && mounted) {
            setState(() => documentReady = true);
          }
        },
        onError: (error) {
          if (mounted) setState(() => documentReady = false);
          debugPrint(error.toString());
        },
      ),
    );
  }
}
```

`ready` means the controller is attached to the native surface. `documentReady` means the current load completed. Measure actual visible content separately; neither event alone is a screen first-paint measurement.

## Common commands

| Goal | Method |
| --- | --- |
| Change document | `load(source)` |
| Reload current document | `reload()` |
| Search and clear search | `search(query)`, `clearSearch()` |
| Next / previous result | `nextSearchResult()`, `previousSearchResult()` |
| Zoom in, out and reset | `zoomIn()`, `zoomOut()`, `resetZoom()` |
| Fit width / page | `fit(mode: 'width')`, `fit(mode: 'contain')` |
| Read / restore view state | `getViewState()`, `applyViewState(state)` |
| Query available operations | `getCapabilities()` |
| Clear current document | `close()` |

Operations depend on the format. Query `getCapabilities()` before exposing application actions; a shared method does not give every format identical capabilities. Print, download and browser-export UI remains gated while native host output integration is qualified in this preview.

## Errors and recovery

`onError` receives load or initialization errors. `FileViewerException.code` distinguishes `missingResources`, `unsupportedSource`, `sourceUnavailable`, `loadFailed` and other cases; `cause` may hold an underlying error. Keep token-bearing URLs and authorization headers out of logs.

The default error UI includes Retry. Supply `errorBuilder(context, error, retry)` for a custom interface; its `retry()` recreates a failed viewer. The runtime also attempts recovery after a native renderer-termination event.

Reset your screen's document-ready state before initiating another load, then wait for the next `documentReady`. Do not send controller commands after closing or disposing the screen.
