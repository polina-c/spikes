import 'package:flutter/material.dart';
import 'package:stager/stager.dart';

class HelloScene extends Scene {
  @override
  Widget build() {
    return const MaterialApp(
      home: Text('hello, world'),
    );
  }

  @override
  Future<void> setUp() async {}

  @override
  String get title => '$HelloScene';
}
