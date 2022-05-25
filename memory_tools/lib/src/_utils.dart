import 'package:intl/intl.dart';
import 'package:memory_tools/src/_config.dart';

final _oldSpaceObjects = <Object>[];

// We need method that allocates objects, to trigger GC.
void _doSomeAllocationsInOldAndNewSpace() {
  final l = List.filled(1000, DateTime.now());
  _oldSpaceObjects.add(l);
  if (_oldSpaceObjects.length > 100) _oldSpaceObjects.removeAt(0);
}

// Future<void> forceGC() async {
//   final start = DateTime.now();
//   logger.fine('Started waiting for GC.');
//
//   while (DateTime.now().isBefore(start.add(timeToGC))) {
//     await Future.delayed(Duration(milliseconds: 10));
//     _doSomeAllocationsInOldAndNewSpace();
//   }
// }

final DateFormat _formatter = DateFormat.Hms();
String timeForConsole(int timestamp) {
  return _formatter.format(DateTime.fromMicrosecondsSinceEpoch(timestamp));
}

String getCallStack() {
  return StackTrace.current.toString();
}
