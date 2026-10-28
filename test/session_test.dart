import 'dart:async';

import 'package:file_viewer_flutter/file_viewer_flutter.dart';
import 'package:file_viewer_flutter/src/session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  FileViewerSession session(FakeResourceHost resources, FakeSurface surface) =>
      FileViewerSession(id: 'test', surface: surface, resources: resources);

  test(
    'a renderer reclaimed while idle is automatically replaced on open',
    () async {
      final surfaces = <FakeSurface>[];
      final runtime = FileViewerRuntime(
        resourceHost: FakeResourceHost(),
        surfaceFactory: () {
          final surface = FakeSurface(id: surfaces.length);
          surfaces.add(surface);
          return surface;
        },
      );
      final first = await runtime.acquire();
      await runtime.release(first);
      surfaces.first.receive({
        'protocolVersion': 1,
        'type': 'surfaceTerminated',
      });
      final replacement = await runtime.acquire();
      expect(replacement, isNot(same(first)));
      expect(replacement.isHealthy, true);
      expect(surfaces.first.disposals, 1);
      await runtime.release(replacement);
      surfaces.last.receive({
        'protocolVersion': 1,
        'type': 'surfaceTerminated',
      });
      expect((await runtime.warmUp()).shellReady, true);
      expect(surfaces.length, 3);
      await runtime.shutdown();
    },
  );

  test(
    'logout revokes document handles in an unhealthy active session',
    () async {
      final host = FakeResourceHost();
      final surface = FakeSurface();
      final runtime = FileViewerRuntime(
        resourceHost: host,
        surfaceFactory: () => surface,
      );
      final active = await runtime.acquire();
      await active.load(const FileViewerSource.asset('private.txt'));
      surface.receive({'protocolVersion': 1, 'type': 'surfaceError'});
      await runtime.clearSessions();
      expect(host.sources, isEmpty);
      await runtime.shutdown();
    },
  );

  test(
    'close followed by the same source loads again and releases the old URL',
    () async {
      final host = FakeResourceHost();
      final surface = FakeSurface();
      final viewer = session(host, surface);
      await viewer.initialize();
      final controller = FileViewerController()..attach(viewer);
      const source = FileViewerSource.asset('sample.txt');
      await viewer.load(source);
      await controller.close();
      expect(host.sources, isEmpty);
      await controller.load(source);
      expect(
        surface.requests.where((request) => request['method'] == 'load').length,
        2,
      );
      expect(host.sources.length, 1);
      await viewer.dispose();
      controller.dispose();
    },
  );

  test(
    'a failed replacement cannot poison the previous source cache',
    () async {
      var fail = false;
      final host = FakeResourceHost();
      final surface = FakeSurface(
        onDispatch: (request, surface) =>
            surface.respond(request, error: fail ? 'broken' : null),
      );
      final viewer = session(host, surface);
      await viewer.initialize();
      const a = FileViewerSource.asset('a.txt'),
          b = FileViewerSource.asset('b.txt');
      await viewer.load(a);
      fail = true;
      await expectLater(viewer.load(b), throwsA(isA<FileViewerException>()));
      fail = false;
      await viewer.load(a);
      expect(
        surface.requests.where((request) => request['method'] == 'load').length,
        3,
      );
      expect(host.sources.values, [a]);
      await viewer.dispose();
    },
  );

  test('controller.load inherits theme and locale', () async {
    final host = FakeResourceHost();
    final surface = FakeSurface();
    final viewer = session(host, surface);
    await viewer.initialize();
    await viewer.load(
      const FileViewerSource.asset('a.txt'),
      options: {'theme': 'dark', 'locale': 'zh-CN'},
    );
    final controller = FileViewerController()..attach(viewer);
    await controller.load(const FileViewerSource.asset('b.txt'));
    expect((surface.requests.last['arguments'] as Map)['options'], {
      'theme': 'dark',
      'locale': 'zh-CN',
    });
    await viewer.dispose();
    controller.dispose();
  });

  test('fast bridge errors are observed before dispatch returns', () async {
    final viewer = session(
      FakeResourceHost(),
      FakeSurface(
        onDispatch: (request, surface) =>
            surface.respond(request, error: 'fast failure'),
      ),
    );
    await viewer.initialize();
    await expectLater(
      viewer.command('reload'),
      throwsA(isA<FileViewerException>()),
    );
    await viewer.dispose();
  });

  test('theme changes update the current document without another file URL or parse', () async {
    final host = FakeResourceHost();
    final surface = FakeSurface();
    final viewer = session(host, surface);
    await viewer.initialize();
    const source = FileViewerSource.asset('a.txt');
    await viewer.load(source, options: {'theme': 'light'});
    final originalId = host.sources.keys.single;
    await viewer.load(source, options: {'theme': 'dark'});
    expect(
      surface.requests.where((request) => request['method'] == 'load').length,
      1,
    );
    expect(surface.requests.last['method'], 'updateOptions');
    expect(host.sources.keys.single, originalId);
    await viewer.dispose();
    await expectLater(
      viewer.load(source, options: {'theme': 'dark'}),
      throwsA(isA<FileViewerException>()),
    );
  });

  test(
    'preloading a source preserves its parsed session for the next widget',
    () async {
      var created = 0;
      final surface = FakeSurface();
      final runtime = FileViewerRuntime(
        resourceHost: FakeResourceHost(),
        surfaceFactory: () {
          created++;
          return surface;
        },
      );
      const source = FileViewerSource.asset('upcoming.pdf');
      await runtime.preload(source);
      final viewer = await runtime.acquire();
      await viewer.load(
        source,
        options: {
          'locale': 'auto',
          'theme': 'system',
          'ui': {'density': 'compact'},
        },
      );
      expect(created, 1);
      expect(
        surface.requests.where((request) => request['method'] == 'load').length,
        1,
      );
      await runtime.release(viewer);
      await runtime.shutdown();
    },
  );

  test('the complete initialization and failed cleanup are bounded', () async {
    final never = Completer<void>();
    final surface = FakeSurface(
      initialization: never.future,
      disposal: never.future,
    );
    final viewer = FileViewerSession(
      id: 'test',
      surface: surface,
      resources: FakeResourceHost(),
      initializationTimeout: const Duration(milliseconds: 5),
      disposalTimeout: const Duration(milliseconds: 5),
    );
    await expectLater(viewer.initialize(), throwsA(isA<TimeoutException>()));
    expect(surface.disposals, 1);
    await viewer.dispose();
  });

  test(
    'runtime reset cancels an acquisition that was still initializing',
    () async {
      final initialization = Completer<void>();
      final surface = FakeSurface(initialization: initialization.future);
      final runtime = FileViewerRuntime(
        resourceHost: FakeResourceHost(),
        surfaceFactory: () => surface,
      );
      final pending = runtime.acquire();
      final assertion = expectLater(
        pending,
        throwsA(
          isA<FileViewerException>().having(
            (error) => error.code,
            'code',
            FileViewerErrorCode.cancelled,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await runtime.clearSessions();
      initialization.complete();
      await assertion;
      expect(surface.disposals, 1);
      expect(runtime.activeSessionCount, 0);
      await runtime.shutdown();
    },
  );
}
