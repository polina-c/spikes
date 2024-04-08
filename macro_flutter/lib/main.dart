import 'package:flutter/material.dart';
import 'usage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(User('Jack', 25).toString()),
        ),
      ),
    );
  }
}
