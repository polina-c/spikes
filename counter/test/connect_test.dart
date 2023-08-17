import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';

Future<Uri> _serviceUri() async {
  Uri? uri = (await Service.getInfo()).serverWebSocketUri;

  if (uri != null) return uri;

  uri = (await Service.controlWebServer(enable: true)).serverWebSocketUri;

  const timeout = Duration(seconds: 5);
  final stopwatch = Stopwatch()..start();

  while (uri == null) {
    if (stopwatch.elapsed > timeout) {
      throw StateError(
        'Could not start VM service.',
      );
    }
    await Future.delayed(const Duration(milliseconds: 1));
    uri = (await Service.getInfo()).serverWebSocketUri;
  }

  return uri;
}

void main() {
  test('Service can be started for flutter test.', () async {
    Uri? uri;

    uri = await _serviceUri();

    print(uri);
  });

  testWidgets('Service can be started for flutter widgets test.',
      (WidgetTester tester) async {
    Uri? uri;

    await tester.runAsync(() async => uri = await _serviceUri());

    print(uri);
  });
}
