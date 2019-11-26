import 'package:flutter/material.dart';

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
    //APIをたたいて、スポットの情報を全取得したい
    var newItems = [
      {"id": "oawjoifja", "name": "aaa"},
      {"id": "oawjoifja", "name": "bbb"},
      {"id": "oawjoifja", "name": "bbb"},
      {"id": "oawjoifja", "name": "cafwea"},
      {"id": "oawjoifja", "name": "afefaewf"},
      {"id": "oawjoifja", "name": "afeawfe"},
      {"id": "oawjoifja", "name": "afawef"},
      {"id": "oawjoifja", "name": "awefaew"},
      {"id": "oawjoifja", "name": "afwefae"},
    ];

    setState(() {
      _items = newItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getItems();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, int index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              _items[index]["name"],
            ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getItems,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
