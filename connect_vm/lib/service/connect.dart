import 'dart:developer';
import 'package:connect_vm/service/service.dart';
import 'package:vm_service/vm_service.dart';
import 'package:collection/collection.dart';
import 'vm_service_wrapper.dart';

late String isolateId;
late VmServiceWrapper service;
bool connected = false;

Future<void> connect() async {
  if (connected) return;

  final info = await Service.getInfo();
  if (info.serverWebSocketUri == null) {
    throw Exception(
        'Run your application or tests in debug or profile mode to troubleshoot leaks.');
  }

  service = await connectWithWebSocket(info.serverWebSocketUri!, (error) {
    throw error ?? Exception('Error connecting to service protocol');
  });

  await service.getVersion();
  await service.forEachIsolate((IsolateRef r) async {
    if (r.name == 'main') {
      isolateId = r.id!;
    }
  });

  connected = true;
}

Future<RetainingPath> getRetainingPath(ObjectFingerprint object) async {
  await connect();

  final targetId = await _targetId(object);
  if (targetId == null) {
    throw Exception('Could not find object in heap');
  }

  return await service.getRetainingPath(isolateId, targetId, 100000);
}

class ObjectFingerprint {
  final String type;
  final int code;

  ObjectFingerprint.byCode(this.type, this.code);
  ObjectFingerprint(Object object)
      : type = object.runtimeType.toString(),
        code = identityHashCode(object);
}

Future<String?> _targetId(ObjectFingerprint object) async {
  final classes = await findClasses(object.type);

  for (final theClass in classes) {
    final instances =
        (await service.getInstances(isolateId, theClass.id!, 10000000))
                .instances ??
            <ObjRef>[];
    final result = instances.firstWhereOrNull((objRef) =>
        objRef is InstanceRef && objRef.identityHashCode == object.code);
    if (result != null) return result.id;
  }

  return null;
}

Future<List<ClassRef>> findClasses(String runtimeClassName) async {
  final classes = await service.getClassList(isolateId);
  return classes.classes
          ?.where((ref) => runtimeClassName == ref.name)
          .toList() ??
      [];
}
