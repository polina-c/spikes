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
/// The disposable is ready for leak tracking if it is instrumented and
/// the package code that declared it verified there is no leak in the package.
///
/// Used to define set of memory leaks that should be included or excluded.
class TrackableDisposables {
  const TrackableDisposables({
    required this.package,
    required this.notDisposed,
    required this.notGCed,
    this.outdatedWarning,
  });

  TrackableDisposables outdated() {
    return TrackableDisposables(
        package: package,
        notDisposed: notDisposed,
        notGCed: notGCed,
        outdatedWarning: null);
  }

  TrackableDisposables emptied() {
    return TrackableDisposables(
        package: package, notDisposed: [], notGCed: [], outdatedWarning: null);
  }

  TrackableDisposables except(
      {List<String> notDisposed = const [], List<String> notGCed = const []}) {
    return TrackableDisposables(
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

const TrackableDisposables flutterDisposables1 = TrackableDisposables(
    package: 'flutter',
    notDisposed: ['RenderObject', 'Layer', 'ChangeNotifier'],
    notGCed: [],
    outdatedWarning:
        'flutterDisposables1 is outdated. Use flutterDisposables2.');

const TrackableDisposables flutterDisposables2 = TrackableDisposables(
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

  final List<TrackableDisposables> toTrack;
  final bool printWarningsForOutdatedPackages;
  final bool printWarningsForMissedPackages;
}

void configureLeakTracking(LeakTrackingSettings settings) {}

// ---------------------------------------
// Code for user's package test/flutter_test_config.dart
// ---------------------------------------

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // No warnings:
  configureLeakTracking(LeakTrackingSettings([
    flutterDisposables2,
  ]));

  // Warning will be printed:
  configureLeakTracking(LeakTrackingSettings([
    flutterDisposables1,
  ]));

  // Warning will be printed, because of detected disposables from flutter:
  configureLeakTracking(LeakTrackingSettings([]));

  // No warnings:
  configureLeakTracking(LeakTrackingSettings(
    [],
    printWarningsForMissedPackages: false,
  ));

  // No warnings:
  configureLeakTracking(LeakTrackingSettings([
    flutterDisposables1.emptied(),
  ]));

  // No warnings:
  configureLeakTracking(
    LeakTrackingSettings(
      [
        flutterDisposables1,
      ],
      printWarningsForOutdatedPackages: false,
    ),
  );

  // No warnings:
  configureLeakTracking(LeakTrackingSettings([
    flutterDisposables1.outdated(),
  ]));

  // No warnings:
  configureLeakTracking(LeakTrackingSettings([
    flutterDisposables1.except(notDisposed: ['RenderObject']),
  ]));
}
