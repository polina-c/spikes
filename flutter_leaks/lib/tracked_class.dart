import 'package:memory_tools/lib_leak_detector.dart' as leak_detector;

class MyTrackedClass {
  Object _token;

  MyTrackedClass(this._token) {
    leak_detector.startTracking(this, token: this._token);
  }

  void dispose() {
    leak_detector.registerDisposal(this, token: this._token);
  }
}
