import '_object_registry.dart';
import 'package:uuid/uuid.dart';

var _uuid = Uuid();

final _objectRegistry = ObjectRegistry();
final _finalizer = Finalizer(_objectGarbageCollected);

class LeakDetector {
  late Object _token;

  LeakDetector(Object object, {Object? token}) {
    _token = token ?? _uuid.v1();
    _finalizer.attach(this, _token);
  }

  registerDisposal() {
    _objectRegistry.registerDisposal(_token);
  }
}

void _objectGarbageCollected(Object token) {
  _objectRegistry.registerGC(token);
}
