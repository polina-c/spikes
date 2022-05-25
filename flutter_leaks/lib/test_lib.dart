class MyClass {
  final int code;

  MyClass(this.code);

  @override
  String toString() => 'hello';
}

MyClass? instance;

Object getObject(int code) {
  return instance = MyClass(code);
}
