import 'dart:async';

import 'package:flutter/material.dart';

import 'controller.dart';
import 'host.dart';
import 'models.dart';
import 'runtime.dart';
import 'session.dart';
import 'source.dart';

/// Displays a document inside the constraints supplied by its parent.
///
/// Place it in a bounded widget, such as an `Expanded` or `SizedBox`, and wrap
/// the application in [FileViewerHost] to reuse its runtime. Changing [source]
/// loads another document; removing the widget retains one reusable session by
/// default. Use [onEvent] to distinguish shell attachment from document readiness.
class FileViewer extends StatefulWidget {
  /// Creates a preview of [source] with optional control and lifecycle callbacks.
  const FileViewer({
    super.key,
    required this.source,
    this.controller,
    this.runtime,
    this.theme = 'system',
    this.locale = 'auto',
    this.fit = 'auto',
    this.retainSession = true,
    this.onEvent,
    this.onError,
    this.errorBuilder,
  });

  /// Original document to preview; changes trigger a new load.
  final FileViewerSource source;

  /// Optional controller owned and disposed by the application.
  ///
  /// Use a separate controller for each simultaneously mounted viewer.
  final FileViewerController? controller;

  /// Explicit runtime, otherwise inherited from [FileViewerHost.of].
  final FileViewerRuntime? runtime;

  /// Viewer chrome theme: `system`, `light` or `dark`.
  ///
  /// Document colors remain under the renderer's control.
  final String theme;

  /// Viewer UI locale, for example `en-US` or `zh-CN`; `auto` uses detection.
  ///
  /// This selects interface translations and does not translate file content.
  final String locale;

  /// Initial layout policy. Auto uses the shared renderer's format-specific
  /// fit, follows viewport changes until interaction, and preserves manual zoom.
  final String fit;

  /// Whether to retain the detached session for reuse when this widget leaves.
  ///
  /// Memory pressure may evict idle sessions. A native view can be attached to
  /// only one widget at a time; retained sessions are not background services.
  final bool retainSession;

  /// Receives runtime and document events, including `ready` and `documentReady`.
  ///
  /// Reset application readiness whenever starting a new document load.
  final FileViewerEventCallback? onEvent;

  /// Receives initialization or document-load failures shown by this widget.
  ///
  /// Controller operation failures are returned by their own futures instead.
  final void Function(Object error)? onError;

  /// Builds custom failure UI with a retry callback that recreates the session.
  ///
  /// When omitted, a centered diagnostic and Retry button are displayed.
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  FileViewerSession? _session;
  FileViewerRuntime? _runtime;
  StreamSubscription<FileViewerEvent>? _events;
  Object? _error;
  int _generation = 0;
  int _loadGeneration = 0;

  Map<String, Object?> get _options => {
    'locale': widget.locale,
    'theme': widget.theme,
    'fit': widget.fit,
    'ui': {'density': 'compact'},
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final runtime = widget.runtime ?? FileViewerHost.of(context);
    if (!identical(runtime, _runtime)) {
      _release();
      _runtime = runtime;
      unawaited(_attach());
    }
  }

  Future<void> _attach() async {
    final generation = ++_generation;
    final runtime = _runtime!;
    try {
      final session = await runtime.acquire();
      if (!mounted || generation != _generation) {
        await runtime.release(session);
        return;
      }
      _session = session;
      _events = session.events.listen((event) {
        if (!mounted || !identical(_session, session)) return;
        if (event.type == 'surfaceTerminated') {
          unawaited(_recover());
        }
        widget.onEvent?.call(event);
      });
      setState(() {
        _error = null;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted ||
          generation != _generation ||
          !identical(_session, session)) {
        return;
      }
      widget.controller?.attach(session);
      widget.onEvent?.call(const FileViewerEvent(type: 'ready'));
      await _load(session);
    } catch (error) {
      if (mounted && generation == _generation) _showError(error);
    }
  }

  void _showError(Object error) {
    setState(() {
      _error = error;
    });
    widget.onError?.call(error);
  }

  Future<void> _load(FileViewerSession session) async {
    final generation = ++_loadGeneration;
    try {
      await session.load(widget.source, options: _options);
      if (mounted &&
          identical(session, _session) &&
          generation == _loadGeneration) {
        widget.onEvent?.call(const FileViewerEvent(type: 'documentReady'));
      }
    } catch (error) {
      if (mounted &&
          identical(session, _session) &&
          generation == _loadGeneration &&
          !(error is FileViewerException &&
              error.code == FileViewerErrorCode.cancelled)) {
        _showError(error);
      }
    }
  }

  Future<void> _recover() async {
    _release(retain: false);
    if (mounted) {
      setState(() {
        _error = null;
      });
      await _attach();
    }
  }

  void _release({bool? retain}) {
    ++_generation;
    ++_loadGeneration;
    unawaited(_events?.cancel());
    _events = null;
    final session = _session;
    final runtime = _runtime;
    _session = null;
    if (session != null) {
      widget.controller?.detach(session);
      if (runtime != null) {
        final shouldRetain = retain ?? widget.retainSession;
        // The old platform view must leave the widget tree before its native
        // keep-alive token can be leased by a different route.
        unawaited(
          WidgetsBinding.instance.endOfFrame.then(
            (_) => runtime.release(session, retain: shouldRetain),
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(FileViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final session = _session;
    if (oldWidget.controller != widget.controller && session != null) {
      oldWidget.controller?.detach(session);
      widget.controller?.attach(session);
    }
    if (oldWidget.runtime != widget.runtime) {
      _release();
      _runtime = widget.runtime ?? FileViewerHost.of(context);
      unawaited(_attach());
    } else if (session != null &&
        (oldWidget.source != widget.source ||
            oldWidget.theme != widget.theme ||
            oldWidget.locale != widget.locale ||
            oldWidget.fit != widget.fit)) {
      setState(() {
        _error = null;
      });
      unawaited(_load(session));
    }
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      void retry() {
        unawaited(_recover());
      }

      return widget.errorBuilder?.call(context, error, retry) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(onPressed: retry, child: const Text('Retry')),
                ],
              ),
            ),
          );
    }
    final session = _session;
    return session == null
        ? const Center(child: CircularProgressIndicator())
        : KeyedSubtree(
            key: ObjectKey(session),
            child: session.buildView(context),
          );
  }
}
