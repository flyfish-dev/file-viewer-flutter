import 'package:flutter/widgets.dart';

import '../resources/resource_host.dart';

typedef BridgeMessageHandler = void Function(Map<String, dynamic> message);

abstract interface class FileViewerSurface {
  Future<void> initialize(
    ViewerResourceHost resources,
    BridgeMessageHandler onMessage,
  );
  Widget buildView(BuildContext context);
  Future<void> dispatch(Map<String, Object?> message);
  Future<void> dispose();
}
