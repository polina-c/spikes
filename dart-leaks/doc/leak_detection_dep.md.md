```mermaid
classDiagram
MyClass *--> LeakDetector
LeakDetector..> Finalizer
LeakDetector ..> DisposedNotGCed
LeakDetector o--> FinalizationCallback
Finalizer..> FinalizationCallback
FinalizationCallback ..> DisposedNotGCed
```