import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kamera_yohou/spotList.dart';

class MockClient extends Mock implements http.Client {}

class MockEnv extends Mock implements DotEnv {}

void main() async {
  String widgetTitle = 'Spot List';
  group('UI', () {
    testWidgets('Spot List title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: new SpotList(title: widgetTitle)));
      // Title shoud be Spot List
      expect(find.text(widgetTitle), findsOneWidget);
    });
  });

  group('API calling', () {
    testWidgets('Get data by one time', (WidgetTester tester) async {
      final mockClient = MockClient();
      final spotList = SpotList(title: widgetTitle);
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async =>
              http.Response('{"Items":[],"Count":0,"ScannedCount":0}', 200));

      spotList.httpClient = mockClient;
      await tester.pumpWidget(MaterialApp(home: spotList));
      await tester.pump();
      //verify 'a called count is 1'
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    testWidgets('Get and Outout data ', (WidgetTester tester) async {
      final spotList = SpotList(title: widgetTitle);
      final mockClient = MockClient();
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
              '{"Items":[{"spot_id":"abcdefg","spot_name":"ABCDEFG"}],"Count":1,"ScannedCount":1}',
              200));

      spotList.httpClient = mockClient;
      await tester.pumpWidget(MaterialApp(home: spotList));
      await tester.pump();
      //verify 'a called count is 1'
      expect(find.text('ABCDEFG'), findsOneWidget);
    });

    testWidgets('NO items message', (WidgetTester tester) async {
      final spotList = SpotList(title: widgetTitle);
      final mockClient = MockClient();
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async =>
              http.Response('{"Items":[],"Count":0,"ScannedCount":0}', 200));

      spotList.httpClient = mockClient;
      await tester.pumpWidget(MaterialApp(home: spotList));
      await tester.pump();
      // Home is Spot List Widget
      expect(find.text('No Recommended Spots...'), findsOneWidget);
    });

    //TODO 400エラーのハンドリング

    //TODO http request エラーのハンドリング
  });
}
