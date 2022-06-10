import 'package:compute/compute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:compute/main.dart';

void main() {
  test('Compute', () {
    heavyCompute(const Duration(seconds: 5));
  });
}
