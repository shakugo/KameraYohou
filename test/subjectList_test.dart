import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kamera_yohou/subjectList.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  String widgetTitle = 'Favarite List';

  group('UI', (){
    testWidgets('SubjectList title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: new SubjectList(title: widgetTitle)));
      // title is 'Favarite List'
      expect(find.text(widgetTitle), findsOneWidget);
    });

    // testWidgets('push PLUS button', (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home: new SubjectList(title: widgetTitle)));
    //   expect(find.text('Add'), findsNothing);
    //   await tester.tap(find.byType(FloatingActionButton));
    //   await tester.pumpAndSettle();
    //   // title is 'Favarite List'
    //   expect(find.text('Add'), findsOneWidget);

    //   //Quiet animation controller for test exit
    //   // await tester.pageBack();
    //   await tester.tap(find.byIcon(Icons.arrow_back));
    //   await tester.pumpAndSettle();
    //   // expect(find.text('Add'), findsNothing);
    // });
  });
  group('API calling', () {
    group('GET', (){
      testWidgets('Get data by one time', (WidgetTester tester) async {
        final mockClient = MockClient();
        final subjectList = SubjectList(title: widgetTitle);
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async =>
                http.Response('{"Items":[],"Count":0,"ScannedCount":0}', 200));

        subjectList.httpClient = mockClient;
        await tester.pumpWidget(MaterialApp(home: subjectList));
        await tester.pumpAndSettle();
        //verify 'a called count is 1'
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      testWidgets('Get and output data ', (WidgetTester tester) async {
        final subjectList = SubjectList(title: widgetTitle);
        final mockClient = MockClient();
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(
                '{"Items":[{"subject_id":"abcdefg","subject_name":"ABCDEFG","available_flag":true}],"Count":1,"ScannedCount":4}',
                200));

        subjectList.httpClient = mockClient;
        await tester.pumpWidget(MaterialApp(home: subjectList));
        await tester.pump();
        //subject_name should be shown
        expect(find.text('ABCDEFG'), findsOneWidget);
      });
    });

    group('POST', (){
      testWidgets('Push add button and request POST', (WidgetTester tester) async {
        final mockClient = MockClient();
        final subjectList = SubjectList(title: widgetTitle);
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(
                '{"Items":[],"Count":0,"ScannedCount":0}',
                200));
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).thenAnswer(
            (_) async =>
                http.Response('{"Items":[],"Count":0,"ScannedCount":0}', 200));

        subjectList.httpClient = mockClient;
        await tester.pumpWidget(MaterialApp(home: subjectList));
        await tester.pumpAndSettle();
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
        expect(find.text('ABCDEFG'), findsNothing);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        //Enter text
        await tester.enterText(find.byType(TextFormField), 'ABCDEFG');
        await tester.pumpAndSettle();

        //tap add button
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        //verfy delete item
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
        expect(find.text('ABCDEFG'), findsOneWidget);
      });
    });
    group('DELETE', (){
      testWidgets('Push delete button and request DELETE', (WidgetTester tester) async {
        final mockClient = MockClient();
        final subjectList = SubjectList(title: widgetTitle);
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(
                '{"Items":[{"subject_id":"abcdefg","subject_name":"ABCDEFG","available_flag":true}],"Count":1,"ScannedCount":4}',
                200));
        when(mockClient.delete(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async =>
                http.Response('{"Items":[],"Count":0,"ScannedCount":0}', 200));

        subjectList.httpClient = mockClient;
        await tester.pumpWidget(MaterialApp(home: subjectList));
        await tester.pumpAndSettle();
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
        expect(find.text('ABCDEFG'), findsOneWidget);

        //tap delete button
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        //verfy delete item
        verify(mockClient.delete(any, headers: anyNamed('headers'))).called(1);
        expect(find.text('ABCDEFG'), findsNothing);
      });
    });
    //TODO 400エラーのハンドリング

    //TODO http request エラーのハンドリング
  });
}
