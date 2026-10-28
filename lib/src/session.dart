import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'models.dart';
import 'platform/surface.dart';
import 'resources/resource_host.dart';
import 'source.dart';

class FileViewerSession implements ViewerCommands {
  FileViewerSession({
    required this.id,
    required this.surface,
    required this.resources,
    this.initializationTimeout = const Duration(seconds: 30),
    this.disposalTimeout = const Duration(seconds: 5),
  }) {
    _ready.future.ignore();
  }

  final String id;
  final FileViewerSurface surface;
  final ViewerResourceHost resources;
  final Duration initializationTimeout;
  final Duration disposalTimeout;
  final _ready = Completer<void>();
  final _pending = <int, Completer<Object?>>{};
  final _events = StreamController<FileViewerEvent>.broadcast(sync: true);
  int _sequence = 0;
  int _documentVersion = 0;
  bool _disposed = false;
  bool _healthy = true;
  FileViewerSource? _source;
  String? _optionsFingerprint;
  Map<String, Object?> _currentOptions = const {};
  String? _activeSourceId;
  FileViewerWarmupReport? warmupReport;

  Stream<FileViewerEvent> get events => _events.stream;
  bool get isHealthy => _healthy && !_disposed;
  Widget buildView(BuildContext context) => surface.buildView(context);

  Future<void> initialize() async {
    final stopwatch = Stopwatch()..start();
    try {
      await (() async {
        await surface.initialize(resources, _receive);
        await _ready.future;
      })().timeout(initializationTimeout);
      final result = await command('warmUp');
      final map = result is Map ? result : const {};
      warmupReport = FileViewerWarmupReport(
        shellReady: true,
        moduleReady: List<String>.from(map['moduleReady'] as List? ?? const []),
        engineReady: List<String>.from(map['engineReady'] as List? ?? const []),
        elapsed: stopwatch.elapsed,
      );
    } catch (_) {
      await dispose();
      rethrow;
    }
  }

  void _receive(Map<String, dynamic> message) {
    if (_disposed) return;
    if (message['protocolVersion'] != 1) {
      _fail(
        const FileViewerException(
          FileViewerErrorCode.protocol,
          'Incompatible viewer bridge protocol.',
        ),
      );
      return;
    }
    if (message['type'] == 'shellReady') {
      if (!_ready.isCompleted) _ready.complete();
    } else if (message['type'] == 'response') {
      final completion = _pending.remove(message['id']);
      if (completion == null) return;
      if (message['ok'] == true) {
        completion.complete(message['result']);
      } else {
        final error = message['error'] as Map? ?? const {};
        final code =
            FileViewerErrorCode.values
                .where((value) => value.name == error['code'])
                .firstOrNull ??
            FileViewerErrorCode.loadFailed;
        completion.completeError(
          FileViewerException(
            code,
            error['message'] as String? ?? 'Viewer operation failed.',
          ),
        );
      }
    } else if (message['type'] == 'surfaceError') {
      _fail(
        FileViewerException(
          FileViewerErrorCode.loadFailed,
          message['message'] as String? ?? 'The viewer could not start.',
        ),
      );
    } else if (message['type'] == 'surfaceTerminated') {
      _fail(
        const FileViewerException(
          FileViewerErrorCode.loadFailed,
          'The viewer process exited. Recreate the viewer to recover.',
        ),
      );
      _events.add(const FileViewerEvent(type: 'surfaceTerminated'));
    } else if (message['documentVersion'] == null ||
        message['documentVersion'] == _documentVersion) {
      _events.add(FileViewerEvent.fromJson(message));
    }
  }

  void _fail(FileViewerException error) {
    _healthy = false;
    if (!_ready.isCompleted) _ready.completeError(error);
    for (final completion in _pending.values) {
      completion.completeError(error);
    }
    _pending.clear();
  }

  @override
  Future<Object?> command(
    String method, [
    Map<String, Object?> arguments = const {},
  ]) async {
    if (!isHealthy) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Viewer session is no longer available.',
      );
    }
    final requestId = ++_sequence;
    final completion = Completer<Object?>();
    _pending[requestId] = completion;
    final result = completion.future.timeout(const Duration(seconds: 60));
    try {
      unawaited(
        Future.sync(
          () => surface.dispatch({
            'protocolVersion': 1,
            'id': requestId,
            'method': method,
            'documentVersion': _documentVersion,
            'arguments': arguments,
          }),
        ).then<void>(
          (_) {},
          onError: (Object error, StackTrace stack) {
            final pending = _pending.remove(requestId);
            if (pending != null && !pending.isCompleted) {
              pending.completeError(error, stack);
            }
          },
        ),
      );
      return await result;
    } finally {
      _pending.remove(requestId);
    }
  }

  @override
  Future<void> load(
    FileViewerSource source, {
    Map<String, Object?>? options,
  }) async {
    if (!isHealthy) {
      throw const FileViewerException(
        FileViewerErrorCode.disposed,
        'Viewer session is no longer available.',
      );
    }
    final effectiveOptions = options ?? _currentOptions;
    final fingerprint = jsonEncode(effectiveOptions);
    if (source == _source && fingerprint == _optionsFingerprint) return;
    if (source == _source) {
      final version = _documentVersion;
      await command('updateOptions', {'options': effectiveOptions});
      if (version == _documentVersion) {
        _currentOptions = Map.unmodifiable(effectiveOptions);
        _optionsFingerprint = fingerprint;
      }
      return;
    }
    final version = ++_documentVersion;
    final sourceId = '$id-$version';
    final previous = _activeSourceId;
    _currentOptions = Map.unmodifiable(effectiveOptions);
    _source = null;
    _optionsFingerprint = null;
    try {
      final input = await resources.registerSource(sourceId, source);
      if (version != _documentVersion || _disposed) {
        await resources.releaseSource(sourceId);
        throw const FileViewerException(
          FileViewerErrorCode.cancelled,
          'Source was replaced before loading.',
        );
      }
      _activeSourceId = sourceId;
      await command('load', {...input, 'options': effectiveOptions});
      if (version == _documentVersion) {
        _source = source;
        _optionsFingerprint = fingerprint;
      }
    } catch (_) {
      await resources.releaseSource(sourceId);
      if (_activeSourceId == sourceId) _activeSourceId = null;
      rethrow;
    } finally {
      if (previous != null) await resources.releaseSource(previous);
    }
  }

  @override
  Future<void> clear() async {
    final previous = _activeSourceId;
    ++_documentVersion;
    _source = null;
    _optionsFingerprint = null;
    _activeSourceId = null;
    try {
      if (isHealthy) await command('clear');
    } finally {
      if (previous != null) await resources.releaseSource(previous);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _fail(
      const FileViewerException(
        FileViewerErrorCode.disposed,
        'Viewer session was disposed.',
      ),
    );
    _disposed = true;
    _source = null;
    _currentOptions = const {};
    _optionsFingerprint = null;
    if (_activeSourceId case final sourceId?) {
      await resources.releaseSource(sourceId);
    }
    _activeSourceId = null;
    try {
      await surface.dispose().timeout(disposalTimeout);
    } on TimeoutException {
      /* A failed native process must not block recovery. */
    }
    await _events.close();
  }
}
