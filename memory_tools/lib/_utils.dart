import 'package:intl/intl.dart';
import 'package:memory_tools/_globals.dart';
import 'package:flutter/src/widgets/widget_inspector.dart';

final _oldSpaceObjects = <Object>[];

// We need method that allocates objects, to trigger GC.
void _doSomeAllocationsInOldAndNewSpace() {
  final l = List.filled(1000, DateTime.now());
  _oldSpaceObjects.add(l);
  if (_oldSpaceObjects.length > 100) _oldSpaceObjects.removeAt(0);
}

Future<void> forceGC() async {
  final start = DateTime.now();
  logger.fine('Started waiting for GC.');

  while (DateTime.now().isBefore(start.add(timeToGC))) {
    await Future.delayed(Duration(milliseconds: 10));
    _doSomeAllocationsInOldAndNewSpace();
  }
}

final DateFormat _formatter = DateFormat.Hms();
void printWithTime(String text) {
  print('${_formatter.format(DateTime.now())} $text');
}

String getCreationLocation(Object object) {
  return describeCreationLocation(object) ?? 'location-not-detected';
}

String getCallStack() {
  return StackTrace.current.toString();
}
