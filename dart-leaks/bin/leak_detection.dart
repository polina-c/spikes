// This is demo how leak detection works.
// To run: `dart bin/leak_detection.dart`

import 'package:dart_leaks/leak_detector.dart';

class MyClass {
  late final leakDetector;

  MyClass(Object token) {
    leakDetector = LeakDetector(this, token: token);
  }

  void dispose() {
    leakDetector.registerDisposal();
  }
}

// Method that allocates, but does not dispose objects.
void createAndNotDispose() {
  final myClass = MyClass("Not disposed.");
  // myClass.dispose();
}

// We need method that allocates objects, to trigger GC.
void doSomeAllocations() {
  List<DateTime> l = [DateTime.now()];
}

void main() async {
  createAndNotDispose();
  final myClass = MyClass('Not GCed');
  myClass.dispose();

  // Wait for GC to trigger.
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    doSomeAllocations();
  }
}
