import 'package:flutter/foundation.dart';

import 'models.dart';
import 'source.dart';

/// Bridge contract implemented by an attached document session.
///
/// Applications normally use [FileViewerController] rather than implementing
/// this low-level command transport.
abstract interface class ViewerCommands {
  /// Sends a supported bridge [method] with JSON-compatible [arguments].
  Future<Object?> command(
    String method, [
    Map<String, Object?> arguments = const {},
  ]);

  /// Loads [source], applying renderer [options] when provided.
  Future<void> load(FileViewerSource source, {Map<String, Object?>? options});

  /// Unloads the current document and releases its scoped resource URL.
  Future<void> clear();
}

/// Controls one mounted viewer's document, search, zoom and view state.
///
/// Wait for the widget's `ready` event before issuing commands, and wait for
/// `documentReady` before document-dependent actions. A controller can attach
/// to only one widget at a time. Dispose it when its owning screen is disposed.
/// Unsupported operations fail with a [FileViewerException]; capabilities
/// depend on the document format and platform.
class FileViewerController extends ChangeNotifier {
  /// Creates an unattached controller for a viewer widget.
  FileViewerController();

  ViewerCommands? _commands;
  bool _disposed = false;

  /// Whether a live widget has attached its session to this controller.
  ///
  /// Attachment indicates that commands can be sent, not that a document has
  /// finished loading. Observe `documentReady` for content readiness.
  bool get isAttached => _commands != null && !_disposed;

  /// Attaches the widget-owned command transport; not an application action.
  @internal
  void attach(ViewerCommands commands) {
    if (_disposed) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Controller is disposed.',
      );
    }
    if (_commands != null && !identical(_commands, commands)) {
      throw StateError('Use a separate controller for each FileViewer widget.');
    }
    _commands = commands;
    notifyListeners();
  }

  /// Detaches [commands] only if it is the currently attached transport.
  @internal
  void detach(ViewerCommands commands) {
    if (identical(_commands, commands)) {
      _commands = null;
      if (!_disposed) notifyListeners();
    }
  }

  ViewerCommands get _bound =>
      _commands ??
      (throw const FileViewerException(
        FileViewerErrorCode.initialization,
        'Wait for the FileViewer ready event before issuing commands.',
      ));

  /// Replaces the current document with [source].
  ///
  /// Reset application document readiness before calling. The returned future
  /// completes when this load finishes; a newer load may cancel it.
  Future<void> load(FileViewerSource source) => _bound.load(source);

  /// Reparses the current document without changing its source.
  Future<void> reload() async {
    await _bound.command('reload');
  }

  /// Searches the current document for [query], returning renderer search state.
  ///
  /// The result is JSON-compatible and format-dependent. Use [getCapabilities]
  /// to check whether document search is available.
  Future<Object?> search(String query) =>
      _bound.command('searchDocument', {'query': query});

  /// Removes the current search query and its highlights.
  Future<Object?> clearSearch() => _bound.command('clearDocumentSearch');

  /// Selects the next match for the current search query.
  Future<Object?> nextSearchResult() => _bound.command('nextSearchResult');

  /// Selects the previous match for the current search query.
  Future<Object?> previousSearchResult() =>
      _bound.command('previousSearchResult');

  /// Increases the current renderer's zoom and suspends automatic fitting.
  Future<Object?> zoomIn() => _bound.command('zoomIn');

  /// Decreases the current renderer's zoom and suspends automatic fitting.
  Future<Object?> zoomOut() => _bound.command('zoomOut');

  /// Restores the renderer's default zoom, usually its natural 100% size.
  ///
  /// Use [fit] to restore adaptive fitting instead of resetting manual zoom.
  Future<Object?> resetZoom() => _bound.command('resetZoom');

  /// Fits the current document using [mode] and restores resize adaptation.
  ///
  /// Accepted modes are `auto`, `width`, `contain` and `actual`. `auto` uses
  /// format-specific fitting; small spreadsheets keep their natural size.
  /// The returned map includes `applied` and, when available, the fitted scale.
  Future<Object?> fit({String mode = 'auto'}) =>
      _bound.command('fitToView', {'fit': mode});

  /// Returns JSON-compatible renderer state such as page, zoom and scroll.
  ///
  /// Available keys depend on the format. Retain this value only for the same
  /// document and renderer when restoring a view with [applyViewState].
  Future<Object?> getViewState() => _bound.command('getViewState');

  /// Applies supported fields from a previously read or partial view [state].
  ///
  /// Pages are one-based. For PPTX, `{'page': 2}` navigates during reading or
  /// slideshow; keys unsupported by a renderer are not a cross-format promise.
  /// This counts as manual view interaction; call [fit] to resume auto fitting.
  Future<Object?> applyViewState(Map<String, Object?> state) =>
      _bound.command('applyViewState', {'state': state});

  /// Enters or leaves PPTX slideshow mode according to [active].
  ///
  /// Wait for document readiness first. Leaving slideshow keeps the current
  /// slide and restores its reading zoom without reparsing the document.
  /// Throws [FileViewerException] with
  /// [FileViewerErrorCode.unsupportedOperation] for unsupported renderers.
  Future<void> setPresentationMode(bool active) async {
    final current = await getViewState();
    final capability = current is Map ? current['extra'] : null;
    if (capability is! Map || capability['presentationAvailable'] != true) {
      throw const FileViewerException(
        FileViewerErrorCode.unsupportedOperation,
        'Slideshow mode is unavailable for this document.',
      );
    }
    final state = await applyViewState({
      'extra': {'presenting': active},
    });
    final extra = state is Map ? state['extra'] : null;
    if (extra is! Map || extra['presenting'] != active) {
      throw const FileViewerException(
        FileViewerErrorCode.unsupportedOperation,
        'Slideshow mode is unavailable for this document.',
      );
    }
  }

  /// Reads the current renderer's available document operations.
  ///
  /// Query again after changing formats or when operation availability changes.
  Future<FileViewerCapabilities> getCapabilities() async {
    final value = await _bound.command('getOperationAvailability');
    return FileViewerCapabilities(
      value is Map ? Map<String, Object?>.from(value) : const {},
    );
  }

  /// Unloads the document while keeping the attached viewer shell available.
  ///
  /// A later [load] can use the same controller and session.
  Future<void> close() => _bound.clear();

  /// Exercise a real packaged module Worker and WASM module on this platform.
  /// This reports runtime transport support, not support for a file format.
  Future<Map<String, Object?>> probeRuntime() async {
    final value = await _bound.command('probeRuntime');
    return Map<String, Object?>.from(value! as Map);
  }

  @override
  void dispose() {
    _disposed = true;
    _commands = null;
    super.dispose();
  }
}
