import 'primitives.dart';

import '_globals.dart';
import '_reporter.dart';

import '_utils.dart' as utils;

final objectRegistry = _ObjectRegistry();

Object _getToken(Object object, Object? token) =>
    token ?? '${object.runtimeType}.${identityHashCode(object)}';

/// Global registry for the objects, which we want to track for leaking.
class _ObjectRegistry {
  late Finalizer<Object> _finalizer;
  final _objects = <Object, ObjectInfo>{};
  final _disposedNotGCed = <Object>{};
  final _notDisposedLeaks = <Leak>[];

  _ObjectRegistry() {
    _finalizer = Finalizer(_objectGarbageCollected);
  }

  void _objectGarbageCollected(Object token) {
    final info = _objects[token]!;
    logger.fine('$token: GCed.');
    info.gcedAfter = DateTime.now().difference(info.registrationTime);
    if (!_disposedNotGCed.contains(token)) {
      _notDisposedLeaks.add(Leak(token, _objects[token]!));
    }
    _disposedNotGCed.remove(token);
  }

  startTracking(Object object, Object? token) {
    token = _getToken(object, token);
    logger.fine('$token: started tracking.');
    _finalizer.attach(object, token);
    _objects[token] = ObjectInfo(
      DateTime.now(),
      utils.getCreationLocation(object),
      utils.getCallStack(),
    );
  }

  void registerDisposal(Object object, Object? token) {
    token = _getToken(object, token);
    logger.fine('$token: disposed.');
    assert(
      !_disposedNotGCed.contains(token),
      'Disposal for the object $token is registered twice.',
    );
    _disposedNotGCed.add(token);

    final info = _objects[token]!;
    info.disposedAfter = DateTime.now().difference(info.registrationTime);
    info.disposalCallStack = utils.getCallStack();
  }

  Leaks collectAndReportLeaks() {
    final result = collectLeaks();
    reportLeaks(result);
    return result;
  }

  Leaks collectLeaks() {
    final now = DateTime.now();

    bool shouldBeGCed(Object token) =>
        _objects[token]!.registrationTime.add(timeToGC).isBefore(now);

    final notGCedLeaks = _disposedNotGCed
        .where((token) => shouldBeGCed(token))
        .map((token) => Leak(token, _objects[token]!))
        .toList(growable: false);

    for (var leak in notGCedLeaks) {
      _disposedNotGCed.remove(leak.token);
    }

    final notDisposed = [..._notDisposedLeaks];
    _notDisposedLeaks.clear();

    return Leaks(notGCedLeaks, notDisposed);
  }
}
