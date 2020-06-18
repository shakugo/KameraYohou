import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kamera_yohou/spotList.dart';

class MockClient extends Mock implements http.Client {}

Future<void> main() async {
  String widgetTitle = 'Spot List';
  group('UI', () {
    testWidgets('Spot List title', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SpotList(title: widgetTitle)));
      // Title shoud be Spot List
      expect(find.text(widgetTitle), findsOneWidget);
    });
    testWidgets('Open drawer menu', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SpotList(title: widgetTitle)));
      //Menu should be CLOSED when starting app
      expect(find.byType(Drawer), findsNothing);

      //Menu should be OPEND when tapping menu button
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);

      //Menu should be CLOSED when tapping Settings (?)
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
    });
  });

  group('API calling', () {
    testWidgets('Get data by one time', (tester) async {
      final mockClient = MockClient();
      final spotList = SpotList(title: widgetTitle);
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async =>
              http.Response('{"Items":{"subjects":["aaa","bbb"]}}', 200));
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async =>
              http.Response('{"Items":[],"Count":0,"ScannedCount":0}', 200));

      spotList.httpClient = mockClient;
      await tester.pumpWidget(MaterialApp(home: spotList));
      await tester.pumpAndSettle();
      //verify 'a called count is 1'
      verify(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    testWidgets('Get and output data ', (tester) async {
      final spotList = SpotList(title: widgetTitle);
      final mockClient = MockClient();
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async =>
              http.Response('{"Items":{"subjects":["aaa","bbb"]}}', 200));
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
              '{"Items":[{"spot_id":"abcdefg","spot_name":"ABCDEFG"}],"Count":1,"ScannedCount":1}',
              200));

      spotList.httpClient = mockClient;
      await tester.pumpWidget(MaterialApp(home: spotList));
      await tester.pumpAndSettle();
      //verify 'a called count is 1'
      expect(find.text('ABCDEFG'), findsOneWidget);
    });

    testWidgets('NO items message', (tester) async {
      final spotList = SpotList(title: widgetTitle);
      final mockClient = MockClient();
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response('{"Items":{"subjects":[]}}', 200));
      when(mockClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async =>
              http.Response('{"Items":[],"Count":0,"ScannedCount":0}', 200));

      spotList.httpClient = mockClient;
      await tester.pumpWidget(MaterialApp(home: spotList));
      await tester.pumpAndSettle();
      // Home is Spot List Widget
      expect(find.text('No Recommended Spots...'), findsOneWidget);
    });

    //TODO 400エラーのハンドリング

    //TODO http request エラーのハンドリング
  });
}
