import 'package:meta/meta.dart';
import 'package:test/test.dart';

mixin Disposable {
  @mustCallSuper
  void dispose() {
    print('i am Disposable');
  }
}

class Class1 with Disposable {
  @override
  void dispose() {
    print('i am Class1');
    super.dispose();
  }
}

mixin Mixin1 on Disposable {
  @override
  void dispose() {
    print('i am Mixin1');
    super.dispose();
  }
}

mixin Mixin2 on Disposable {
  @override
  void dispose() {
    print('i am Mixin2');
    super.dispose();
  }
}

class SuperPosition extends Class1 with Mixin1, Mixin2 {
  @override
  void dispose() {
    print('i am SuperPosition');
    super.dispose();
  }
}

void main() {
  test('dispose', () {
    SuperPosition().dispose();
    // Output shows nothing is missing:
    // i am SuperPosition
    // i am Mixin2
    // i am Mixin1
    // i am Class1
    // i am Disposable
  });
}
