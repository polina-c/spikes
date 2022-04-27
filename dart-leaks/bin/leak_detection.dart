// This is demo how leak detection works.
// To run: `dart bin/leak_detection.dart`

import 'package:memory_tools/leak_detector.dart';

class MyClass {
  late final leakDetector;
  late String name;

  MyClass(Object token) {
    leakDetector = LeakDetector(this, token: token);
    name = 'class-with-token-[$token]';
  }

  void dispose() {
    leakDetector.registerDisposal();
  }
}

// Method that allocates, but does not dispose objects.
void createAndNotDispose() {
  final notDisposed = MyClass('Not disposed.');
  // notDisposed.dispose();
}

final oldSpaceObjects = <Object>[];

// We need method that allocates objects, to trigger GC.
void doSomeAllocationsInOldAndNewSpace() {
  List<DateTime> l = List.filled(100, DateTime.now());
  oldSpaceObjects.add(l);
  if (l.length > 100) oldSpaceObjects.removeAt(0);
}

void main() async {
  createAndNotDispose();

  final notGCed = MyClass('Not GCed');
  notGCed.dispose();

  // Wait for GC to trigger.
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    doSomeAllocationsInOldAndNewSpace();
  }
}
