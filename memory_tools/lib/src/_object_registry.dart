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
  final _notDisposedLeaks = <ObjectInfo>[];
  final _falsePositives = <Object>{};

  _ObjectRegistry() {
    _finalizer = Finalizer(_objectGarbageCollected);
  }

  void _objectGarbageCollected(Object token) {
    final info = _objects[token];
    if (info == null) {
      _falsePositives.add(token);
      return;
    }
    _assertIntegrity(info);

    logger.fine('$token: GCed.');
    info.setGCedNow();

    if (_disposedNotGCed.contains(token)) {
      _disposedNotGCed.remove(token);
    } else {
      assert(!info.isDisposed);
      _notDisposedLeaks.add(info);
    }

    _assertIntegrity(info);
  }

  startTracking(Object object, Object? token) {
    token = _getToken(object, token);
    logger.fine('$token: started tracking.');
    assert(!_objects.containsKey(token));
    _finalizer.attach(object, token);

    ObjectInfo info = ObjectInfo(
      token,
      DateTime.now(),
      utils.getCreationLocation(object),
      '', // utils.getCallStack(),
    );

    _objects[token] = info;
    _assertIntegrity(info);
  }

  void registerDisposal(Object object, Object? token) {
    token = _getToken(object, token);
    logger.fine('$token: disposed.');
    assert(
      !_disposedNotGCed.contains(token),
      'Disposal for the object $token is registered twice.',
    );
    final info = _objects[token]!;
    _assertIntegrity(info);

    _disposedNotGCed.add(token);
    info.setDisposedNow();
    // info.disposalCallStack = utils.getCallStack();

    _assertIntegrity(info);
  }

  Future<Leaks> forceGCandReportLeaks() async {
    await utils.forceGC();
    final result = collectLeaks();
    reportLeaks(result);
    return result;
  }

  Leaks collectLeaks() {
    _assertIntegrityForAll();
    final now = DateTime.now();

    bool shouldBeGCed(Object token) =>
        _objects[token]!.registrationTime.add(timeToGC).isBefore(now);

    final notGCedLeaks = _disposedNotGCed
        .where((token) => shouldBeGCed(token))
        .map((token) => _objects[token]!)
        .toList(growable: false);

    for (var leak in notGCedLeaks) {
      _disposedNotGCed.remove(leak.token);
      _objects.remove(leak.token);
    }

    final notDisposedLeaks = [..._notDisposedLeaks];
    _notDisposedLeaks.clear();
    for (var leak in notDisposedLeaks) assert(!leak.isDisposed);

    final falsePositives = [..._falsePositives];
    _falsePositives.clear();

    _assertIntegrityForAll();
    return Leaks(notGCedLeaks, notDisposedLeaks, falsePositives);
  }

  void _assertIntegrityForAll() {
    for (var info in _objects.values) _assertIntegrity(info);
  }

  void _assertIntegrity(ObjectInfo info) {
    assert(_objects[info.token]!.token == info.token);

    assert(
      _disposedNotGCed.contains(info.token) ==
          (info.isDisposed && !info.isGCed),
      '${_disposedNotGCed.contains(info.token)},${info.isDisposed},${info.isGCed}',
    );
  }
}
