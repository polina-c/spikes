import 'dart:io';

import 'primitives.dart';

import '_globals.dart' as globals;
import 'dart:developer';

Leaks? _previous;

void reportLeaks(
  Leaks leaks,
) {
  if (leaks.isEmpty) return;
  reportToDevTools(leaks);

  if (leaks.sameSize(_previous)) return;

  int notGCed = leaks.notGCed.length;
  int notDisposed = leaks.notDisposed.length;
  int gcedLate = leaks.gcedLate.length;

  print('${notGCed + notDisposed + gcedLate} leaks:'
      ' $notDisposed not disposed,'
      ' $notGCed not GCed,'
      ' $gcedLate GCed late.');

  _previous = leaks;
}

void reportToDevTools(Leaks leaks) {
  postEvent('MemoryLeaks', _leaksToJson(leaks));
}

Map<String, dynamic> _leaksToJson(Leaks leaks) => {
      'not-gced': _listOfLeaksToJson(leaks.notGCed),
      'gced-late': _listOfLeaksToJson(leaks.gcedLate),
      'not-disposed': _listOfLeaksToJson(leaks.notDisposed),
    };

Map<String, dynamic> _listOfLeaksToJson(Iterable<ObjectInfo> leaks) => {
      'total': leaks.length,
      'leaks': leaks.map((e) => _leakToJson(e)).toList(growable: false)
    };

Map<String, dynamic> _leakToJson(ObjectInfo leak) => {
      'token': leak.token,
      'creationLocation': leak.creationLocation,
      'registration': leak.registration.toString(),
      'disposed': leak.disposed.toString(),
      'gced': leak.gced.toString(),
    };

String _leaksToYaml(Leaks leaks) =>
    _listOfLeaksToYaml('not-disposed', leaks.notDisposed) +
    _listOfLeaksToYaml('not-gced', leaks.notGCed) +
    _listOfTokensToYaml('gced-late', leaks.gcedLate);

String _listOfLeaksToYaml(String title, Iterable<ObjectInfo> leaks) =>
    leaks.length == 0
        ? ''
        : '''$title:
  total: ${leaks.length}
  objects:
${leaks.map((e) => _leakToYaml(e, '    ')).join()}
''';

String _listOfTokensToYaml(String title, Iterable<Object> tokens) =>
    tokens.length == 0
        ? ''
        : '''$title:
  total: ${tokens.length}
  tokens:
${tokens.map((e) => '    - $e\n').join()}
''';

String _leakToYaml(ObjectInfo leak, String indent) {
  return '''$indent${leak.token}:
$indent  creationLocation: ${leak.creationLocation}
$indent  registrationTime: ${leak.registration}
$indent  disposedAfter: ${leak.disposed}
$indent  gcedAfter: ${leak.gced}
''';
}
