// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StagerAppGenerator
// **************************************************************************

import 'hello.dart';

import 'package:stager/stager.dart';

void main() {
  final scenes = [
    HelloScene(),
  ];

  if (const String.fromEnvironment('Scene').isNotEmpty) {
    const sceneName = String.fromEnvironment('Scene');
    final scene = scenes.firstWhere((scene) => scene.title == sceneName);
    runStagerApp(scenes: [scene]);
  } else {
    runStagerApp(scenes: scenes);
  }
}
