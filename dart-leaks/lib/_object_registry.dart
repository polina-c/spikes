import 'dart:core';

void _objectGarbageCollected(Object token) {
  print('$token garbage collected');
}

final _finalizer = Finalizer(_objectGarbageCollected);

void objectCreated() {}
void objectDisposed() {}

void watchGC() {}
void unwatchGC() {}
void rememberDisposed() {}
void forgetDisposed() {}
