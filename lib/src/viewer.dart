import 'dart:async';

import 'package:flutter/material.dart';

import 'controller.dart';
import 'host.dart';
import 'models.dart';
import 'runtime.dart';
import 'session.dart';
import 'source.dart';

class FileViewer extends StatefulWidget {
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

  final FileViewerSource source;
  final FileViewerController? controller;
  final FileViewerRuntime? runtime;
  final String theme;
  final String locale;

  /// Initial layout policy. Auto uses the shared renderer's format-specific
  /// fit, follows viewport changes until interaction, and preserves manual zoom.
  final String fit;
  final bool retainSession;
  final FileViewerEventCallback? onEvent;
  final void Function(Object error)? onError;
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
