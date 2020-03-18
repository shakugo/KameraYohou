import 'package:flutter_test/flutter_test.dart';
import 'package:kamera_yohou/main.dart';

void main() {
  testWidgets('Home App title', (tester) async {
    await tester.pumpWidget(MyApp());
    // Home is Spot List Widget
    expect(find.text('Spot List'), findsOneWidget);
  });
}
