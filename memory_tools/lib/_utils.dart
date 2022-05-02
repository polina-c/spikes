import 'package:intl/intl.dart';

final _oldSpaceObjects = <Object>[];

// We need method that allocates objects, to trigger GC.
void _doSomeAllocationsInOldAndNewSpace() {
  final l = List.filled(1000, DateTime.now());
  _oldSpaceObjects.add(l);
  if (_oldSpaceObjects.length > 100) _oldSpaceObjects.removeAt(0);
}

const timeToGC = Duration(seconds: 30);

Future<void> forceGC() async {
  final start = DateTime.now();
  printWithTime('Started waiting for GC.');

  while (DateTime.now().isBefore(start.add(timeToGC))) {
    await Future.delayed(Duration(seconds: 1));
    _doSomeAllocationsInOldAndNewSpace();
  }
}

final DateFormat _formatter = DateFormat.Hms();
void printWithTime(String text) {
  print('${_formatter.format(DateTime.now())} $text');
}
