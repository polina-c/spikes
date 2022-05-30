import 'package:memory_tools/src/model.dart';
import 'package:test/test.dart';

void main() {
  test('Object can be restored by info.', () {
    Object theObject = ['hello'];
    final info = ObjectInfo('token', 'location', theObject);

    final restoredObject = info.restoreObject();
    expect(restoredObject, theObject);
  });
}
