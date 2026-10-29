import 'dart:async';

import 'package:flutter/widgets.dart';

import 'runtime.dart';

/// Shares an application's viewer runtime and starts warm-up after its first frame.
///
/// Place this near the application root. It forwards memory-pressure and
/// lifecycle notifications to the runtime, releasing idle sessions when needed.
/// It does not start an operating-system background service or guarantee that
/// a suspended process remains resident.
class FileViewerHost extends StatefulWidget {
  /// Wraps [child] and optionally uses an application-owned [runtime].
  const FileViewerHost({
    super.key,
    required this.child,
    this.runtime,
    this.onWarmupError,
  });

  /// Application subtree that can obtain the shared runtime with [of].
  final Widget child;

  /// Runtime to share, defaulting to [FileViewerRuntime.instance].
  ///
  /// The host does not dispose it when removed. Call its `shutdown` method when
  /// permanently closing an application-owned runtime.
  final FileViewerRuntime? runtime;

  /// Receives asynchronous warm-up failures without replacing the application UI.
  ///
  /// A later viewer load can retry initialization. Avoid logging source secrets
  /// when handling underlying diagnostics.
  final void Function(Object error, StackTrace stack)? onWarmupError;

  /// Returns the nearest shared runtime, or [FileViewerRuntime.instance].
  ///
  /// Registers an inherited dependency when a host is present.
  static FileViewerRuntime of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_ViewerRuntimeScope>()
          ?.runtime ??
      FileViewerRuntime.instance;

  @override
  State<FileViewerHost> createState() => _FileViewerHostState();
}

class _FileViewerHostState extends State<FileViewerHost>
    with WidgetsBindingObserver {
  FileViewerRuntime get runtime => widget.runtime ?? FileViewerRuntime.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        runtime.warmUp().then<void>(
          (_) {},
          onError: (Object error, StackTrace stack) {
            widget.onWarmupError?.call(error, stack);
          },
        ),
      );
    });
  }

  @override
  void didHaveMemoryPressure() {
    unawaited(runtime.trimMemory());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(runtime.setBackgrounded(state != AppLifecycleState.resumed));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ViewerRuntimeScope(runtime: runtime, child: widget.child);
}

class _ViewerRuntimeScope extends InheritedWidget {
  const _ViewerRuntimeScope({required this.runtime, required super.child});
  final FileViewerRuntime runtime;

  @override
  bool updateShouldNotify(_ViewerRuntimeScope oldWidget) =>
      runtime != oldWidget.runtime;
}
