# not_gced_leak

This application illustrates memory leak caused by context passed to a closure.

Follow https://github.com/flutter/devtools/blob/master/packages/devtools_app/lib/src/screens/memory/panes/leaks/LEAK_TRACKING.md
for tha application in profile mode for macos.

After a set of size changes, counter increases and answer openings you will get the leak:

```yaml
    StatefulElement:
      identityHashCode: 801698972
      retainingPath:
        - /Root-0
        - /Isolate-0
        - package:flutter/src/widgets/binding.dart/WidgetsFlutterBinding-4200361193
        - package:flutter/src/widgets/framework.dart/BuildOwner-551775339
        - dart.collection/_InternalLinkedHashMap-0
        - dart.core/_List-0
        - package:flutter/src/widgets/framework.dart/SingleChildRenderObjectElement-276060140
        - package:flutter/src/widgets/framework.dart/StatelessElement-205720855
        - package:flutter/src/widgets/framework.dart/SingleChildRenderObjectElement-1024453286
        - package:flutter/src/widgets/framework.dart/StatefulElement-988294612
        - package:not_gced_leak/main.dart/_MyHomePageState-372707313
        - package:not_gced_leak/quest.dart/QuestController-2082527545
        - dart.core/_Closure-39473473
        - /Context-2690620942
        - package:flutter/src/widgets/framework.dart/StatefulElement-801698972
      total-victims: 2
```
