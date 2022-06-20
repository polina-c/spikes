import 'package:vm_service/vm_service.dart';

class MtHeap {
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

  factory MtHeapObject.fromHeapSnapshotObject(HeapSnapshotObject object) =>
      MtHeapObject(
        code: object.identityHashCode,
        successors: object.successors.map((e) => e.identityHashCode).toList(),
        references: List.from(object.references),
        klass: object.klass.name,
        library: object.klass.libraryUri.toString(),
      );

  factory MtHeapObject.fromJson(Map<String, dynamic> json) => MtHeapObject(
        code: json['code'],
        successors: json['successors'],
        references: (json['references'] as List<dynamic>).cast<int>(),
        klass: json['klass'],
        library: json['url'],
      );

  final List<int> references;
  final String klass;
  final String library;
  final IdentityHashCode code;
  final List<IdentityHashCode> successors;

  Map<String, dynamic> toJson() => {
        'code': code,
        'successors': successors,
        'references': references,
        'klass': klass,
        'url': library.toString(),
      };
}
