import 'dart:core';

// Get master channel to have it working.

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

void x() {
  final myClass = MyClass();
  // myClass.dispose();
}

void y() {
  List<DateTime> l = [DateTime.now()];
}

void main() async {
  x();
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    y();
  }
}
