import 'dart:async';
import 'package:memory_tools/_globals.dart' as globals;
import 'package:memory_tools/primitives.dart';

import '_object_registry.dart';
import '_utils.dart' as utils;

void init(
    {Duration timeToGC = const Duration(seconds: 5),
    bool detailedOutput = false}) {
  globals.timeToGC = timeToGC;
  globals.detailedOutput = detailedOutput;
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
