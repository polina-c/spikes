import 'package:dart_leaks/leaking_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_tools/test_leak_detector.dart' as leak_detector;

void main() {
  setUp(() {
    leak_detector.init(Duration(seconds: 2));
  });

  testWidgets(
    'Leaks are detected for LeakingWidget.',
    (tester) async {
      await tester.pumpWidget(LeakingWidget());
      // Let the splash page animations complete.
      await tester.pump(const Duration(seconds: 1));
    },
  );

  tearDown(() async {
    final leaks = await leak_detector.collectLeaks();
    expect(leaks.notGCed.length, 1);
    expect(leaks.notDisposed.length, 1);
  });
}
