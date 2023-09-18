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

mixin class MixinClass1 implements Disposable {
  @override
  @mustCallSuper
  void dispose() {
    print(
        'i am MixinClass1, i will have to implement Disposable, because I cannot extend or be on non object');
  }
}

class SuperPosition1 extends Class1 with Mixin1, MixinClass1 {
  @override
  void dispose() {
    print('i am SuperPosition');
    super.dispose();
  }
}

void main() {
  test('dispose SuperPosition1', () {
    SuperPosition1().dispose();
    // Output shows dispose of Class1 and Mixin1 are missing:
    // i am SuperPosition
    // i am MixinClass1, i will have to implement Disposable, because I cannot extend or be on non Object
  });
}
