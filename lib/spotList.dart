import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotList extends StatefulWidget {
  SpotList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SpotList> {
  var _items = [];

  //API Gateway経由でおすすめスポットの一覧を取得
  void _getItems() {
    var url = DotEnv().env['MOCK_URL'];
    var apiKey = DotEnv().env['MOCK_API_KEY'];
    //APIをたたいて、スポットの情報を全取得
    http.get(url, headers: {'x-api-key': apiKey}).then((response) {
      print("Fetch API");
      Map<String, dynamic> body = json.decode(response.body);
      print(body);
      setState(() {
        _items = body['data'];
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
                _items[index]["name"],
              ));
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
