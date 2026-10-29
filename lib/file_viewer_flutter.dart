/// Offline document previews with reusable, application-scoped render sessions.
///
/// Wrap an application in [FileViewerHost], then place a [FileViewer] in a
/// bounded layout with a [FileViewerSource]. Use [FileViewerController] for
/// document actions after the viewer reports readiness.
///
/// [FileViewerRuntime.warmUp] prepares the viewer shell and parser modules;
/// [FileViewerRuntime.preload] loads a particular upcoming document. Neither
/// shell readiness nor module warm-up guarantees that every format's engine
/// has initialized. Listen for `documentReady` before acting on document content.
///
/// See the [integration guide](https://flutter.file-viewer.app/en/docs/quickstart/)
/// for host setup, source types and platform qualification.
library;

export 'src/controller.dart';
export 'src/host.dart';
export 'src/models.dart';
export 'src/runtime.dart';
export 'src/source.dart';
export 'src/viewer.dart';
