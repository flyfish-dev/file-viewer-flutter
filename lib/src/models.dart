import 'package:flutter/foundation.dart';

/// Lifecycle of an application's shared viewer runtime.
enum FileViewerRuntimeState {
  /// Resources and the spare viewer have not been initialized.
  cold,

  /// Resource initialization or shell warm-up is in progress.
  booting,

  /// A viewer shell is available; document engines may still initialize later.
  ready,

  /// Reserved for runtime recovery; do not use it as document readiness.
  recovering,

  /// The runtime has been permanently closed and cannot acquire viewers.
  disposed,
}

/// Machine-readable failure categories for initialization and document actions.
enum FileViewerErrorCode {
  /// Initialization failed, or a command was sent before attachment.
  initialization,

  /// A packaged offline resource is missing or has an invalid checksum.
  missingResources,

  /// The packaged resources do not match the supported runtime protocol.
  incompatibleRuntime,

  /// The source kind or URI scheme is unavailable on this platform.
  unsupportedSource,

  /// The current format or renderer cannot perform the requested action.
  unsupportedOperation,

  /// The document could not be read from its asset, path or network source.
  sourceUnavailable,

  /// The renderer could not load or parse the document.
  loadFailed,

  /// A newer load, reset or shutdown superseded an in-flight operation.
  cancelled,

  /// An operation targeted an object that has already been disposed.
  disposed,

  /// A command or response does not match the Dart/JavaScript bridge protocol.
  protocol,
}

/// A typed viewer failure, optionally retaining its original [cause].
@immutable
class FileViewerException implements Exception {
  /// Describes a failure with a stable [code] and human-readable [message].
  const FileViewerException(this.code, this.message, {this.cause});

  /// Category suitable for recovery decisions without parsing message text.
  final FileViewerErrorCode code;

  /// Human-readable diagnostic; it may contain source-specific information.
  final String message;

  /// Original platform, resource or renderer error, when available.
  final Object? cause;

  @override
  String toString() => 'FileViewerException(${code.name}): $message';
}

/// A lifecycle, operation or view-state notification from a viewer session.
@immutable
class FileViewerEvent {
  /// Creates an event with a protocol [type] and optional [payload].
  const FileViewerEvent({required this.type, this.payload});

  /// Event name, such as `ready`, `documentReady` or `view-state-change`.
  ///
  /// `ready` means commands can be sent. `documentReady` means the current
  /// document load completed; reset application readiness on each new load.
  final String type;

  /// Event-specific JSON-compatible details; its shape depends on [type].
  final Object? payload;

  /// Decodes an event envelope containing `type` and optional `payload` keys.
  factory FileViewerEvent.fromJson(Map<String, dynamic> json) =>
      FileViewerEvent(type: json['type'] as String, payload: json['payload']);
}

/// Availability of actions for the currently loaded document and platform.
@immutable
class FileViewerCapabilities {
  /// Wraps the renderer's operation-availability map.
  const FileViewerCapabilities(this.operations);

  /// Operation names mapped to booleans or records with an `available` flag.
  final Map<String, Object?> operations;

  /// Whether [operation] is available according to the current renderer.
  ///
  /// Unknown operations return false. Availability can change after loading
  /// another format or updating the view, so query it before exposing actions.
  bool supports(String operation) {
    final value = operations[operation];
    return value == true || (value is Map && value['available'] == true);
  }
}

/// Measured preparation of a viewer shell, modules and document engines.
///
/// Read each field independently: preparing a JavaScript module does not mean
/// its Worker or WASM engine has initialized for a document.
@immutable
class FileViewerWarmupReport {
  /// Creates a report from the stages actually observed by the runtime.
  const FileViewerWarmupReport({
    required this.shellReady,
    required this.moduleReady,
    required this.engineReady,
    required this.elapsed,
  });

  /// Whether the shell has established its command bridge.
  final bool shellReady;

  /// Format module identifiers that completed JavaScript module evaluation.
  final List<String> moduleReady;

  /// Engines whose initialization was measured; empty during module-only warm-up.
  final List<String> engineReady;

  /// Time spent preparing this session, excluding future document loading.
  final Duration elapsed;
}

/// Receives lifecycle and view-state events without transferring document bytes.
typedef FileViewerEventCallback = void Function(FileViewerEvent event);
