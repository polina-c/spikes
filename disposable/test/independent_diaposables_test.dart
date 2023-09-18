import 'package:meta/meta.dart';
import 'package:test/test.dart';

mixin Mixin1 {
  @mustCallSuper
  void dispose() {
    print('i am Mixin1');
  }
}

mixin Mixin2 {
  @mustCallSuper
  void dispose() {
    print('i am Mixin2');
  }
}

class User with Mixin1, Mixin2 {
  @override
  void dispose() {
    print('i am User');
    super.dispose();
  }
}

void main() {
  test('dispose', () {
    User().dispose();
    // Output shows Mixin1 is missing:
    // i am User
    // i am Mixin2
  });
}
