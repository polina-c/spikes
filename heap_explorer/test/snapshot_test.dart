import 'dart:convert';
import 'dart:io';
import 'package:heap_explorer/model.dart';
import 'package:heap_explorer/spanning_tree_builder.dart';
import 'package:test/test.dart';

void main() {
  late MtHeap heap;
  const appName = 'MyApp';

  setUp(() async {
    heap = await _loadHeapFromFile('test/goldens/demo_app.json');
  });

  test('There are many objects and roots.', () {
    expect(heap.objects.length, greaterThan(1000));
    expect(heap.objects[MtHeap.rootIndex].references.length, greaterThan(1000));
  });

  test('Successors and references are the same.', () {
    for (var o in heap.objects) {
      expect(o.successors, hasLength(o.references.length));
    }
  });

  test('There is exactly one object of type $appName.', () {
    final appObjects = heap.objects.where((o) => o.klass == appName);
    expect(appObjects, hasLength(1));
  });

  test('Write spanning tree to file.', () async {
    buildTreeFromRoot(heap);
    final appObject = heap.objects.where((o) => o.klass == appName).first;
    expect(appObject.parent, isNotNull);

    await File(
      'test/goldens/demo_app.yaml',
    ).writeAsString(heap.toYaml());
  });
}

Future<MtHeap> _loadHeapFromFile(
  String fileNameFromProjectRoot,
) async {
  final json = jsonDecode(
    await File(fileNameFromProjectRoot).readAsString(),
  );
  return MtHeap.fromJson(json);
}
