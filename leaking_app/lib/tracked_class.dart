// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/memory.dart';
import 'dart:core';

class MyTrackedClass {
  MyTrackedClass({required this.token, required this.children}) {
    startObjectLeakTracking(this, details: token);
  }

  final String token;
  final List<MyTrackedClass> children;

  void dispose() {
    children.forEach((element) => element.dispose());
    registerDisposal(this,
        details: 'disposal call stack:\n${StackTrace.current.toString()}');
  }
}
