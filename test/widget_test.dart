// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kamera_yohou/main.dart';

void main() {
  testWidgets('API Getway test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Show mock API Gateway
    expect(find.text('aaa'), findsOneWidget);
    expect(find.text('bbb'), findsNWidgets(2));
    expect(find.text('cafwea'), findsOneWidget);
    expect(find.text('afefaewf'), findsOneWidget);
    expect(find.text('afeawfe'), findsOneWidget);
  });

  testWidgets('Page Transition test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect("Favarites List", findsOneWidget);
  });

}
