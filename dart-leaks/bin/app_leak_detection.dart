// This is demo how leak detection works.
// To run: `dart bin/app_leak_detection.dart`

import 'package:dart_leaks/tracked_class.dart';
import 'package:memory_tools/app_leak_detector.dart' as leak_detector;

/// Method that allocates, but does not dispose objects.
void createAndNotDispose() {
  // ignore: unused_local_variable
  final notDisposed = MyTrackedClass('not-disposed');
  // notDisposed.dispose();
}

void main() async {
  leak_detector.init(fileName: 'leaks_from_test_app.yaml');

  createAndNotDispose();

  final notGCed = MyTrackedClass('not-GCed');
  notGCed.dispose();

  await leak_detector.wrapUp();
}
