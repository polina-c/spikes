// This library contains methods that should be invoked from DevTools with
// `eval`.

import 'package:memory_tools/src/_object_registry.dart';
import 'package:memory_tools/src/leaks.dart';

Leaks getLeaks() {
  return objectRegistry.collectLeaks();
}

Object? getObject(int identityHashCode) {
  return 'hello';
}
