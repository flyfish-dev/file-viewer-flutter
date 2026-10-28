import 'dart:async';

/// A spare is reserved synchronously before awaiting it. Concurrent callers
/// therefore never receive the same native view, including during warm-up.
class ViewerSessionPool<T extends Object> {
  ViewerSessionPool({required this.create, required this.destroy});

  final Future<T> Function() create;
  final Future<void> Function(T) destroy;
  final _owned = <T>{};
  final _leased = <T>{};
  final _creating = <Future<T>>{};
  Future<T>? _spare;
  bool _disposed = false;

  int get leasedCount => _leased.length;
  int get ownedCount => _owned.length;
  bool get hasSpare => _spare != null;
  Iterable<T> get instances => List.unmodifiable(_owned);

  Future<T> _create() async {
    final item = await create();
    if (_disposed) {
      await destroy(item);
      throw StateError('Session pool is disposed.');
    }
    _owned.add(item);
    return item;
  }

  Future<T> _newInstance() {
    late final Future<T> pending;
    pending = _create().whenComplete(() {
      _creating.remove(pending);
    });
    _creating.add(pending);
    return pending;
  }

  Future<T> prewarm() {
    if (_disposed) return Future.error(StateError('Session pool is disposed.'));
    final existing = _spare;
    if (existing != null) return existing;
    if (_owned.isNotEmpty) return Future.value(_owned.first);
    if (_creating.isNotEmpty) return _creating.first;
    final pending = _newInstance();
    _spare = pending;
    unawaited(
      pending.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {
          if (identical(_spare, pending)) _spare = null;
        },
      ),
    );
    return pending;
  }

  Future<T> acquire() async {
    if (_disposed) throw StateError('Session pool is disposed.');
    final pending = _spare;
    _spare = null;
    final item = await (pending ?? _newInstance());
    if (_disposed) throw StateError('Session pool is disposed.');
    if (!_leased.add(item)) {
      throw StateError('A viewer surface cannot be attached twice.');
    }
    return item;
  }

  Future<void> release(T item, {bool retain = true}) async {
    if (!_leased.remove(item)) return;
    if (!_disposed && retain && _spare == null) {
      _spare = Future.value(item);
    } else if (_owned.remove(item)) {
      await destroy(item);
    }
  }

  Future<void> trim() async {
    final pending = _spare;
    _spare = null;
    if (pending == null) return;
    try {
      final item = await pending;
      if (_owned.remove(item)) await destroy(item);
    } catch (_) {
      /* Failed prewarm owns no instance. */
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await trim();
    final items = _owned.toList();
    _owned.clear();
    _leased.clear();
    await Future.wait(items.map(destroy));
  }
}
