import 'dart:async';
import 'dart:io';

import 'package:counter/format.dart';

class MemoryChecker {
  // ignore: unused_field
  late Timer _timer;

  MemoryChecker() {
    _timer = Timer.periodic(Duration(seconds: 1), _check);
  }

  void _check(Timer timer) {
    final rss = ProcessInfo.currentRss;
    print(prettyPrintBytes(rss, includeUnit: true));
  }
}
