import 'package:dart_leaks/leaking_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
// import 'package:memory_tools/_globals.dart';
// import 'package:memory_tools/_reporter.dart';
import 'package:memory_tools/test_leak_detector.dart' as leak_detector;

void main() {
  Logger.root.level = Level.FINE;
  // logger.onRecord.listen((record) {
  //   print('${record.level.name}: ${record.time}: ${record.message}');
  // });

  setUp(() {
    leak_detector.init(
      timeToGC: Duration(seconds: 5),
    );
  });

  testWidgets(
    'Leaks are detected for LeakingWidget.',
    (tester) async {
      await tester.pumpWidget(LeakingWidget());
      await tester.pump(const Duration(seconds: 1));
    },
  );

  tearDown(() async {
    final leaks = await leak_detector.collectLeaks();

    // await outputLeaks(leaks);

    expect(leaks.notGCed.length, 1);
    expect(leaks.notDisposed.length, 1);
  });
}
