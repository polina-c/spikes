import 'dart:async';

final _listeners = <Function>[];
Timer? _timer;

Object? oldSpaceObject;
late WeakReference<Object> detector;

void addOldGCEventListener(Function listener) {
  _listeners.add(listener);

  if (_timer == null) _start();
}

void _start() async {
  await _resetDetector();
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (detector.target != null) return;
    for (var l in _listeners) {
      l();
    }
    _resetDetector();
  });
}

Future<void> _resetDetector() async {
  oldSpaceObject = [DateTime.now()];
  await Future.delayed(Duration(milliseconds: 100));
  detector = WeakReference(oldSpaceObject!);
  oldSpaceObject = null;
}
