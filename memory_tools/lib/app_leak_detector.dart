import 'dart:async';
import 'src/_config.dart' as config;
import 'src/_object_registry.dart';
import 'src/_reporter.dart' as reporter;
import 'dart:developer' as developer;

Timer? _timer;

void init({
  required String Function(Object object) objectLocationGetter,
  Duration timeToGC = const Duration(seconds: 15),
  Duration tick = const Duration(seconds: 1),
}) {
  config.objectLocationGetter = objectLocationGetter;
  config.timeToGC = timeToGC;

  _timer ??= Timer.periodic(
    tick,
    (_) {
      reporter.reportLeaks(objectRegistry.collectLeaks());
    },
  );

  config.leakTrackingEnabled = true;

  // We need the extension to receive GC events from flutter_tools.
  developer.registerExtension('ext.app-gc-event', (method, parameters) async {
    objectRegistry.registerGC(
      oldSpace: parameters.containsKey('old'),
      newSpace: parameters.containsKey('new'),
    );
    return developer.ServiceExtensionResponse.result('ok');
  });
}
