// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:memory_leak_tracker/src/model.dart';
import 'package:test/test.dart';

void main() {
  final report = LeakReport(
    type: 'type',
    code: 123,
    details: ['creationLocation'],
  );

  test('$LeakReport.fromJson does not lose information', () {
    final json = report.toJson();
    final copy = LeakReport.fromJson(json);

    expect(copy.type, report.type);
    expect(copy.details, report.details);
    expect(copy.code, report.code);
  });

  test('$LeakReport.toJson does not lose information.', () {
    final json = report.toJson();
    expect(json, LeakReport.fromJson(json).toJson());
  });
}
