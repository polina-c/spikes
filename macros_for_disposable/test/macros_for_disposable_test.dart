import 'package:macros_for_disposable/macros_for_disposable.dart';
import 'package:test/test.dart';

void main() {
  tearDownAll(() => print('last'));
  tearDownAll(() => print('1'));

  test('calculate', () {
    //expect(calculate(), 42);
    print('test');
  });

  tearDownAll(() => print('2'));
}
