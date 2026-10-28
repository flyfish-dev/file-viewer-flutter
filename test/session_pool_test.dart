import 'dart:async';

import 'package:file_viewer_flutter/src/session_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'concurrent acquisitions reserve a warming surface exclusively',
    () async {
      final creating = <Completer<Object>>[];
      final disposed = <Object>[];
      final pool = ViewerSessionPool<Object>(
        create: () {
          final item = Completer<Object>();
          creating.add(item);
          return item.future;
        },
        destroy: (item) async {
          disposed.add(item);
        },
      );
      final warm = pool.prewarm();
      final first = pool.acquire();
      final second = pool.acquire();
      expect(creating.length, 2);
      final a = Object(), b = Object();
      creating[0].complete(a);
      creating[1].complete(b);
      expect(await warm, same(a));
      expect(await first, same(a));
      expect(await second, same(b));
      expect(pool.leasedCount, 2);
      await pool.release(a);
      await pool.release(b);
      expect(disposed, [b]);
      expect(await pool.acquire(), same(a));
      await pool.dispose();
      expect(disposed.toSet(), {a, b});
    },
  );

  test('host warm-up reuses an acquisition already initializing', () async {
    final creating = Completer<Object>();
    var count = 0;
    final pool = ViewerSessionPool<Object>(
      create: () {
        count++;
        return creating.future;
      },
      destroy: (_) async {},
    );
    final acquisition = pool.acquire();
    final warm = pool.prewarm();
    expect(count, 1);
    final object = Object();
    creating.complete(object);
    expect(await warm, same(object));
    expect(await acquisition, same(object));
    expect(pool.leasedCount, 1);
    await pool.dispose();
  });

  test('memory trimming disposes only the idle surface', () async {
    final disposed = <Object>[];
    final pool = ViewerSessionPool<Object>(
      create: () async => Object(),
      destroy: (item) async {
        disposed.add(item);
      },
    );
    final active = await pool.acquire();
    final idle = await pool.acquire();
    await pool.release(idle);
    await pool.trim();
    expect(disposed, [idle]);
    expect(pool.leasedCount, 1);
    await pool.release(active, retain: false);
    expect(disposed, [idle, active]);
    await pool.dispose();
  });

  test('a native view completing after shutdown is destroyed', () async {
    final creating = Completer<Object>();
    final disposed = <Object>[];
    final pool = ViewerSessionPool<Object>(
      create: () => creating.future,
      destroy: (item) async {
        disposed.add(item);
      },
    );
    final pending = pool.acquire();
    final assertion = expectLater(pending, throwsStateError);
    await pool.dispose();
    final object = Object();
    creating.complete(object);
    await assertion;
    expect(disposed, [object]);
  });
}
