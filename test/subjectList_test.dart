import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kamera_yohou/subjectList.dart';

void main() {
  testWidgets('SubjectList ', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: new Subject(title: 'Favarites List')));
    // Home is Spot List Widget
    expect(find.text('Favarites List'), findsOneWidget);
  });
}
