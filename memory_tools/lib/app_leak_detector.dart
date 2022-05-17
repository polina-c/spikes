import 'dart:async';
import 'src/_globals.dart' as globals;
import 'src/_object_registry.dart';
import 'src/_reporter.dart' as reporter;
import 'src/_utils.dart' as utils;
import 'dart:convert';
import 'dart:io' as io;

Timer? _timer;

void init(
    {required String Function(Object object) objectLocationGetter,
    required Duration timeToGC}) {
  globals.objectLocationGetter = objectLocationGetter;
  globals.timeToGC = timeToGC;

  _timer ??= Timer.periodic(
    Duration(seconds: 1),
    (_) => reporter.reportLeaks(objectRegistry.collectLeaks()),
  );

  globals.leakTrackingEnabled = true;
}
