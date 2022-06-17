import 'package:intl/intl.dart';
import 'package:memory_tools/src/_config.dart';

final DateFormat _formatter = DateFormat.Hms();
String timeForConsole(int timestamp) {
  return _formatter.format(DateTime.fromMicrosecondsSinceEpoch(timestamp));
}

String getCallStack() {
  return StackTrace.current.toString();
}

Future<void> forceGC() async {
  logger.fine('Started waiting for GC.');

  _gcValidator = List.filled(100, DateTime.now());
  final ref = WeakReference<Object>(_gcValidator!);
  await _doSomeAllocationsInOldAndNewSpace();
  _gcValidator = null;
  int count = 0;
  while (ref.target != null) {
    count++;
    await _doSomeAllocationsInOldAndNewSpace();
  }
  print('GC happened after $count iterations.');
  _oldSpaceObjects.clear();
}

Object? _gcValidator;
final _oldSpaceObjects = <Object>[];

// We need method that allocates objects, to trigger GC.
Future<void> _doSomeAllocationsInOldAndNewSpace() async {
  Iterable.generate(100).forEach((i) async {
    await Future.delayed(Duration(milliseconds: 10));
    final l = List.filled(10000, DateTime.now());
    _oldSpaceObjects.add(l);
    if (_oldSpaceObjects.length > 100) _oldSpaceObjects.removeAt(0);
  });
}
