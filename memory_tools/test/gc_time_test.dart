import 'package:memory_tools/src/_gc_time.dart';
import 'package:test/test.dart';

void main() {
  test('Cycles happen as expected.', () {
    final gcTime = GCTime();
    expect(gcTime.now, 1);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 1);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 1);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 1);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 2);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 2);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 2);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 2);
    gcTime.registerGCEvent({GCEvent.newGC, GCEvent.oldGC});
    expect(gcTime.now, 3);
  });
}
