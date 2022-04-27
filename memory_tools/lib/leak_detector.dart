import '_object_registry.dart';
import 'package:uuid/uuid.dart';

final _objectRegistry = ObjectRegistry();
final _finalizer = Finalizer(_objectGarbageCollected);

Object _getToken(Object object, Object? token) =>
    token ?? identityHashCode(object);

void _objectGarbageCollected(Object token) {
  _objectRegistry.registerGC(token);
}

startLeakDetector(Object object, {Object? token}) {
  _finalizer.attach(object, _getToken(object, token));
}

registerDisposal(Object object, {Object? token}) {
  _objectRegistry.registerDisposal(_getToken(object, token));
}
