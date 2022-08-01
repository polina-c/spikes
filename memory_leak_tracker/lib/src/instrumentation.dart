// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import '_app_config.dart';
import '_gc_detector.dart';
import '_gc_initiator.dart';
import '_reporter.dart';
import '_tracker.dart';
import 'model.dart';

Timer? _timer;

/// Name of extension that enables leak tracking for applications.
const String memoryLeakTrackingExtensionName = 'ext.dart.memoryLeakTracking';

/// Starts leak tracking in the application, for instrumented objects.
///
/// If [detailsProvider] provided, it will be used to collect location
/// for the leaked objects.
/// If [checkPeriod] is not null, the leaks summary will be regularly calculated
/// and, in case of new leaks, output to the console.
void startAppLeakTracking(LeakTrackingConfiguration config) {
  leakTrackingConfiguration = config;
  addOldGCEventListener(() => leakTracker.registerOldGCEvent());

  if (config.checkPeriod != null) {
    _timer?.cancel();
    _timer = Timer.periodic(
      config.checkPeriod!,
      (_) {
        final start = DateTime.now();
        reportLeaksSummary(leakTracker.collectLeaksSummary());
        print('!!!! analysis took ${DateTime.now().difference(start)}');
      },
    );
  }

  try {
    registerExtension(memoryLeakTrackingExtensionName,
        (String method, Map<String, String> parameters) async {
      // final bool isGCRegistration = parameters.containsKey('registerGC');
      // if (isGCRegistration) leakTracker.registerOldGCEvent();

      final bool isRequestForDetails = parameters.containsKey('requestDetails');
      if (isRequestForDetails) reportLeaks(leakTracker.collectLeaks());

      final bool isRequestForGC = parameters.containsKey('forceGC');
      if (isRequestForGC) await forceGC(3);

      return ServiceExtensionResponse.result('{}');
    });
  } on ArgumentError catch (ex) {
    // Skipping error about already registered extension.
    final bool isAlreadyRegisteredError = ex.toString().contains('registered');
    if (!isAlreadyRegisteredError) rethrow;
  }
}

void stopAppLeakTracking() {
  leakTrackingConfiguration = null;
  _timer?.cancel();
}

void startObjectLeakTracking(Object object, {String? details, Object? family}) {
  if (!_shouldTrack()) return;
  leakTracker.startTracking(object, details);
}

void registerDisposal(Object object, {String? details, Object? family}) {
  if (!_shouldTrack()) return;
  leakTracker.registerDisposal(object, details);
}

void addLeakTrackingDetails(Object object, String details, {Object? family}) {
  if (!_shouldTrack()) return;
  leakTracker.addDetails(object, details);
}

bool _shouldTrack() {
  return leakTrackingConfiguration != null;
}
