import 'package:meta/meta.dart';

/// This file is linked in doc:
/// https://docs.google.com/document/d/1ec5djPP14b1u93O9fHrJJf3gbONay1nV4sBV2-XXOIw/edit?resourcekey=0-CFEu4HWAW8yP0knhoVfKxQ

// ---------------------------------------
// Code for 'package:collection/disposable.dart'

/// A class that can be extended or mixed in that provides a way
/// to dispose the resources.
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

  /// Discards any resources used by the object. After this is called, the
  /// object is not in a usable state and should be discarded.
  ///
  /// This method should only be called by the object's owner.
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
