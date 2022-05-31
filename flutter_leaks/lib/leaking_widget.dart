import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'tracked_class.dart';

final log = Logger('leak-detector');

class MyClass {
  MyTrackedClass? notGCed1 = MyTrackedClass('not-GCed1');
  MyTrackedClass? notGCed2 = MyTrackedClass('not-GCed2');

  void dispose() {
    notGCed1?.dispose();
    notGCed2?.dispose();
  }
}

class LeakingWidget extends StatefulWidget {
  LeakingWidget({Key? key}) : super(key: key);

  @override
  State<LeakingWidget> createState() => _LeakingWidgetState();
}

class _LeakingWidgetState extends State<LeakingWidget> {
  bool _isCleaned = false;
  MyTrackedClass? _notDisposed = MyTrackedClass('not-disposed');
  MyTrackedClass? _disposedAndGCed = MyTrackedClass('disposed-and-GCed');
  // ignore: unnecessary_nullable_for_final_variable_declarations
  final MyClass? _notGCed = MyClass();

  @override
  Widget build(BuildContext context) {
    if (!_isCleaned) {
      _notDisposed = null;

      _notGCed?.dispose();

      _disposedAndGCed?.dispose();
      _disposedAndGCed = null;

      _isCleaned = true;
    }

    return Column(children: [
      const SizedBox(
        width: 100,
        height: 100,
        child: Text('I am leaking widget'),
      ),
      Checkbox(value: true, onChanged: (_) {}),
    ]);
  }
}
