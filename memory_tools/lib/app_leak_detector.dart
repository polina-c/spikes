import 'dart:async';
import '_object_registry.dart';
import '_utils.dart' as utils;

final _objectRegistry = ObjectRegistry();
Timer? _timer;

void startTracking(Object object, {Object? token}) {
  _timer ??= Timer.periodic(
    Duration(seconds: 1),
    (_) => _objectRegistry.collectAndReportLeaks(),
  );

  _objectRegistry.startTracking(object, token);
}

void registerDisposal(Object object, {Object? token}) =>
    _objectRegistry.registerDisposal(object, token);

Future<void> wrapUp() async {
  _timer?.cancel();
  await utils.forceGC();
  _objectRegistry.collectAndReportLeaks();
}
