import 'dart:async';
import '_globals.dart' as globals;
import '_object_registry.dart';
import '_reporter.dart' as reporter;
import '_utils.dart' as utils;

Timer? _timer;

void init({required String fileName}) {
  globals.reportFileName = fileName;
  globals.timeToGC = Duration(seconds: 30);
  reporter.clearFile();

  _timer ??= Timer.periodic(
    Duration(seconds: 1),
    (_) => objectRegistry.collectAndReportLeaks(),
  );
}

// For console application.
Future<void> wrapUp() async {
  globals.logger.fine('Wrapping up...');
  _timer?.cancel();
  objectRegistry.collectAndReportLeaks();
  await utils.forceGC();
  objectRegistry.collectAndReportLeaks();
  globals.logger.fine('Wrapped up.');
}
