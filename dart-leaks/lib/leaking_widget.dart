import 'package:dart_leaks/tracked_class.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final log = Logger('leak-detector');

MyTrackedClass? notGCed = null;

class LeakingWidget extends StatefulWidget {
  LeakingWidget({Key? key}) : super(key: key) {
    notGCed ??= MyTrackedClass('not-GCed');
  }

  @override
  State<LeakingWidget> createState() => _LeakingWidgetState();
}

class _LeakingWidgetState extends State<LeakingWidget> {
  MyTrackedClass? _notDisposed = MyTrackedClass('not-disposed');
  final _disposedAndGCed = MyTrackedClass('disposed-and-GCed');

  @override
  Widget build(BuildContext context) {
    if (_notDisposed != null) {
      _notDisposed = null;
      notGCed?.dispose();
      _disposedAndGCed.dispose();
      log.fine('leaking widget cleaned up');
    }
    return Container();
  }
}
