// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'model.dart';

/// Keeps timeline of GC cycles.
///
/// One cycle is a set of GC events after which any non-reachable object is
/// guaranteed to be collected.
class GCTimeLine {
  // It will start actually working when VM team completes the request:
  // https://github.com/dart-lang/sdk/issues/49319.

  int _cyclesPassed = 0;
  static const _cycleLength = 2;
  int _eventsPassed = 0;

  void registerOldGCEvent() {
    _eventsPassed++;
    if (_eventsPassed == _cycleLength) {
      _cyclesPassed++;
      _eventsPassed = 0;
    }
  }

  /// Number of the current GC cycle.
  int get now => _cyclesPassed + 1;
}
