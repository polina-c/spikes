import 'package:vm_service/vm_service.dart';

class MtHeap {
  static const rootIndex = 1;
  final List<MtHeapObject> objects;

  MtHeap(this.objects);

  factory MtHeap.fromJson(Map<String, dynamic> json) => MtHeap(
        (json['objects'] as List<dynamic>)
            .map((e) => MtHeapObject.fromJson(e))
            .toList(),
      );

  factory MtHeap.fromHeapSnapshot(HeapSnapshotGraph graph) => MtHeap(
        graph.objects
            .map((e) => MtHeapObject.fromHeapSnapshotObject(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'objects': objects.map((e) => e.toJson()).toList(),
      };

  String toYaml() {
    final noPath = objects.where((o) => o.parent == null);
    final result = StringBuffer();

    result.writeln('with-retaining-path:');
    result.writeln('  total: ${objects.length - noPath.length}');
    result.write(_objectToYaml(objects[rootIndex], '  '));
    result.writeln('without-retaining-path:');
    result.writeln('  total: ${noPath.length}');
    result.writeln('  objects:');
    for (var o in noPath) {
      result.writeln('    ${o.name}');
    }
    return result.toString();
  }

  String _objectToYaml(MtHeapObject object, String indent) {
    final firstLine = '$indent${object.name}';
    if (object.children.isEmpty) return '$firstLine\n';

    final result = StringBuffer();
    result.writeln('$firstLine:');
    for (var c in object.children) {
      final child = objects[c];
      result.write(_objectToYaml(child, '$indent  '));
    }
    return result.toString();
  }
}

typedef IdentityHashCode = int;

class MtHeapObject {
  MtHeapObject({
    required this.code,
    required this.successors,
    required this.references,
    required this.klass,
    required this.library,
  });

  factory MtHeapObject.fromHeapSnapshotObject(HeapSnapshotObject object) {
    var library = object.klass.libraryName;
    if (library.isEmpty) library = object.klass.libraryUri.toString();
    return MtHeapObject(
      code: object.identityHashCode,
      successors: object.successors.map((e) => e.identityHashCode).toList(),
      references: List.from(object.references),
      klass: object.klass.name,
      library: library,
    );
  }

  factory MtHeapObject.fromJson(Map<String, dynamic> json) => MtHeapObject(
        code: json['code'],
        successors: (json['successors'] as List<dynamic>).cast<int>(),
        references: (json['references'] as List<dynamic>).cast<int>(),
        klass: json['klass'],
        library: json['library'],
      );

  final List<int> references;
  final String klass;
  final String library;
  final IdentityHashCode code;
  final List<IdentityHashCode> successors;

  // Fields for graph analysis.
  final List<int> children = [];
  // null - unknown, -1 - root.
  int? parent;

  Map<String, dynamic> toJson() => {
        'code': code,
        'successors': successors,
        'references': references,
        'klass': klass,
        'library': library.toString(),
      };

  String get name => '$library/$klass:$code';
}
