// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:connect_vm/service/connect.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connect_vm/main.dart';

void main() {
  testWidgets('Retaining path is detectable.', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final state = tester.state(find.byType(MyHomePage));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    final path =
        await tester.runAsync(() => getRetainingPath(ObjectFingerprint(state)));
    print(path);
  });

  test('Retaining path is reported in debug mode.', () async {
    late MyClass notGCedObject;
    late int code;

    Future<void> doSomething() async {
      notGCedObject = MyClass();
      code = identityHashCode(notGCedObject);
      // Dispose reachable instance.
      notGCedObject.dispose();
    }

    await doSomething();

    final path =
        await getRetainingPath(ObjectFingerprint.byCode('MyClass', code));
    print(path);
  });
}

class MyClass {
  MyClass();

  void dispose() {}
}
