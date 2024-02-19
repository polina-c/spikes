import 'package:flutter/foundation.dart';

class Disposable {
  const Disposable(
      {this.enableMemoryEvents = true, this.protectFromDoubleDispose = true});

  final bool enableMemoryEvents;
  final bool protectFromDoubleDispose;
}

const bool kIsMyTestEnv = bool.fromEnvironment('myPackage.isTestEnv');

/// Use this to make the class always instrumented.
const disposable = Disposable();

/// Use this to make the class instrumented just in tests for the package.
const disposableInMyTests = Disposable(enableMemoryEvents: kIsMyTestEnv);

abstract class NotInstrumentedParent {
  const NotInstrumentedParent.constant();

  NotInstrumentedParent.nonConst();

  @mustCallSuper
  void dispose() {}
}

/// This class illustrates how the macro @disposable updates the code.
@disposableInMyTests
class MyDisposable extends NotInstrumentedParent {
  MyDisposable.dynamicConst() : super.constant() {
    /* may be user code */
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:my_package/my_package.dart',
        className: 'MyDisposable',
        object: this,
      );
    }
  }

  MyDisposable.dynamicDynamic() : super.nonConst() {
    /* may be user code */
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:my_package/my_package.dart',
        className: 'MyDisposable',
        object: this,
      );
    }
  }

  MyDisposable.redirectingDynamicDynamic() : this.dynamicConst();

  factory MyDisposable.myFactory() => MyDisposable.redirectingDynamicDynamic();

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
  static bool debugAssertNotDisposed(MyDisposable disposable) {
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

  @override
  void dispose() {
    assert(debugAssertNotDisposed(this));
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    /* may be user code */
    super.dispose();
    _debugDisposed = true;
  }
}
