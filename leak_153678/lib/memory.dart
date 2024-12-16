import 'dart:async';
import 'dart:io';

import 'package:counter/format.dart';

class MemoryChecker {
  // ignore: unused_field
  late Timer _timer;
  int _max = 0;

  MemoryChecker() {
    _timer = Timer.periodic(Duration(seconds: 1), _check);
  }

  void _check(Timer timer) {
    final rss = ProcessInfo.currentRss;
    if (rss > _max) {
      _max = rss;
    }

    final rssDisplay = prettyPrintBytes(rss, includeUnit: true);
    final maxDisplay = prettyPrintBytes(_max, includeUnit: true);

    print('Current RSS: $rssDisplay, Max RSS: $maxDisplay');
  }
}
