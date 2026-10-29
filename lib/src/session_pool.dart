import 'dart:async';

/// A spare is reserved synchronously before awaiting it. Concurrent callers
/// therefore never receive the same native view, including during warm-up.
class ViewerSessionPool<T extends Object> {
  /// Creates a pool with explicit instance allocation and destruction callbacks.
  ViewerSessionPool({required this.create, required this.destroy});

  /// Allocates a new exclusive instance when no spare is available.
  final Future<T> Function() create;

  /// Permanently releases an instance removed from the pool.
  final Future<void> Function(T) destroy;
  final _owned = <T>{};
  final _leased = <T>{};
  final _creating = <Future<T>>{};
  Future<T>? _spare;
  bool _disposed = false;

  /// Number of instances currently leased to consumers.
  int get leasedCount => _leased.length;

  /// Number of initialized instances owned by this pool, including its spare.
  int get ownedCount => _owned.length;

  /// Whether a completed or pending instance is reserved as the spare.
  bool get hasSpare => _spare != null;

  /// Snapshot of initialized instances; modifying it cannot mutate the pool.
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

  /// Initializes a spare, or reuses existing initialization without leasing it.
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

  /// Exclusively leases the spare or a newly allocated instance.
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

  /// Returns [item], retaining at most one spare when [retain] is true.
  Future<void> release(T item, {bool retain = true}) async {
    if (!_leased.remove(item)) return;
    if (!_disposed && retain && _spare == null) {
      _spare = Future.value(item);
    } else if (_owned.remove(item)) {
      await destroy(item);
    }
  }

  /// Destroys the spare while leaving leased instances untouched.
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

  /// Permanently closes the pool and destroys its initialized instances.
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
