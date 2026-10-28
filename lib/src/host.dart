import 'dart:async';

import 'package:flutter/widgets.dart';

import 'runtime.dart';

class FileViewerHost extends StatefulWidget {
  const FileViewerHost({
    super.key,
    required this.child,
    this.runtime,
    this.onWarmupError,
  });

  final Widget child;
  final FileViewerRuntime? runtime;
  final void Function(Object error, StackTrace stack)? onWarmupError;

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
