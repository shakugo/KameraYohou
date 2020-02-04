import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'package:kamera_yohou/currentLocation.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String url = DotEnv().env['API_BASE_URL'].toString() + "/subjects";
  String apiKey = DotEnv().env['API_KEY'];
  final logger = Logger();
  final inputTextController = TextEditingController();

  //state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var _datas = [];
  bool _isError;
  String _errMsg = "";

  //API Gateway経由で登録済み被写体一覧を取得
  void _getSubjects() {
    http.get(url, headers: {'x-api-key': apiKey}).then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> body = json.decode(responseBody);
      logger.d(body);

      if (body['Items'] != null) {
        setState(() {
          _datas = body["Items"];
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

  //API Gateway経由で被写体新規登録
  void _registerSubjects() {
    String subjectName = inputTextController.text;
    List<int> bytes = utf8.encode(subjectName); // data being hashed
    var digest = sha1.convert(bytes);
    Map<String, Object> reqBody = {
      "subject_id": digest.toString(),
      "subject_name": subjectName
    };

    //リクエスト送信
    http
        .post(url, headers: {'x-api-key': apiKey}, body: json.encode(reqBody))
        .then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> resBody = json.decode(responseBody);
      _datas.add(reqBody);
      setState(() {
        _datas = _datas;
      });
      logger.d(resBody);
    }).catchError((err) {
      setState(() {
        _isError = true;
        _errMsg = err.toString();
      });
    });

    inputTextController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _refresh() async {
    await Future.sync(() {
      _getSubjects();
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  //入力フォーム
  Widget inputFormUI() {
    return Row(
      children: <Widget>[
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Enter a new Subject'),
          controller: inputTextController,
          autofocus: true,
          validator: (value) {
            if (value.isEmpty) {
              return "Please input text!";
            }
            return null;
          },
        )),
        RaisedButton(
            child: Text("Add"),
            color: Colors.red,
            shape: StadiumBorder(),
            onPressed: _validateInputs),
      ],
    );
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      // If all data are correct then save data to out variables
      _formKey.currentState.save();
      _registerSubjects();
    } else {
      // If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  void dispose() {
    inputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favarites List"),
      ),
      body: ListView.builder(
        itemCount: _datas.length,
        itemBuilder: (context, int index) {
          return Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                _datas[index]["subject_name"],
                style: TextStyle(fontSize: 20),
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
        onPressed: () {
          //最下部から出現する入力フォーム
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)),
              ),
              builder: (context) => Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: inputFormUI())));
        },
      ),
    );
  }
}
