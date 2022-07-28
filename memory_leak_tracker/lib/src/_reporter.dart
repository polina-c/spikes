// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:memory_leak_tracker/src/_app_config.dart';

import 'model.dart';

LeakSummary? _previous;

void reportLeaksSummary(LeakSummary leakSummary) {
  if (leakSummary.equals(_previous)) return;
  _previous = leakSummary;
  final config = leakTrackingConfiguration!;
  final listener = config.leakListener;

  postEvent('memory_leaks_summary', leakSummary.toJson());

  if (listener != null) listener(leakSummary);

  // TODO(polina-c): add deep link for DevTools here.
  if (config.stdoutLeaks) {
    print(leakSummary.toMessage());
  }
}

void reportLeaks(Leaks leaks) {
  postEvent('memory_leaks_details', leaks.toJson());
}
