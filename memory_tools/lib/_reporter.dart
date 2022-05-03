import 'primitives.dart';

import '_utils.dart';
import '_globals.dart' as globals;

void reportLeaks(
  Leaks leaks,
) {
  if (leaks.isEmpty) return;

  print(
      'Detected ${leaks.notGCed.length} not GCed and ${leaks.notDisposed.length} not disposed.');

  if (!globals.detailedOutput) return;

  if (!leaks.notGCed.isEmpty) {
    print('  ${leaks.notGCed.length} disposed but not GCed object(s):');
    for (var leak in leaks.notGCed) print('    ${leak.token}');
  }
  if (!leaks.notDisposed.isEmpty) {
    print('  ${leaks.notDisposed.length} GCed but not disposed objects(s):');
    for (var leak in leaks.notDisposed) print('    ${leak.token}');
  }
}
