import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
// TODO 今は決め打ちでリストの中身が入ってるので可変にする?
  List<KeyValueFavorites> _datas = [
    KeyValueFavorites(key: "桜", isChecked: false),
    KeyValueFavorites(key: "バラ", isChecked: false),
    KeyValueFavorites(key: "菊", isChecked: false),
    KeyValueFavorites(key: "紅葉", isChecked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favarites List"),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: _datas
            .map((text) => CheckboxListTile(
                  title: Text(text.key),
                  value: text.isChecked,
                  onChanged: (val) {
                    setState(() {
                      text.isChecked = val;
                    });
                  },
                ))
            .toList(),
      ),
    );
  }
}

// favoritesのリストにそれぞれキー、バリューを持たせるため
class KeyValueFavorites {
  String key;
  bool isChecked;

  KeyValueFavorites({this.key, this.isChecked});
}
