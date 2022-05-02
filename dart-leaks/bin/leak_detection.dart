// This is demo how leak detection works.
// To run: `dart bin/leak_detection.dart`

import 'package:memory_tools/app_leak_detector.dart' as leak_detector;

class MyClass {
  Object _token;

  MyClass(this._token) {
    leak_detector.startTracking(this, token: this._token);
  }

  void dispose() {
    leak_detector.registerDisposal(this, token: this._token);
  }
}

// Method that allocates, but does not dispose objects.
void createAndNotDispose() {
  // ignore: unused_local_variable
  final notDisposed = MyClass('not-disposed');
  // notDisposed.dispose();
}

void main() async {
  createAndNotDispose();

  final notGCed = MyClass('not-GCed');
  notGCed.dispose();

  await leak_detector.wrapUp();
}
