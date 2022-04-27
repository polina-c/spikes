import '_primitives.dart';

void reportLeaks(
  Iterable<NotGCedLeak> notGCed,
  Iterable<NotDisposedLeak> notDisposed,
) {
  if (notGCed.length > 0) {
    print('Detected ${notGCed.length} disposed but not GCed object(s):');
    for (var leak in notGCed) print('  ${leak.token}');
  }
  if (notDisposed.length > 0) {
    print('Detected ${notDisposed.length} GCed but not disposed objects(s):');
    for (var leak in notDisposed) print('  ${leak.token}');
  }
}
