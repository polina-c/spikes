import 'package:memory_tools/_reporter.dart';

import '_object_registry.dart';

final _objectRegistry = ObjectRegistry();
final _finalizer = Finalizer(_objectGarbageCollected);

Object _getToken(Object object, Object? token) =>
    token ?? identityHashCode(object);

void _objectGarbageCollected(Object token) {
  _objectRegistry.registerGC(token);
}

startLeakDetector(Object object, {Object? token}) {
  _finalizer.attach(object, _getToken(object, token));
}

registerDisposal(Object object, {Object? token}) {
  _objectRegistry.registerDisposal(_getToken(object, token));
}

final _oldSpaceObjects = <Object>[];

// We need method that allocates objects, to trigger GC.
void _doSomeAllocationsInOldAndNewSpace() {
  final l = List.filled(1000, DateTime.now());
  _oldSpaceObjects.add(l);
  if (_oldSpaceObjects.length > 100) _oldSpaceObjects.removeAt(0);
}

void dispose() {
  _objectRegistry.dispose();
}

Future<void> forceGC() async {
  const wait = Duration(minutes: 1);
  final start = DateTime.now();
  printWithTime('Started waiting for GC.');

  while (DateTime.now().isBefore(start.add(wait))) {
    await Future.delayed(Duration(seconds: 1));
    _doSomeAllocationsInOldAndNewSpace();
  }
}
