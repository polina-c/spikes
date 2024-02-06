import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MemoryTest(),
    );
  }
}

class MemoryTest extends StatelessWidget {
  const MemoryTest({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = OutlinedButton(
      child: const Text("CLICK"),
      onPressed: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const MemoryTest(),
        ));
      },
    );
    for (var i = 10; i-- > 0;) {
      content = Padding(padding: const EdgeInsets.all(0), child: content);
    }
    return content;
  }
}
