import 'package:flutter/widgets.dart';

import '../resources/resource_host.dart';

/// Receives a decoded event or response from a platform's viewer bridge.
typedef BridgeMessageHandler = void Function(Map<String, dynamic> message);

/// Exclusive platform-view ownership and command transport for one session.
abstract interface class FileViewerSurface {
  /// Initializes the shell using [resources] and delivers events to [onMessage].
  Future<void> initialize(
    ViewerResourceHost resources,
    BridgeMessageHandler onMessage,
  );

  /// Builds the single widget permitted to display this surface at a time.
  Widget buildView(BuildContext context);

  /// Sends a JSON-compatible protocol envelope to the initialized shell.
  Future<void> dispatch(Map<String, Object?> message);

  /// Permanently releases this platform view and its bridge listeners.
  Future<void> dispose();
}
