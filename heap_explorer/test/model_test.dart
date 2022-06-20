import 'package:heap_explorer/model.dart';
import 'package:test/test.dart';

void main() {
  test('MtHeap serializes.', () {
    final json = MtHeap([
      MtHeapObject(
          code: 1,
          successors: [1, 2],
          references: [3, 4, 5],
          klass: 'klass',
          library: 'library')
    ]).toJson();

    expect(json, MtHeap.fromJson(json).toJson());
  });
}
