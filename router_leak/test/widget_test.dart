// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:router_leak/main.dart';

void main() {
  testWidgets('Leak test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Warm up
    for (var i = 0; i < 20; i++) {
      await tester.tap(find.text('CLICK'));
      await tester.pumpAndSettle();
    }

    var rss = ProcessInfo.currentRss;
    var totalDelta = 0;
    for (var i = 0; i < 100; i++) {
      await tester.tap(find.text('CLICK'));
      await tester.pumpAndSettle();

      final newRss = ProcessInfo.currentRss;
      debugPrint('diff: ${newRss - rss}');
      totalDelta += newRss - rss;
      rss = newRss;
    }
    debugPrint('totalDelta: $totalDelta');
  });
}
