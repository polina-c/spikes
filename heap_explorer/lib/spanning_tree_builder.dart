import 'package:heap_explorer/model.dart';

/// Returns null if there is no path to root.
void buildTreeFromRoot(MtHeap heap) {
  final root = heap.objects[MtHeap.rootIndex];
  root.parent = -1;

  // Array of all objects where the best distance from root is n.
  // n starts with 0 and increases by 1 on each step of the algorithm.
  var cut = [MtHeap.rootIndex];

  // On each step of algorithm we know that there is no roots closer
  // than nodes in the current cut, to the destination.
  while (true) {
    final nextCut = <int>[];
    for (var p in cut) {
      final parent = heap.objects[p];
      for (var c in parent.references) {
        final child = heap.objects[c];
        if (child.parent != null) continue;

        child.parent = p;
        parent.children.add(c);
        nextCut.add(c);
      }
    }
    if (nextCut.isEmpty) return;
    cut = nextCut;
  }
}
