import 'dart:io';

import 'primitives.dart';

import '_globals.dart' as globals;
import 'package:indent/indent.dart';

String _folderName = '/Users/polinach/Documents/';

void reportLeaks(
  Leaks leaks,
) {
  if (leaks.isEmpty) return;

  print(
      'Detected ${leaks.notGCed.length + leaks.notDisposed.length}: ${leaks.notGCed.length} not GCed and ${leaks.notDisposed.length} not disposed.');

  outputLeaks(leaks);
}

Future<void> outputLeaks(Leaks leaks) async {
  var file = await File(_folderName + globals.reportFileName);
  await file.writeAsString(_leaksToYaml(leaks), mode: FileMode.append);
}

Future<void> clearFile() async {
  var file = await File(_folderName + globals.reportFileName);
  await file.writeAsString('');
}

String _leaksToYaml(Leaks leaks) =>
    _listToYaml('not-disposed', leaks.notDisposed) +
    _listToYaml('not-gced', leaks.notGCed);

String _listToYaml(String title, Iterable<Leak> leaks) => leaks.length == 0
    ? ''
    : '''$title:
  total: ${leaks.length}
  objects:
${leaks.map((e) => _leakToYaml(e, '    ')).join()}
''';

String _leakToYaml(Leak leak, String indent) {
  return '''$indent${leak.token}:
$indent  creationLocation: ${leak.info.creationLocation}
$indent  registrationTime: ${leak.info.registrationTime}
$indent  disposedAfter: ${leak.info.disposedAfter}
$indent  gcedAfter: ${leak.info.gcedAfter}
$indent  call-stacks:
$indent    registrationCallStack: '
${leak.info.registrationCallStack.indent(indent.length + 6)}
$indent    '
$indent    disposalCallStack: '
${(leak.info.disposalCallStack ?? '').indent(indent.length + 6)}
$indent    '
''';
}
