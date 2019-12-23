import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotList extends StatefulWidget {
  SpotList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<SpotList> {
  var _items = [];
  bool _isError;
  String _errMsg = "";
  final logger = Logger();

  final String url = DotEnv().env['MOCK_URL'];
  final String apiKey = DotEnv().env['MOCK_API_KEY'];

  //API Gateway経由でおすすめスポットの一覧を取得
  void _getItems() {
    var url = DotEnv().env['API_BASE_URL'].toString() + "/spots";
    var apiKey = DotEnv().env['API_KEY'];
    //APIをたたいて、スポットの情報を全取得したい
    http.get(url, headers: {'x-api-key': apiKey}).then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> body = json.decode(responseBody);
      logger.d(body);

      if(body['Items'] != null) {
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

  Widget _getSpotChild() {
    if (_items == null) {
      return Center(
        child: CircularProgressIndicator(), //取得中はグルグルを表示
      );
    } else {
      return ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, int index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              _items[index]["spot_name"],
              style: TextStyle(fontSize: 20),
            )
          );
        },
      );
    }
  }
  void _linkToRegister() {
    Navigator.of(context).pushNamed("/register");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getSpotChild(),
      floatingActionButton: FloatingActionButton(
        onPressed: _linkToRegister,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
