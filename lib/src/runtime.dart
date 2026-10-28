import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';
import 'platform/factory.dart';
import 'platform/surface.dart';
import 'resources/resource_host.dart';
import 'resources/native_host.dart'
    if (dart.library.js_interop) 'resources/web_host.dart'
    as resources;
import 'session.dart';
import 'session_pool.dart';
import 'source.dart';

class FileViewerRuntime extends ChangeNotifier {
  FileViewerRuntime({
    ViewerResourceHost? resourceHost,
    FileViewerSurface Function()? surfaceFactory,
  }) : _resources = resourceHost ?? resources.createResourceHost(),
       _surfaceFactory = surfaceFactory ?? createViewerSurface {
    _pool = ViewerSessionPool(
      create: _createSession,
      destroy: (session) => session.dispose(),
    );
  }

  static final FileViewerRuntime instance = FileViewerRuntime();
  final ViewerResourceHost _resources;
  final FileViewerSurface Function() _surfaceFactory;
  late final ViewerSessionPool<FileViewerSession> _pool;
  FileViewerRuntimeState _state = FileViewerRuntimeState.cold;
  Future<void>? _initializing;
  int _nextId = 0;
  int _epoch = 0;
  Future<void>? _closing;

  FileViewerRuntimeState get state => _state;
  int get activeSessionCount => _pool.leasedCount;

  void _setState(FileViewerRuntimeState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> _initialize() {
    if (_state == FileViewerRuntimeState.disposed) {
      return Future.error(
        const FileViewerException(
          FileViewerErrorCode.disposed,
          'Runtime is disposed.',
        ),
      );
    }
    return _initializing ??= _resources.initialize();
  }

  Future<FileViewerSession> _createSession() async {
    await _initialize();
    final session = FileViewerSession(
      id: 'viewer-${++_nextId}',
      surface: _surfaceFactory(),
      resources: _resources,
    );
    await session.initialize();
    return session;
  }

  Future<FileViewerWarmupReport> warmUp() async {
    if (_state == FileViewerRuntimeState.cold) {
      _setState(FileViewerRuntimeState.booting);
    }
    try {
      var session = await _pool.prewarm();
      if (!session.isHealthy) {
        session = await acquire();
        await release(session);
      }
      if (_state != FileViewerRuntimeState.disposed) {
        _setState(FileViewerRuntimeState.ready);
      }
      return session.warmupReport!;
    } catch (_) {
      if (_state != FileViewerRuntimeState.disposed) {
        _setState(FileViewerRuntimeState.cold);
      }
      rethrow;
    }
  }

  /// Parse a known upcoming document in the spare viewer. Opening the same
  /// source/options then reuses its rendered session instead of parsing again.
  Future<void> preload(
    FileViewerSource source, {
    String theme = 'system',
    String locale = 'auto',
  }) async {
    final session = await acquire();
    try {
      await session.load(
        source,
        options: {
          'locale': locale,
          'theme': theme,
          'ui': {'density': 'compact'},
        },
      );
    } finally {
      await release(session);
    }
  }

  @internal
  Future<FileViewerSession> acquire() async {
    final epoch = _epoch;
    var session = await _pool.acquire();
    if (!session.isHealthy) {
      await _pool.release(session, retain: false);
      session = await _pool.acquire();
    }
    if (epoch != _epoch) {
      await _pool.release(session, retain: false);
      throw const FileViewerException(
        FileViewerErrorCode.cancelled,
        'Session acquisition was cancelled by a runtime reset.',
      );
    }
    return session;
  }

  @internal
  Future<void> release(FileViewerSession session, {bool retain = true}) =>
      _pool.release(session, retain: retain && session.isHealthy);

  Future<void> trimMemory() => _pool.trim();

  Future<void> clearSessions() async {
    ++_epoch;
    await Future.wait(_pool.instances.map((session) => session.clear()));
    await _pool.trim();
  }

  @internal
  Future<void> setBackgrounded(bool backgrounded) async {
    await Future.wait(
      _pool.instances.where((session) => session.isHealthy).map((
        session,
      ) async {
        try {
          await session.command(backgrounded ? 'pause' : 'resume');
        } catch (_) {
          /* A process may have been reclaimed. */
        }
      }),
    );
  }

  Future<void> shutdown() {
    dispose();
    return _closing!;
  }

  @override
  void dispose() {
    if (_state == FileViewerRuntimeState.disposed) return;
    _setState(FileViewerRuntimeState.disposed);
    _closing = () async {
      try {
        await _pool.dispose();
      } finally {
        await _resources.dispose();
      }
    }();
    _closing!.ignore();
    super.dispose();
  }
}
