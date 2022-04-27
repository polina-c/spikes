// This is demo how leak detection works.
// To run: `dart bin/leak_detection.dart`

import 'package:memory_tools/leak_detector.dart' as leak_detector;

class MyClass {
  Object _token;

  MyClass(this._token) {
    leak_detector.startLeakDetector(this, token: this._token);
  }

  void dispose() {
    leak_detector.registerDisposal(this, token: this._token);
  }
}

// Method that allocates, but does not dispose objects.
void createAndNotDispose() {
  final notDisposed = MyClass('not-disposed');
  // notDisposed.dispose();
}

final oldSpaceObjects = <Object>[];

// We need method that allocates objects, to trigger GC.
void doSomeAllocationsInOldAndNewSpace() {
  final l = List.filled(1000, DateTime.now());
  oldSpaceObjects.add(l);
  if (l.length > 100) oldSpaceObjects.removeAt(0);
}

void main() async {
  createAndNotDispose();

  final notGCed = MyClass('not-GCed');
  notGCed.dispose();

  // Wait for GC to trigger.
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    doSomeAllocationsInOldAndNewSpace();
  }
}
