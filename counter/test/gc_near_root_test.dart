// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

late WeakReference<Object> nearMain1;
late WeakReference<Object> nearMain2;
late WeakReference<Object> farFromMain1;
late WeakReference<Object> farFromMain2;

void main() {
  testWidgets('test1', (_) async {
    final nearMain = _create();
    nearMain1 = WeakReference(nearMain);
    farFromMain1 = _createWeakly();
  });

  testWidgets('test2', (_) async {
    farFromMain2 = _createWeakly();
    final TextEditingController controller = TextEditingController();
    nearMain2 = WeakReference(controller);
  });

  tearDownAll(() async {
    printNullness();
    await forceGC();
    printNullness();
  });
}

String nullness(String name, WeakReference<Object> ref) =>
    ref.target == null ? '$name is null' : '$name is not-null';

void printNullness() {
  print(nullness('   nearMain1', nearMain1));
  print(nullness('farFromMain1', farFromMain1));
  print(nullness('   nearMain2', nearMain2));
  print(nullness('farFromMain2', farFromMain2));
}

Object _create() => FocusNode(debugLabel: 'Test Node');

WeakReference<Object> _createWeakly() => WeakReference(_create());

Future<void> forceGC() async {
  final int barrier = reachabilityBarrier;

  final List<List<int>> storage = <List<int>>[];

  void allocateMemory() {
    storage.add(List.generate(30000, (n) => n));
    if (storage.length > 100) {
      storage.removeAt(0);
    }
  }

  while (reachabilityBarrier < barrier + 1) {
    await Future<void>.delayed(Duration.zero);
    allocateMemory();
  }
}
