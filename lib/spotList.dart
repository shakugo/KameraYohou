import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SpotList extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spot List',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Spot List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var _items = [];

  void _getItems() {
    var url = "MOCKURL";
    //APIをたたいて、スポットの情報を全取得したい
    http.get(url).then((response){
      print("Fetch API");
      Map<String, dynamic> body = json.decode(response.body);
      print(body);
      setState((){
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
    if(_items == null) {
      return Center(
        child: CircularProgressIndicator(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getSpotChild(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getItems,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
