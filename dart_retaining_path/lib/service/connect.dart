import 'dart:developer';

import 'package:vm_service/vm_service.dart';
import 'package:collection/collection.dart';
import 'service.dart';
import 'vm_service_wrapper.dart';

late String _isolateId;
late VmServiceWrapper _service;
bool connected = false;

Future<void> connect() async {
  if (connected) return;

  final info = await Service.getInfo();
  if (info.serverWebSocketUri == null) {
    throw Exception(
        'Run your application or tests in debug or profile mode to troubleshoot leaks.');
  }

  _service = await connectWithWebSocket(info.serverWebSocketUri!, (error) {
    throw error ?? Exception('Error connecting to service protocol');
  });

  await _service.getVersion();

  await _service.forEachIsolate((IsolateRef r) async {
    if (r.name == 'main') {
      _isolateId = r.id!;
    }
  });

  connected = true;
}

Future<RetainingPath> getRetainingPath(ObjectFingerprint object) async {
  await connect();

  final targetId = await _targetId(object);

  return await _service.getRetainingPath(_isolateId, targetId, 100000);
}

class ObjectFingerprint {
  final String type;
  final int code;

  ObjectFingerprint.byCode(this.type, this.code);
  ObjectFingerprint(Object object)
      : type = object.runtimeType.toString(),
        code = identityHashCode(object);
}

/// Finds targetId of an object.
///
/// Throws [StateError] if object is not found.
Future<String> _targetId(ObjectFingerprint object) async {
  final classes = await findClasses(object.type);

  for (final theClass in classes) {
    final instances =
        (await _service.getInstances(_isolateId, theClass.id!, 10000000))
                .instances ??
            <ObjRef>[];
    final result = instances.firstWhereOrNull((objRef) =>
        objRef is InstanceRef && objRef.identityHashCode == object.code);
    if (result != null) return result.id!;
  }

  throw StateError(
      'Instance of ${object.type} with code ${object.code} not found.');
}

Future<List<ClassRef>> findClasses(String runtimeClassName) async {
  var classes = await _service.getClassList(_isolateId);

  // In the beginning list of classes is empty.
  while (classes.classes?.isEmpty ?? true) {
    await Future.delayed(const Duration(milliseconds: 100));
    classes = await _service.getClassList(_isolateId);
  }

  final result =
      classes.classes?.where((ref) => runtimeClassName == ref.name).toList() ??
          [];

  print(classes.classes!.map((e) => e.name).join(', '));
  if (result.isEmpty) {
    throw StateError('Class $runtimeClassName not found.');
  }

  return result;
}
