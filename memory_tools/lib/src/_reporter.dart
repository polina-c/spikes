import 'package:memory_tools/src/_config.dart';

import 'model.dart';
import 'dart:developer';

LeakSummary? _previous;

void reportLeaks(LeakSummary leakSummary) {
  reportToDevTools(leakSummary);
  if (leakSummary.equals(_previous)) return;
  _previous = leakSummary;
  logger.info(leakSummary.toMessage());
}

void reportToDevTools(LeakSummary summary) {
  postEvent('memory_leaks_summary', summary.toJson());
}

// Map<String, dynamic> _leaksToJson(Leaks leaks) => {
//       'not-gced': _listOfLeaksToJson(leaks.notGCed),
//       'gced-late': _listOfLeaksToJson(leaks.gcedLate),
//       'not-disposed': _listOfLeaksToJson(leaks.notDisposed),
//     };

// Map<String, dynamic> _listOfLeaksToJson(Iterable<ObjectInfo> leaks) => {
//       'total': leaks.length,
//       'leaks': leaks.map((e) => _leakToJson(e)).toList(growable: false)
//     };

// Map<String, dynamic> _leakToJson(ObjectInfo leak) => {
//       'token': leak.token,
//       'creationLocation': leak.creationLocation,
//       'registration': leak.registration.toString(),
//       'disposed': leak.disposed.toString(),
//       'gced': leak.gced.toString(),
//     };

String _leaksToYaml(Leaks leaks) =>
    _listOfLeaksToYaml('not-disposed', leaks.notDisposed) +
    _listOfLeaksToYaml('not-gced', leaks.notGCed) +
    _listOfLeaksToYaml('gced-late', leaks.gcedLate);

String _listOfLeaksToYaml(String title, Iterable<ObjectInfo> leaks) {
  if (leaks.length == 0) return '';

  return '''$title:
  total: ${leaks.length}
  objects:
${leaks.map((e) => _leakToYaml(e, '    ')).join()}
''';
}

String _leakToYaml(ObjectInfo leak, String indent) {
  return '''$indent${leak.type}:
$indent  token: ${leak.token}
$indent  creationLocation: ${leak.creationLocation}
$indent  disposedAfter: ${leak.disposed}
$indent  gcedAfter: ${leak.gced}
''';
}
