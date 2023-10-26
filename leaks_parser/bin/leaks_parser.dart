import 'package:leaks_parser/leaks_parser.dart';

Future<void> main(List<String> arguments) async {
  final result = <String>{};

  await parseLeaks('data/failure1.txt', result);
  await parseLeaks('data/failure2.txt', result);
  await parseLeaks('data/failure3.txt', result);
  await parseLeaks('data/failure4.txt', result);

  result.add('AnimationController');
  result.add('OverlayEntry');

  for (var name in result.toList()..sort()) {
    print("        '$name': null,");
  }
}
