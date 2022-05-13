import 'dart:async';
import 'src/_globals.dart' as globals;
import 'src/_object_registry.dart';
import 'src/_reporter.dart' as reporter;
import 'src/_utils.dart' as utils;
import 'dart:convert';
import 'dart:io' as io;

Timer? _timer;

void init({required String? fileName, required Duration timeToGC}) {
  globals.reportFileName = fileName;
  globals.timeToGC = timeToGC;
  reporter.clearFile();

  _timer ??= Timer.periodic(
    Duration(seconds: 1),
    (_) async => await objectRegistry.forceGCandReportLeaks(),
  );
}

// For console applications and tests.
Future<void> wrapUp() async {
  globals.logger.fine('Wrapping up...');
  _timer?.cancel();
  await objectRegistry.forceGCandReportLeaks();
  globals.logger.fine('Wrapped up.');
}
