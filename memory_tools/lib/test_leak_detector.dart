import 'dart:async';
import 'package:memory_tools/_globals.dart';
import 'package:memory_tools/primitives.dart';

import '_object_registry.dart';
import '_utils.dart' as utils;

void init(Duration timeToGCtoUse) {
  timeToGC = timeToGCtoUse;
}

Future<Leaks> collectLeaks() async {
  await utils.forceGC();
  return objectRegistry.collectLeaks();
}

Future<void> wrapUp() async {
  logger.fine('Wrapping up...');
  objectRegistry.collectAndReportLeaks();
  await utils.forceGC();
  objectRegistry.collectAndReportLeaks();
  logger.fine('Wrapped up.');
}
