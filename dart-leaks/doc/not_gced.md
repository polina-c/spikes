```mermaid
sequenceDiagram
	myClass -> leakDetector: create
	leakDetector -> finalizer: register myClass
	myClass -> leakDetector: registerDisposal
	leakDetector -> disposedNotGCed: add myClass token
	
	timer -> disposedNotGCed: checkForLeaks
	Note right of disposedNotGCed -> for disposed long time ago:<br/>- output warning to console<br/>- send to DevTools<br/>- delete 
```