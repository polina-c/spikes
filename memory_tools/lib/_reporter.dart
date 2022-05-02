import 'primitives.dart';

import '_utils.dart';

void reportLeaks(
  Leaks leaks,
) {
  if (leaks.isEmpty) return;

  printWithTime('Detected leaks:');

  if (!leaks.notGCed.isEmpty) {
    print('  ${leaks.notGCed.length} disposed but not GCed object(s):');
    for (var leak in leaks.notGCed) print('    ${leak.token}');
  }
  if (!leaks.notDisposed.isEmpty) {
    print('  ${leaks.notDisposed.length} GCed but not disposed objects(s):');
    for (var leak in leaks.notDisposed) print('    ${leak.token}');
  }
}
