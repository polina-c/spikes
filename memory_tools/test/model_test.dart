import 'package:memory_tools/src/model.dart';
import 'package:test/test.dart';

void main() {
  test('Object can be restored from info.', () {
    Object theObject = ['hello'];
    final info = ObjectInfo('token', 'location', theObject);
    final restoredObject = info.weakReference.target;
    expect(restoredObject, theObject);
  });
}
