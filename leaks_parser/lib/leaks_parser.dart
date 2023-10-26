import 'dart:io';

Future<void> parseLeaks(String file, Set<String> classes) async {
  final content = await File(file).readAsString();
  final matches =
      RegExp(r'([0-9a-zA-Z_<>]+):\n\s*test:.*\n\s*identityHashCode:')
          .allMatches(content);

  classes
      .addAll(matches.map((m) => m[1]!).where((item) => !{'>'}.contains(item)));
}
