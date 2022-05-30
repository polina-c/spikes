import 'dart:math';

import 'package:memory_tools/app_leak_detector.dart';
import 'package:memory_tools/src/_gc_time.dart';
import 'package:memory_tools/src/model.dart';
import 'package:memory_tools/src/testing/generated.mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:memory_tools/src/_object_registry.dart' show ObjectRegistry;
import 'package:collection/collection.dart';

import '../lib/src/testing/generated.dart';

void main() {
  final mockFinalizer = MockFinalizer<Object>();
  final gcTime = GCTime();
  // Object, that was just attached to mockFinalizer.
  var lastAttachedObject;
  late Function(Object token) registerGC;
  late ObjectRegistry testObjectRegistry;

  init(objectLocationGetter: (object) => 'location of $object');
  when(mockFinalizer.attach(any, any)).thenAnswer((invocation) {
    lastAttachedObject = invocation.positionalArguments[0];
  });
  testObjectRegistry = ObjectRegistry(
    finalizerBuilder: (handler) {
      registerGC = handler;
      return mockFinalizer;
    },
    gcTime: gcTime,
  );

  group('ObjectRegistry', () {
    test('creates Finalizer and passes handler to it', () {
      expect(registerGC, isNotNull);
    });

    test('attaches object to finalizer', () {
      testObjectRegistry.startTracking('my object', 'my token');
      expect(lastAttachedObject, 'my object');
    });

    test('reports zero leaks', () {
      testObjectRegistry.reset();
      final summary = testObjectRegistry.collectLeaksSummary();
      expect(summary.totals.values.sum, 0);
    });

    test('declares not-GC-ed leak', () {
      testObjectRegistry.reset();
      final myObject = 'my object';
      final myToken = 'my token';
      testObjectRegistry.startTracking(myObject, myToken);
      testObjectRegistry.registerDisposal(myObject, myToken);
      _registerGCEvents(8, gcTime);
      expect(gcTime.now, 3);
      final leaks = testObjectRegistry.collectLeaksSummary();
      expect(leaks.totals.values.sum, 1);
      expect(leaks.totals[LeakType.notGCed], 1);
    });
  });
}

void _registerGCEvents(int count, GCTime gcTime) => Iterable.generate(count)
    .forEach((_) => gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC}));