import 'package:meta/meta.dart';

mixin Disposable {
  bool _debugDisposed = false;

  /// Used by subclasses to assert that the [Disposable] has not yet been
  /// disposed.
  ///
  /// {@tool snippet}
  /// The [debugAssertNotDisposed] function should only be called inside of an
  /// assert, as in this example.
  ///
  /// ```dart
  /// class MyClass with Disposable {
  ///   void doUpdate() {
  ///     assert(Disposable.debugAssertNotDisposed(this));
  ///     // ...
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  // This is static and not an instance method because there are many
  // implementations of Disposable, and so it is too breaking
  // to add a public method.
  static bool debugAssertNotDisposed(Disposable disposable) {
    assert(() {
      if (disposable._debugDisposed) {
        throw StateError(
          'A ${disposable.runtimeType} was used after being disposed.\n'
          'After you have called dispose() on a ${disposable.runtimeType}, it '
          'can not longer be used. '
          'See debugging tips at https://dart.dev/tutorials/disposables/debug-usage-after-disposal.',
        );
      }
      return true;
    }());
    return true;
  }

  @mustCallSuper
  void dispose() {
    assert(() {
      if (_debugDisposed) {
        throw StateError(
          'dispose() is called second time on $runtimeType, while it should be called exactly once. '
          'See debugging tips at https://dart.dev/tutorials/disposables/debug-double-disposal.',
        );
      }
      _debugDisposed = true;
      return true;
    }());
  }
}
