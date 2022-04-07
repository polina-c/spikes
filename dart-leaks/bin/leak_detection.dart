import 'package:leaks/leak_detector.dart';

class MyClass {
  late final leakDetector;

  MyClass() {
    leakDetector = LeakDetector(this);
  }

  void constructBuilder() {
    leakDetector.registerPass('Enclosed into a builder');
  }

  void dispose() {
    leakDetector.registerDisposal();
  }
}

void main() {}
