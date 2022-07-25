import 'dart:async';

final _listeners = <Function>[];
Timer? _timer;

Object? _oldSpaceObject;
late WeakReference<Object> _detector;

void addOldGCEventListener(Function listener) {
  _listeners.add(listener);

  if (_timer == null) _start();
}

void _start() async {
  await _resetDetector();
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_detector.target != null) return;
    for (var l in _listeners) {
      l();
    }
    _resetDetector();
  });
}

Future<void> _resetDetector() async {
  _oldSpaceObject = [DateTime.now()];
  _detector = WeakReference(_oldSpaceObject!);
  await Future.delayed(Duration(milliseconds: 100));
  _oldSpaceObject = null;
}
