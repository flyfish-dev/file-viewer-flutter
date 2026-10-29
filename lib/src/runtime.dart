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

/// Owns offline resources and the pool of reusable viewer sessions.
///
/// Share one runtime through the application host. It retains a spare session
/// to reduce repeated shell loads, while [trimMemory] releases idle instances.
/// Listen to this notifier for [state] changes, and use [shutdown] for permanent
/// asynchronous cleanup of an application-owned instance.
class FileViewerRuntime extends ChangeNotifier {
  /// Creates an independent runtime using packaged platform resources by default.
  ///
  /// `resourceHost` and `surfaceFactory` are advanced integration and testing
  /// hooks; ordinary applications should leave both unset.
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

  /// Default application-scoped runtime used when no explicit runtime is supplied.
  ///
  /// Once shut down, this instance cannot be restarted; create a new runtime
  /// for a new application scope.
  static final FileViewerRuntime instance = FileViewerRuntime();
  final ViewerResourceHost _resources;
  final FileViewerSurface Function() _surfaceFactory;
  late final ViewerSessionPool<FileViewerSession> _pool;
  FileViewerRuntimeState _state = FileViewerRuntimeState.cold;
  Future<void>? _initializing;
  int _nextId = 0;
  int _epoch = 0;
  Future<void>? _closing;

  /// Current runtime lifecycle; distinct from the readiness of any document.
  FileViewerRuntimeState get state => _state;

  /// Number of sessions currently leased, excluding the retained idle spare.
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

  /// Prepares a spare viewer and returns the preparation stages actually measured.
  ///
  /// Concurrent calls reuse pool initialization. Module preparation does not
  /// initialize every document engine; use [preload] for a specific upcoming
  /// source. A failed warm-up can be retried unless the runtime is disposed.
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

  /// Leases one exclusive session for a mounted viewer or document preload.
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

  /// Returns a leased session, retaining it only when healthy and requested.
  @internal
  Future<void> release(FileViewerSession session, {bool retain = true}) =>
      _pool.release(session, retain: retain && session.isHealthy);

  /// Releases idle sessions while preserving sessions attached to active widgets.
  Future<void> trimMemory() => _pool.trim();

  /// Clears loaded documents in all sessions and releases idle viewer instances.
  ///
  /// Active widgets keep their session attachments, but their documents are
  /// unloaded. In-flight session acquisitions are cancelled by this reset.
  Future<void> clearSessions() async {
    ++_epoch;
    await Future.wait(_pool.instances.map((session) => session.clear()));
    await _pool.trim();
  }

  /// Forwards application background/foreground state to healthy sessions.
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

  /// Permanently disposes the runtime and waits for native/resource cleanup.
  ///
  /// Stop using associated viewer widgets and controllers before shutdown.
  /// Repeated calls return the same cleanup future.
  Future<void> shutdown() {
    dispose();
    return _closing!;
  }

  /// Starts permanent cleanup; use [shutdown] when cleanup must be awaited.
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
