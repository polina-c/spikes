import 'package:logging/logging.dart';

import '_config.dart';
import '_gc_time.dart';
import 'leaks.dart';
import '_config.dart' as config;
import 'package:meta/meta.dart';

final objectRegistry = ObjectRegistry();

Object _getToken(Object object, Object? token) =>
    token ?? identityHashCode(object);

/// Global registry for the objects, which we want to track for leaking.
@visibleForTesting
class ObjectRegistry {
  late Finalizer<Object> _finalizer;
  late GCTime _gcTime;

  final _notGCed = <Object, ObjectInfo>{};
  final _gcedLateLeaks = <ObjectInfo>{};
  final _gcedNotDisposedLeaks = <ObjectInfo>{};

  /// The parameters are injected for testing purposes.
  ObjectRegistry({
    Finalizer<Object> Function(Function(Object token) gcEventHandler)?
        finalizerBuilder,
    GCTime? gcTime,
  }) {
    finalizerBuilder ??= (handler) => Finalizer<Object>(handler);
    _finalizer = finalizerBuilder(_objectGarbageCollected);

    _gcTime = gcTime ?? GCTime();
  }

  @visibleForTesting
  void reset() {
    _gcTime.reset();

    _notGCed.clear();
    _gcedLateLeaks.clear();
    _gcedNotDisposedLeaks.clear();
  }

  void _objectGarbageCollected(Object token) {
    final info = _notGCed[token];
    if (info == null) {
      throw '$token garbage collected twice.';
    }
    _assertIntegrity(info);

    config.logger.fine('$token: GCed.');
    info.setGCed(_gcTime.now);

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
      config.objectLocationGetter(object),
      object.runtimeType,
    );

    _notGCed[token] = info;
    _assertIntegrity(info);
  }

  void registerDisposal(Object object, Object? token) {
    token = _getToken(object, token);
    config.logger.fine('$token: disposed.');
    final info = _notGCed[token]!;
    _assertIntegrity(info);

    info.setDisposed(_gcTime.now);

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
              (info.gced! - info.disposed! >= cyclesToDeclareLeakIfNotGCed)),
      '${_gcedLateLeaks.contains(info)}, ${info.isDisposed}, ${info.isGCed},'
      ' ${info.gced} - ${info.disposed} < ${cyclesToDeclareLeakIfNotGCed}',
    );

    assert(
        _gcedNotDisposedLeaks.contains(info) ==
            (info.isGCed && !info.isDisposed),
        '${_gcedNotDisposedLeaks.contains(info)}, ${info.isGCed}, ${!info.isDisposed}');
  }

  LeakSummary collectLeaksSummary() {
    _assertIntegrityForAll();

    final notGCedLeaksCount =
        _notGCed.values.where((info) => info.isNotGCedLeak(_gcTime.now)).length;

    return LeakSummary({
      LeakType.notDisposed: _gcedNotDisposedLeaks.length,
      LeakType.notGCed: notGCedLeaksCount,
      LeakType.gcedLate: _gcedLateLeaks.length,
    });
  }

  Leaks collectLeaks() {
    final notGCedLeaks =
        _notGCed.values.where((info) => info.isNotGCedLeak(_gcTime.now));
    return Leaks(
      notDisposed: _gcedNotDisposedLeaks.toList(),
      notGCed: notGCedLeaks.toList(),
      gcedLate: _gcedLateLeaks.toList(),
    );
  }

  void _assertIntegrityForAll() {
    for (var info in _notGCed.values) _assertIntegrity(info);
    for (var info in _gcedLateLeaks) _assertIntegrity(info);
    for (var info in _gcedNotDisposedLeaks) _assertIntegrity(info);
  }

  void registerGCEvent({required bool oldSpace, required bool newSpace}) {
    _gcTime.registerGCEvent({
      if (oldSpace) GCEvent.oldGC,
      if (newSpace) GCEvent.newGC,
    });
    if (_notGCed.length == 0) return;
  }

  void logStatus(Level level) {
    logger.log(
        level, 'status: gc time: ${_gcTime.now}, not GCed: ${_notGCed.length}');
  }
}
