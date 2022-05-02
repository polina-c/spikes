import 'dart:async';
import '_globals.dart';
import '_object_registry.dart';
import '_utils.dart' as utils;

Timer? _timer;

void init() {
  _timer ??= Timer.periodic(
    Duration(seconds: 1),
    (_) => objectRegistry.collectAndReportLeaks(),
  );
}

Future<void> wrapUp() async {
  logger.fine('Wrapping up...');
  _timer?.cancel();
  objectRegistry.collectAndReportLeaks();
  await utils.forceGC();
  objectRegistry.collectAndReportLeaks();
  logger.fine('Wrapped up.');
}
