import 'package:flutter/foundation.dart';

class Disposable {
  const Disposable({this.enableMemoryEvents = true});

  final bool enableMemoryEvents;
}

const bool kIsMyTestEnv = bool.fromEnvironment('myPackage.isTestEnv');

/// Use this to make the class always instrumented.
const disposable = Disposable();

/// Use this to make the class instrumented just in tests for the package.
const disposableInMyTests = Disposable(enableMemoryEvents: kIsMyTestEnv);

abstract class NotInstrumentedParent {
  const NotInstrumentedParent.constant();

  NotInstrumentedParent.nonConst() {}

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

  @override
  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    super.dispose();
  }
}
