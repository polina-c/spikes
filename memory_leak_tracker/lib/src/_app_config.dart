// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'model.dart';

/// If true, leak detection is enabled for the application.
bool leakTrackingEnabled = false;

/// Set of object families, enabled for tracking.
///
/// If an object does not belong to any family, it is always tracked.
/// Otherwise it is tracked if its family belongs to this set.
Set<Object> enabledFamilies = <Object>{};