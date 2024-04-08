import 'macro/disposable.dart';
import 'macro/auto_to_string.dart';

void use() {
  final jack = User('Jack', 25);
  print(jack.toString());
}

@Disposable()
class User {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  @AutoToString()
  String toString();
}
