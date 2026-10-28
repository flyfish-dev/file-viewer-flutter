import 'dart:async';

import 'package:file_viewer_flutter/src/platform/surface.dart';
import 'package:file_viewer_flutter/src/resources/resource_host.dart';
import 'package:file_viewer_flutter/src/source.dart';
import 'package:flutter/widgets.dart';

class FakeResourceHost implements ViewerResourceHost {
  final sources = <String, FileViewerSource>{};
  bool disposed = false;
  @override
  Map<String, String> get assetBases => {
    'base': 'http://localhost:1234/assets/',
  };
  @override
  Uri get shellUri => Uri.parse('http://localhost:1234/assets/index.html');
  @override
  Future<void> initialize() async {}
  @override
  Future<Map<String, Object?>> registerSource(
    String id,
    FileViewerSource source,
  ) async {
    sources[id] = source;
    return {
      'url': 'http://localhost:1234/documents/$id',
      'filename': source.filename,
    };
  }

  @override
  Future<void> releaseSource(String id) async {
    sources.remove(id);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    sources.clear();
  }
}

class FakeSurface implements FileViewerSurface {
  FakeSurface({
    this.id = 0,
    this.initialization,
    this.onDispatch,
    this.disposal,
  });
  final int id;
  final Future<void>? initialization;
  final Future<void>? disposal;
  final FutureOr<void> Function(
    Map<String, Object?> message,
    FakeSurface surface,
  )?
  onDispatch;
  late BridgeMessageHandler receive;
  final requests = <Map<String, Object?>>[];
  int disposals = 0;
  @override
  Future<void> initialize(
    ViewerResourceHost resources,
    BridgeMessageHandler onMessage,
  ) async {
    receive = onMessage;
    if (initialization != null) await initialization;
    receive({'protocolVersion': 1, 'type': 'shellReady'});
  }

  void respond(Map<String, Object?> request, {Object? result, String? error}) {
    receive({
      'protocolVersion': 1,
      'type': 'response',
      'id': request['id'],
      'ok': error == null,
      if (error == null) 'result': result,
      if (error != null) 'error': {'code': 'loadFailed', 'message': error},
    });
  }

  @override
  Future<void> dispatch(Map<String, Object?> message) async {
    requests.add(message);
    if (message['method'] == 'warmUp') {
      respond(
        message,
        result: {
          'moduleReady': ['pdf'],
          'engineReady': [],
        },
      );
    } else if (onDispatch != null) {
      await onDispatch!(message, this);
    } else {
      respond(message);
    }
  }

  @override
  Widget buildView(BuildContext context) => Text('surface-$id');
  @override
  Future<void> dispose() async {
    disposals++;
    if (disposal != null) await disposal;
  }
}
