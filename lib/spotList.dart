import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kamera_yohou/header.dart';
import 'package:kamera_yohou/footer.dart';
import 'package:kamera_yohou/menu.dart';

class SpotList extends StatefulWidget {
  SpotList({Key key, this.title}) : super(key: key);

  final String title;
  Client httpClient = Client();

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<SpotList> {
  var _items = [];
  bool _isError;
  String _errMsg = "";
  final logger = Logger();

  //API Gateway経由でおすすめスポットの一覧を取得
  void _getItems() async {
    var url = DotEnv().env['API_BASE_URL'].toString() + "/spots";
    var apiKey = DotEnv().env['API_KEY'];

    //APIをたたいて、スポットの情報を全取得したい
    widget.httpClient.get(url, headers: {'x-api-key': apiKey}).then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> body = json.decode(responseBody);
      if (response.statusCode == 200) {
        setState(() {
          _items = body["Items"];
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _errMsg = body["message"];
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
      child: Column(
        children: <Widget>[
          Image.asset('images/rain_animated.gif'),
          Text(
            "No Recommended Spots...",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0x55555555)),
            textScaleFactor: 1.5
          )
        ]
      )
    );
  }

  Widget spotItem(item) {
    return Text(
      item["spot_name"],
      style: TextStyle(fontSize: 20),
    );
  }

  Widget contents() {
    var scrollableView;
    //Sport itemが1件もない場合
    if (_items.length == 0) {
      scrollableView = LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              //Boxの高さを表示域限界に設定
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              //message and image Widget
              child: noItem()
            )
          )
      );
    } else {
      scrollableView = ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, int index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: spotItem(_items[index])
          );
        },
      );
    }

    return new RefreshIndicator(
      onRefresh: _refresh,
      child: scrollableView
    );
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
