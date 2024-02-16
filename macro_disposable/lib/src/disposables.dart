import 'package:flutter/foundation.dart';

class Disposable {
  const Disposable({bool enableMemoryEvents = true});
}

const bool kIsMyTestEnv = bool.fromEnvironment('myPackage.isTestEnv');

/// Use this to make the class always instrumented.
const disposable = Disposable();

/// Use this to make the class instrumented just in tests for the package.
const disposableInMyTests = Disposable(enableMemoryEvents: kIsMyTestEnv);

@disposableInMyTests
abstract class InstrumentedParent {
  const InstrumentedParent.constant();

  InstrumentedParent.nonConst() {
    /* may be user code */
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:my_package/my_package.dart',
        className: 'InstrumentedParent',
        object: this,
      );
    }
  }

  @mustCallSuper
  void dispose() {
    /* may be user code */
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
  }
}

/// This class illustrates how the macro @disposable updates the code.
@disposableInMyTests
class MyDisposable extends InstrumentedParent {
  const MyDisposable.constConst() : super.constant();

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

  MyDisposable.dynamicDynamic() : super.nonConst();

  const MyDisposable.redirectingConstConst() : this.constConst();

  /// Original code:
  /// ```
  /// MyDisposable.redirectingDynamicConst() : this.constConst();
  /// ```
  factory MyDisposable.redirectingDynamicConst() {
    final result = MyDisposable.constConst();
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:my_package/my_package.dart',
        className: 'MyDisposable',
        object: result,
      );
    }
    return result;
  }

  MyDisposable.redirectingDynamicDynamic() : this.dynamicConst();

  factory MyDisposable.myFactory() => const MyDisposable.constConst();

  @override
  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    super.dispose();
  }
}
