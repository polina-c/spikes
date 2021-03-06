```mermaid
sequenceDiagram
    participant myClass
    participant timer
    participant GC
    participant leakDetector
    participant finalizer as finalizer<br/>(global)
    participant disposedNotGCed as disposedNotGCed<br/>(global)

    myClass ->>+ leakDetector: create
    leakDetector ->>- finalizer: register myClass
    myClass ->>+ leakDetector: registerDisposal
    leakDetector ->>- disposedNotGCed: add myClass token
    timer ->> disposedNotGCed: checkForNotGCed
    Note over disposedNotGCed: for disposed long time ago:<br/>- output missed GC warning to console<br/>- send to DevTools<br/>- delete
    GC ->>+ finalizer: finalize myClass
    finalizer ->>- disposedNotGCed: objectIsGCed
    Note over disposedNotGCed: delete the object<br/>if it was not here:<br/>- output warning to console<br/>- send to DevTools
    	 
```