import 'package:meta/meta.dart';

const bool _instrumentDisposables =
    bool.fromEnvironment('my_package.instrument_disposables');

mixin LeakTrackableHelpers {
  void dispatchObjectCreated({
    required String library,
    required String className,
    required Object object,
  }) {}

  void dispatchObjectDisposed({
    required String library,
    required String className,
    required Object object,
  }) {}
}

@LeakTrackable(_instrumentDisposables)
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Point.origin()
      : x = 0,
        y = 0;

  Point.derived() : this(1.0, 1.0);

  @mustCallSuper
  void dispose() {}
}

mixin MyDisposableMixin {}

@LeakTrackable(_instrumentDisposables)
class MyDerivedClass with MyDisposableMixin {}

// It is macro.
class LeakTrackable {
  const LeakTrackable(bool instrument);
}

// lint rule: classes with method dispose() should use macros @LeakTrackable
