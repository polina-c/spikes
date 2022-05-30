// This library contains methods that should be invoked from DevTools with
// `eval`.

import 'package:memory_tools/src/_object_registry.dart';
import 'package:memory_tools/src/model.dart';

Leaks getLeaks() {
  return objectRegistry.collectLeaks();
}

Object? getNotGCedObject(int identityHashCode) {
  return objectRegistry.getNotGCedObject(identityHashCode);
}
