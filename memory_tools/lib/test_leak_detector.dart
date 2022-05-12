import 'dart:async';
import 'package:memory_tools/src/_globals.dart' as globals;
import 'package:memory_tools/src/_reporter.dart' as reporter;
import 'package:memory_tools/src/primitives.dart';

import 'src/_object_registry.dart';
import 'src/_utils.dart' as utils;

void init(
    {Duration timeToGC = const Duration(seconds: 5),
    String fileName = 'leaks_from_app.yaml'}) {
  globals.timeToGC = timeToGC;
  globals.reportFileName = fileName;
  reporter.clearFile();
}

Future<Leaks> collectLeaks() async {
  await utils.forceGC();
  return objectRegistry.collectLeaks();
}

Future<void> wrapUp() async {
  globals.logger.fine('Wrapping up...');
  await utils.forceGC();
  objectRegistry.collectAndReportLeaks();
  globals.logger.fine('Wrapped up.');
}
