import 'package:memory_tools/src/_config.dart';

import 'model.dart';
import 'dart:developer';

LeakSummary? _previous;

void reportLeaksSummary(LeakSummary leakSummary) {
  postEvent('memory_leaks_summary', leakSummary.toJson());
  if (leakSummary.equals(_previous)) return;
  _previous = leakSummary;
  logger.info(leakSummary.toMessage());
}

void reportLeaks(Leaks leaks) {
  postEvent('memory_leaks_details', leaks.toJson());
}
