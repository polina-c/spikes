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

void x() {
  final foo = MyClass();
  // foo.dispose();
}

void main() {
  x();
  while (true) {}
  // long running program that does some GC
}
