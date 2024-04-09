
import 'macro/auto_to_string.dart';
import 'package:macro_disposable/macro_disposable.dart';

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
