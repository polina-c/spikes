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
    final instance = MyClass();

    print(info.serverWebSocketUri);

    final service =
        await connectWithWebSocket(info.serverWebSocketUri!, (error) {
      throw error ?? Exception('Error connecting to service protocol');
    });

    await service.getVersion();

    await Future.delayed(const Duration(seconds: 5));

    late String isolateId;
    await service.forEachIsolate((IsolateRef r) async {
      print(r.name);
      if (r.name == 'main') {
        isolateId = r.id!;
      }
    });

    await Future.delayed(const Duration(minutes: 30));

    var classes = await service.getClassList(isolateId);

    // In the beginning list of classes is empty.
    while (classes.classes?.isEmpty ?? true) {
      print('Waiting for classes to be loaded.');
      await Future.delayed(const Duration(milliseconds: 100));
      classes = await service.getClassList(isolateId);
    }

    print('found ${classes.classes?.length} classes');

    final result =
        classes.classes?.where((ref) => 'MyClass' == ref.name).toList() ?? [];

    expect(result.length, 1);
    print(instance);
  }, timeout: Timeout(Duration(minutes: 30)));
}
