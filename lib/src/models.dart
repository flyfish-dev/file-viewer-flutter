import 'package:flutter/foundation.dart';

enum FileViewerRuntimeState { cold, booting, ready, recovering, disposed }

enum FileViewerErrorCode {
  initialization,
  missingResources,
  incompatibleRuntime,
  unsupportedSource,
  unsupportedOperation,
  sourceUnavailable,
  loadFailed,
  cancelled,
  disposed,
  protocol,
}

@immutable
class FileViewerException implements Exception {
  const FileViewerException(this.code, this.message, {this.cause});

  final FileViewerErrorCode code;
  final String message;
  final Object? cause;

  @override
  String toString() => 'FileViewerException(${code.name}): $message';
}

@immutable
class FileViewerEvent {
  const FileViewerEvent({required this.type, this.payload});

  final String type;
  final Object? payload;

  factory FileViewerEvent.fromJson(Map<String, dynamic> json) =>
      FileViewerEvent(type: json['type'] as String, payload: json['payload']);
}

@immutable
class FileViewerCapabilities {
  const FileViewerCapabilities(this.operations);

  final Map<String, Object?> operations;

  bool supports(String operation) {
    final value = operations[operation];
    return value == true || (value is Map && value['available'] == true);
  }
}

@immutable
class FileViewerWarmupReport {
  const FileViewerWarmupReport({
    required this.shellReady,
    required this.moduleReady,
    required this.engineReady,
    required this.elapsed,
  });

  final bool shellReady;
  final List<String> moduleReady;
  final List<String> engineReady;
  final Duration elapsed;
}

typedef FileViewerEventCallback = void Function(FileViewerEvent event);
