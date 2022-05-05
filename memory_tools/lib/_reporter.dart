import 'dart:io';

import 'primitives.dart';

import '_globals.dart' as globals;
// import 'package:indent/indent.dart';

String _folderName = '/Users/polinach/Documents/';

void reportLeaks(
  Leaks leaks,
) {
  if (leaks.isEmpty) return;

  int notGCed = leaks.notGCed.length;
  int notDisposed = leaks.notDisposed.length;
  int falsePositives = leaks.falsePositives.length;

  print('Detected ${notGCed + notDisposed + falsePositives}:'
      ' $notGCed not GCed,'
      ' $notDisposed not disposed and'
      ' $falsePositives false positives.');

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
    _listOfLeaksToYaml('not-disposed', leaks.notDisposed) +
    _listOfLeaksToYaml('not-gced', leaks.notGCed) +
    _listOfTokensToYaml('false-positives', leaks.falsePositives);

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
${tokens.map((e) => '    $e').join()}
''';

String _leakToYaml(ObjectInfo leak, String indent) {
  return '''$indent${leak.token}:
$indent  creationLocation: ${leak.creationLocation}
$indent  registrationTime: ${leak.registrationTime}
$indent  disposedAfter: ${leak.disposedAfter}
$indent  gcedAfter: ${leak.gcedAfter}
''';

// $indent  call-stacks:
// $indent    registrationCallStack: '
// ${leak.registrationCallStack.indent(indent.length + 6)}
// $indent    '
// $indent    disposalCallStack: '
// ${(leak.disposalCallStack ?? '').indent(indent.length + 6)}
// $indent    '
// ''';
}
