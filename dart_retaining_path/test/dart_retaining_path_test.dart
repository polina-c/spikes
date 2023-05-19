import 'dart:developer';

import 'package:dart_retaining_path/service/service.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

class MyClass {
  MyClass();
}

void main() {
  test('$MyClass can be found.', () async {
    final info = await Service.getInfo();

    final service =
        await connectWithWebSocket(info.serverWebSocketUri!, (error) {
      throw error ?? Exception('Error connecting to service protocol');
    });

    await service.getVersion();

    late String isolateId;
    await service.forEachIsolate((IsolateRef r) async {
      if (r.name == 'main') {
        isolateId = r.id!;
      }
    });

    var classes = await service.getClassList(isolateId);

    // In the beginning list of classes is empty.
    while (classes.classes?.isEmpty ?? true) {
      print('Waiting for classes to be loaded.');
      await Future.delayed(const Duration(milliseconds: 100));
      classes = await service.getClassList(isolateId);
    }

    final result =
        classes.classes?.where((ref) => '$MyClass' == ref.name).toList() ?? [];

    expect(result.length, 1);
  });
}
