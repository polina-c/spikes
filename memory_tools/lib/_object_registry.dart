import 'dart:async';

import '_leak_reporter.dart';

import '_primitives.dart';

/// Global registry for the objects, which we want to track for leaking.
class ObjectRegistry {
  static const _timeToGC = Duration(seconds: 30);
  static const _reportingPeriod = Duration(seconds: 1);
  final _disposedNotGCed = <Object, DateTime>{};
  final _notDisposedLeaks = <NotDisposedLeak>[];
  late Timer _timer;

  ObjectRegistry() {
    _timer = Timer.periodic(_reportingPeriod, _collectAndReportLeaks);
  }

  void registerDisposal(Object token) {
    assert(
      !_disposedNotGCed.containsKey(token),
      'Disposal for the object $token is registered twice.',
    );
    _disposedNotGCed[token] = DateTime.now();
  }

  void registerGC(Object token) {
    if (!_disposedNotGCed.containsKey(token)) {
      _notDisposedLeaks.add(NotDisposedLeak(token));
    }
    _disposedNotGCed.remove(token);
  }

  void _collectAndReportLeaks(Timer timer) {
    final now = DateTime.now();

    bool shouldBeGCed(Object token) =>
        _disposedNotGCed[token]!.add(_timeToGC).isBefore(now);

    final notGCedLeaks = _disposedNotGCed.keys
        .where((token) => shouldBeGCed(token))
        .map((token) => NotGCedLeak(token))
        .toList(growable: false);

    for (var leak in notGCedLeaks) {
      _disposedNotGCed.remove(leak.token);
    }

    reportLeaks(notGCedLeaks, _notDisposedLeaks);
    _notDisposedLeaks.clear();
  }

  void dispose() => _timer.cancel();
}
