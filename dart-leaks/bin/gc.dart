// This is demo how finalizer works.
// To run: `dart bin/gc.dart`

import 'dart:core';

void nonDisposedObjectGarbageCollected(Object token) {
  print('$token garbage collected');
}

final finalizer = Finalizer(nonDisposedObjectGarbageCollected);

class MyClass {
  Object _token = 'MyClass#1';

  MyClass() {
    print('$_token created');
    finalizer.attach(this, _token, detach: this);
  }

  void dispose() {
    finalizer.detach(this);
  }
}

// Method that allocates, but does not dispose objects.
void createAndNotDispose() {
  final myClass = MyClass();
  // myClass.dispose();
}

// We need method that allocates objects, to trigger GC.
void doSomeAllocations() {
  List<DateTime> l = [DateTime.now()];
}

void main() async {
  createAndNotDispose();
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    doSomeAllocations();
  }
}
