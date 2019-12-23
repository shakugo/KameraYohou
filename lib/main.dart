import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kamera_yohou/spotList.dart';
import 'package:kamera_yohou/register.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SpotList(title: 'Kamera Yohou | Sport List'),
      routes: <String, WidgetBuilder>{
        '/register': (_) => new Register(),
      },
    );
  }
}
