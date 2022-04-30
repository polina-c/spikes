import '_primitives.dart';
import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat.Hms();

void reportLeaks(
  Iterable<NotGCedLeak> notGCed,
  Iterable<NotDisposedLeak> notDisposed,
) {
  if (notDisposed.isEmpty && notGCed.isEmpty) return;

  printWithTime('Detected leaks:');

  if (notGCed.length > 0) {
    print('  ${notGCed.length} disposed but not GCed object(s):');
    for (var leak in notGCed) print('    ${leak.token}');
  }
  if (notDisposed.length > 0) {
    print('  ${notDisposed.length} GCed but not disposed objects(s):');
    for (var leak in notDisposed) print('    ${leak.token}');
  }
}

void printWithTime(String text) {
  print('${formatter.format(DateTime.now())} $text');
}
