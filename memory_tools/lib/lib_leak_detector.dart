import '_object_registry.dart';

void startTracking(Object object, {Object? token}) {
  objectRegistry.startTracking(object, token);
}

void registerDisposal(Object object, {Object? token}) =>
    objectRegistry.registerDisposal(object, token);
