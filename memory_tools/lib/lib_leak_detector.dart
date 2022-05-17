import 'src/_object_registry.dart';
import 'src/_config.dart';

void startTracking(Object object, {Object? token}) {
  if (leakTrackingEnabled) objectRegistry.startTracking(object, token);
}

void registerDisposal(Object object, {Object? token}) {
  if (leakTrackingEnabled) objectRegistry.registerDisposal(object, token);
}
