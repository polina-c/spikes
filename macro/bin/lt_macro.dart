import 'package:macro/lt_macro.dart' as macro;

void main() {
  final jack = User('Jack', 25);
  print(jack.toString());
}

class User {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  @AutoToString()
  String toString();
}
