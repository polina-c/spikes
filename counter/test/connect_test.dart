import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';

Future<Uri> _serviceUri() async {
  Uri? uri = (await Service.getInfo()).serverWebSocketUri;

  if (uri != null) return uri;

  uri = (await Service.controlWebServer(enable: true)).serverWebSocketUri;
  if (uri == null) {
    throw StateError(
      'Could not start VM service. If you are running `flutter test`, pass the flag `--enable-vmservice`',
    );
  }

  return uri;
}

// flutter test --enable-vmservice test/connect_test.dart

void main() {
  test('Service can be started for flutter test.', () async {
    await _serviceUri();
  });

  testWidgets('Service can be started for flutter widgets test.',
      (WidgetTester tester) async {
    await tester.runAsync(() async => await _serviceUri());
  });
}
