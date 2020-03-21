import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kamera_yohou/header.dart';
import 'package:kamera_yohou/footer.dart';
import 'package:kamera_yohou/menu.dart';

// ignore: must_be_immutable
class SpotList extends StatefulWidget {
  SpotList({Key key, this.title}) : super(key: key);

  final String title;
  @visibleForTesting
  Client httpClient = Client();

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<SpotList> {
  List<String> _subjects;
  List<Map<String, String>> _items = [];
  bool _isError;
  String _errMsg = "";
  final logger = Logger();
  String baseUrl = DotEnv().env['API_BASE_URL'].toString();
  String apiKey = DotEnv().env['API_KEY'];

  //API Gateway経由でユーザ情報を取得
  Future<void> _getSubjectsByUser() async {
    String endpoint = baseUrl + "/user/1/subjects";

    await widget.httpClient
        .get(endpoint, headers: {'x-api-key': apiKey}).then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      dynamic body = json.decode(responseBody);
      if (response.statusCode == 200) {
        setState(() {
          _subjects = body["Item"]["subjects"] as List<String>;
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _errMsg = body["message"].toString();
        });
      }
    }).catchError((err) {
      setState(() {
        _isError = true;
        _errMsg = err.toString();
      });
    });
  }

  //API Gateway経由でおすすめスポットの一覧を取得
  Future<void> _getItems() async {
    String endpoint = baseUrl + "/spots";
    Map<String, Object> reqBody = {"subjects": _subjects};

    //APIをたたいて、スポットの情報を全取得したい
    await widget.httpClient
        .post(endpoint,
            headers: {'x-api-key': apiKey}, body: json.encode(reqBody))
        .then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      dynamic body = json.decode(responseBody);
      if (response.statusCode == 200) {
        setState(() {
          _items = body["Items"] as List<Map<String, String>>;
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _errMsg = body["message"].toString();
        });
      }
    }).catchError((err) {
      setState(() {
        _isError = true;
        _errMsg = err.toString();
      });
    });
  }

  Future<void> _refresh() async {
    await Future.sync(() {
      _getSubjectsByUser();
      _getItems();
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Widget noItem() {
    return Center(
        child: Column(children: <Widget>[
      Image.asset('images/rain_animated.gif'),
      Text("No Recommended Spots...",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0x55555555)),
          textScaleFactor: 1.5)
    ]));
  }

  Widget spotItem(Map<String, String> item) {
    return Text(
      item["spot_name"],
      style: TextStyle(fontSize: 20),
    );
  }

  Widget contents() {
    Widget scrollableView;
    //Sport itemが1件もない場合
    if (_items.isEmpty) {
      scrollableView = LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                  //Boxの高さを表示域限界に設定
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  //message and image Widget
                  child: noItem())));
    } else {
      scrollableView = ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.all(8.0), child: spotItem(_items[index]));
        },
      );
    }

    return RefreshIndicator(onRefresh: _refresh, child: scrollableView);
  }

  //TODO: Error発生時の出力
  void printError() {
    if (_isError) {
      logger.e(_errMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: widget.title),
      drawer: Menu(),
      body: contents(),
      bottomNavigationBar: Footer(),
    );
  }
}
