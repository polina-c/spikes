import 'primitives.dart';

import '_globals.dart';
import '_reporter.dart';

import '_utils.dart';

final objectRegistry = ObjectRegistry();

Object _getToken(Object object, Object? token) =>
    token ?? '${object.runtimeType}.${identityHashCode(object)}';

/// Global registry for the objects, which we want to track for leaking.
class ObjectRegistry {
  late Finalizer<Object> _finalizer;
  final _disposedNotGCed = <Object, DateTime>{};
  final _notDisposedLeaks = <NotDisposedLeak>[];

  ObjectRegistry() {
    _finalizer = Finalizer(_objectGarbageCollected);
  }

  void _objectGarbageCollected(Object token) {
    logger.fine('$token: GCed.');
    if (!_disposedNotGCed.containsKey(token)) {
      _notDisposedLeaks.add(NotDisposedLeak(token));
    }
    _disposedNotGCed.remove(token);
  }

  startTracking(Object object, Object? token) {
    logger.fine('$token: started tracking.');
    token = _getToken(object, token);
    _finalizer.attach(object, token);
  }

  void registerDisposal(Object object, Object? token) {
    logger.fine('$token: disposed.');
    token = _getToken(object, token);
    assert(
      !_disposedNotGCed.containsKey(token),
      'Disposal for the object $token is registered twice.',
    );
    _disposedNotGCed[token] = DateTime.now();
  }

  Leaks collectAndReportLeaks() {
    final result = collectLeaks();
    reportLeaks(result);
    return result;
  }

  Leaks collectLeaks() {
    final now = DateTime.now();

    bool shouldBeGCed(Object token) =>
        _disposedNotGCed[token]!.add(timeToGC).isBefore(now);

    final notGCedLeaks = _disposedNotGCed.keys
        .where((token) => shouldBeGCed(token))
        .map((token) => NotGCedLeak(token))
        .toList(growable: false);

    for (var leak in notGCedLeaks) {
      _disposedNotGCed.remove(leak.token);
    }

    final notDisposed = [..._notDisposedLeaks];
    _notDisposedLeaks.clear();

    return Leaks(notGCedLeaks, notDisposed);
  }
}
