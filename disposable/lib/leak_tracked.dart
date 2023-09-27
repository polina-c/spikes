import 'dart:async';

/// This file is linked in doc:
/// https://docs.google.com/document/d/1hlGY6HnsH5EJhpQDFm-_e-Sr9euQf6jE74TxkqDxhGY/edit?resourcekey=0--7J08lEADd6HpaTGC1B-Pw

// ---------------------------------------
// Code for 'package:collection/disposable.dart'
// ---------------------------------------

// Also, code of https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/foundation/memory_allocations.dart
// will be copied here, with note to use flutter lib when possible, because it is optimized by a flag for production code.

/// List of disposables, ready for leak tracking.
///
/// A disposable class is ready for leak tracking if it is instrumented and
/// the package code that declared the class verified there is no leak in the package.
///
/// Used to define set of memory leaks that should be included or excluded.
class MemoryLeakTypes {
  const MemoryLeakTypes({
    required this.package,
    required this.notDisposed,
    required this.notGCed,
    this.outdatedWarning,
  });

  MemoryLeakTypes outdated() {
    return MemoryLeakTypes(
        package: package,
        notDisposed: notDisposed,
        notGCed: notGCed,
        outdatedWarning: null);
  }

  MemoryLeakTypes emptied() {
    return MemoryLeakTypes(
        package: package, notDisposed: [], notGCed: [], outdatedWarning: null);
  }

  MemoryLeakTypes except(
      {List<String> notDisposed = const [], List<String> notGCed = const []}) {
    return MemoryLeakTypes(
        package: package,
        notDisposed: Set<String>.from(this.notDisposed)
            .difference(Set<String>.from(notDisposed))
            .toList(),
        notGCed: Set<String>.from(this.notGCed)
            .difference(Set<String>.from(notGCed))
            .toList(),
        outdatedWarning: null);
  }

  /// Package name.
  final String package;

  /// Warning, to be printed if this instance is used.
  ///
  /// Set it for outdated instances.
  final String? outdatedWarning;

  /// List of classes for notDisposed leaks.
  ///
  /// The class name should be as reported to [ObjectCreated.className].
  final List<String> notDisposed;

  /// List of classes for notGCed leaks.
  ///
  /// The class name should be as reported to [ObjectCreated.className].
  final List<String> notGCed;
}

// ---------------------------------------
// Code for flutter framework.
// Similar code should be in any package, Flutter or third party, that declared instrumented disposables.
// If disposables are not ready for leak tracking yet, the list shpuld be empty.
// ---------------------------------------

const MemoryLeakTypes flutterDisposables1 = MemoryLeakTypes(
    package: 'flutter',
    notDisposed: ['RenderObject', 'Layer', 'ChangeNotifier'],
    notGCed: [],
    outdatedWarning:
        'flutterDisposables1 is outdated. Use flutterDisposables2.');

const MemoryLeakTypes flutterDisposables2 = MemoryLeakTypes(
  package: 'flutter',
  notDisposed: ['RenderObject', 'Layer', 'ChangeNotifier'],
  notGCed: ['RenderObject', 'Layer', 'ChangeNotifier'],
);

// ---------------------------------------
// fragment of leak_tracker API
// ---------------------------------------

class LeakTrackingSettings {
  const LeakTrackingSettings(
    this.toTrack, {
    this.printWarningsForOutdatedPackages = true,
    this.printWarningsForMissedPackages = true,
  });

  /// If null, all instrumented disposables will be tracked.
  final List<MemoryLeakTypes>? toTrack;
  final bool printWarningsForOutdatedPackages;
  final bool printWarningsForMissedPackages;
}

void setLeakTrackingSettings(LeakTrackingSettings settings) {}

// ---------------------------------------
// Code for user's package test/flutter_test_config.dart
// ---------------------------------------

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // No warnings:
  setLeakTrackingSettings(LeakTrackingSettings([
    flutterDisposables2,
  ]));

  // Warning will be printed:
  setLeakTrackingSettings(LeakTrackingSettings([
    flutterDisposables1,
  ]));

  // Warning will be printed, because of detected disposables from flutter:
  setLeakTrackingSettings(LeakTrackingSettings([]));

  // No warnings:
  setLeakTrackingSettings(LeakTrackingSettings(
    [],
    printWarningsForMissedPackages: false,
  ));

  // No warnings:
  setLeakTrackingSettings(LeakTrackingSettings([
    flutterDisposables1.emptied(),
  ]));

  // No warnings:
  setLeakTrackingSettings(
    LeakTrackingSettings(
      [
        flutterDisposables1,
      ],
      printWarningsForOutdatedPackages: false,
    ),
  );

  // No warnings:
  setLeakTrackingSettings(LeakTrackingSettings([
    flutterDisposables1.outdated(),
  ]));

  // No warnings:
  setLeakTrackingSettings(LeakTrackingSettings([
    flutterDisposables1.except(notDisposed: ['RenderObject']),
  ]));
}
