import 'package:memory_tools/lib_leak_detector.dart' as leak_detector;

class MyTrackedClass {
  final Object token;
  final MyTrackedClass? child;

  MyTrackedClass({required this.token, this.child}) {
    leak_detector.startTracking(this, token: token);
  }

  void dispose() {
    child?.dispose();
    leak_detector.registerDisposal(this, token: token);
  }
}
