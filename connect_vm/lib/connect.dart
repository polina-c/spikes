import 'dart:developer';
import 'package:connect_vm/service/service.dart';
import 'package:vm_service/vm_service.dart';
import 'package:collection/collection.dart';
import 'service/vm_service_wrapper.dart';

late String isolateId;
late VmServiceWrapper service;
bool connected = false;

Future<void> connect() async {
  if (connected) return;

  try {
    final info = await Service.getInfo();

    service = await connectWithWebSocket(info.serverWebSocketUri!, (error) {
      print('error recieved: $error');
    });

    await service.getVersion();
    await service.forEachIsolate((IsolateRef r) async {
      if (r.name == 'main') {
        isolateId = r.id!;
      }
    });

    connected = true;
  } catch (e, stack) {
    print('error connecting: $e\n$stack');
  }
}

Future<RetainingPath> getRetainingPath(Object object) async {
  await connect();

  final fp = _ObjectFingerprint(object);
  final targetId = await _targetId(fp);
  if (targetId == null) {
    throw Exception('Could not find object in heap');
  }

  return await service.getRetainingPath(isolateId, targetId, 100000);
}

class _ObjectFingerprint {
  final String type;
  final int code;

  _ObjectFingerprint._(this.type, this.code);
  _ObjectFingerprint(Object object)
      : type = object.runtimeType.toString(),
        code = identityHashCode(object);
}

Future<String?> _targetId(_ObjectFingerprint object) async {
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
