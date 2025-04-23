import 'package:leak_tracker/leak_tracker.dart';

const library = 'package:my_package/lib/src/my_lib.dart';

class InstrumentedDisposable {
  InstrumentedDisposable() {
    LeakTracking.dispatchObjectCreated(
      library: library,
      className: 'InstrumentedDisposable',
      object: this,
    );
  }

  void addSomeNotes() {
    LeakTracking.dispatchObjectTrace(
      object: this,
      context: {'notes': 'Some notes'},
    );
  }

  void dispose() {
    LeakTracking.dispatchObjectDisposed(object: this);
  }
}
