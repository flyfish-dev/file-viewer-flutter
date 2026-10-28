import 'package:flutter/foundation.dart';

import 'models.dart';
import 'source.dart';

abstract interface class ViewerCommands {
  Future<Object?> command(
    String method, [
    Map<String, Object?> arguments = const {},
  ]);
  Future<void> load(FileViewerSource source, {Map<String, Object?>? options});
  Future<void> clear();
}

class FileViewerController extends ChangeNotifier {
  ViewerCommands? _commands;
  bool _disposed = false;

  bool get isAttached => _commands != null && !_disposed;

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

  Future<void> load(FileViewerSource source) => _bound.load(source);
  Future<void> reload() async {
    await _bound.command('reload');
  }

  Future<Object?> search(String query) =>
      _bound.command('searchDocument', {'query': query});
  Future<Object?> clearSearch() => _bound.command('clearDocumentSearch');
  Future<Object?> nextSearchResult() => _bound.command('nextSearchResult');
  Future<Object?> previousSearchResult() =>
      _bound.command('previousSearchResult');
  Future<Object?> zoomIn() => _bound.command('zoomIn');
  Future<Object?> zoomOut() => _bound.command('zoomOut');
  Future<Object?> resetZoom() => _bound.command('resetZoom');
  Future<Object?> fit({String mode = 'width'}) =>
      _bound.command('fitToView', {'fit': mode});
  Future<Object?> getViewState() => _bound.command('getViewState');
  Future<Object?> applyViewState(Map<String, Object?> state) =>
      _bound.command('applyViewState', {'state': state});
  Future<FileViewerCapabilities> getCapabilities() async {
    final value = await _bound.command('getOperationAvailability');
    return FileViewerCapabilities(
      value is Map ? Map<String, Object?>.from(value) : const {},
    );
  }

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
