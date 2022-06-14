// Copied from https://github.com/dart-lang/sdk/blob/main/runtime/observatory/HACKING.md
// To run from root of observatory after building it:
// xcodebuild/DebugARM64/dart-sdk/bin/dart --disable-service-origin-check --observe ../../spikes/observatory/instance.dart

import 'dart:async' show Timer, Duration;

class MyClass {
  bool tick = true;

  String hello() {
    return 'Hello!!!';
  }
}

main() {
  final myObject = MyClass();
  new Timer.periodic(const Duration(seconds: 1), (Timer t) {
    //print(tick ? 'tick' : 'tock');
    myObject.tick = false;
  });
}
