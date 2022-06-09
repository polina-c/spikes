import 'package:meta/meta.dart';

import '../model.dart';

enum GCEvent {
  oldGC,
  newGC,
}

/// Keeps timeline of GC cycles.
///
/// In the current implementation, an unreachable new-space object can require
/// up to two new-space GC followed by an old-space GC to be reclaimed
/// (to break an intergenerational cycle), and an unreachable old-space object
/// can require up to two old-space GCs to be reclaimed (can be floating
/// garbage captured by the incremental barrier).
class GCTime {
  int _cyclesPassed = 0;

  static const _cycleEvents = [
    GCEvent.newGC,
    GCEvent.oldGC,
    GCEvent.newGC,
    GCEvent.oldGC
  ];
  int _eventsPassed = 0;

  void registerGCEvent(Set<GCEvent> event) {
    if (event.contains(_cycleEvents[_eventsPassed])) _eventsPassed++;
    if (_eventsPassed == _cycleEvents.length) {
      _cyclesPassed++;
      _eventsPassed = 0;
    }
  }

  /// Number of current GC cycle.
  GCMoment get now => _cyclesPassed + 1;

  @visibleForTesting
  void reset() {
    _cyclesPassed = 0;
    _eventsPassed = 0;
  }
}
