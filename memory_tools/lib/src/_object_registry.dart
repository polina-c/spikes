import 'primitives.dart';

import '_globals.dart' as config;
import '_reporter.dart';

import '_utils.dart' as utils;

final objectRegistry = _ObjectRegistry();

Object _getToken(Object object, Object? token) =>
    token ?? '${object.runtimeType}.${identityHashCode(object)}';

/// Global registry for the objects, which we want to track for leaking.
class _ObjectRegistry {
  late Finalizer<Object> _finalizer;

  final _notGCed = <Object, ObjectInfo>{};
  final _gcedLateLeaks = <ObjectInfo>{};
  final _gcedNotDisposedLeaks = <ObjectInfo>{};

  _ObjectRegistry() {
    _finalizer = Finalizer(_objectGarbageCollected);
  }

  void _objectGarbageCollected(Object token) {
    final info = _notGCed[token];
    if (info == null) {
      throw '$token garbage collected twice.';
    }
    _assertIntegrity(info);

    config.logger.fine('$token: GCed.');
    info.setGCedNow();

    _notGCed.remove(token);
    if (info.isGCedLateLeak) {
      _gcedLateLeaks.add(info);
    } else if (info.isNotDisposedLeak) {
      _gcedNotDisposedLeaks.add(info);
    }

    _assertIntegrity(info);
  }

  startTracking(Object object, Object? token) {
    token = _getToken(object, token);
    config.logger.fine('$token: started tracking.');
    assert(!_notGCed.containsKey(token));
    _finalizer.attach(object, token);

    ObjectInfo info = ObjectInfo(
      token,
      DateTime.now(),
      config.objectLocationGetter(object),
    );

    _notGCed[token] = info;
    _assertIntegrity(info);
  }

  void registerDisposal(Object object, Object? token) {
    token = _getToken(object, token);
    config.logger.fine('$token: disposed.');
    final info = _notGCed[token]!;
    _assertIntegrity(info);

    info.setDisposedNow();

    _assertIntegrity(info);
  }

  void _assertIntegrity(ObjectInfo info) {
    if (_notGCed.containsKey(info.token)) {
      assert(_notGCed[info.token]!.token == info.token);
      assert(!info.isGCed);
    }

    assert(
      _gcedLateLeaks.contains(info) ==
          (info.isDisposed &&
              info.isGCed &&
              (info.gced! - info.disposed! > config.timeToGC)),
      '${_gcedLateLeaks.contains(info)}, ${info.isDisposed}, ${info.isGCed},'
      ' ${info.gced} - ${info.disposed} > ${config.timeToGC}',
    );

    assert(
        _gcedNotDisposedLeaks.contains(info) ==
            (info.isGCed && !info.isDisposed),
        '${_gcedNotDisposedLeaks.contains(info)}, ${info.isGCed}, ${!info.isDisposed}');
  }

  Leaks collectLeaks() {
    _assertIntegrityForAll();

    final notGCedLeaks = _notGCed.values.where((info) => info.isNotGCedLeak);

    return Leaks(
      [...notGCedLeaks],
      [..._gcedNotDisposedLeaks],
      [..._gcedLateLeaks],
    );
  }

  void _assertIntegrityForAll() {
    for (var info in _notGCed.values) _assertIntegrity(info);
    for (var info in _gcedLateLeaks) _assertIntegrity(info);
    for (var info in _gcedNotDisposedLeaks) _assertIntegrity(info);
  }
}
