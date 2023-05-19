import 'package:dart_retaining_path/dart_retaining_path.dart';
import 'package:dart_retaining_path/service/connect.dart';
import 'package:test/test.dart';

void main() {
  test('Retaining path is reported in debug mode.', () async {
    late MyClass notGCedObject;
    late int code;

    Future<void> doSomething() async {
      notGCedObject = MyClass();
      code = identityHashCode(notGCedObject);
      // Dispose reachable instance.
      notGCedObject.dispose();
    }

    await doSomething();

    final path =
        await getRetainingPath(ObjectFingerprint.byCode('MyClass', code));
    print(path);
  });
}

class MyClass {
  MyClass();

  void dispose() {}
}
