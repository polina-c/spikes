import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyAppWithMemoryTest());
  currentRss = ProcessInfo.currentRss;
}

class MyAppWithMemoryTest extends StatelessWidget {
  const MyAppWithMemoryTest({super.key});

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

int currentRss = 0;

class MemoryTest extends StatelessWidget {
  const MemoryTest({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = OutlinedButton(
      child: const Text("CLICK"),
      onPressed: () {
        final newRss = ProcessInfo.currentRss;
        debugPrint(
            'Current RSS KB: ${newRss ~/ 1024}, RSS delta KB: ${(newRss - currentRss) ~/ 1024}');
        currentRss = newRss;
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
