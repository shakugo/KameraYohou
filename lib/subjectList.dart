import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kamera_yohou/header.dart';

class SubjectList extends StatefulWidget {
  SubjectList({Key key, this.title}) : super(key: key);

  final String title;
  Client httpClient = Client();

  @override
  _SubjectState createState() => _SubjectState();
}

class _SubjectState extends State<SubjectList> {
  String url = DotEnv().env['API_BASE_URL'].toString() + "/user/1/subjects";
  String apiKey = DotEnv().env['API_KEY'];
  final logger = Logger();
  final inputTextController = TextEditingController();

  //state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var _datas = [];
  bool _isError;
  String _errMsg = "";

  //API Gateway経由で登録済み被写体の一覧を取得
  void _getSubjects() {
    widget.httpClient.get(url, headers: {'x-api-key': apiKey}).then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> body = json.decode(responseBody);
      if (body['Item'] != null) {
        setState(() {
          _datas = body["Item"]["subjects"];
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

  //API Gateway経由で被写体の新規登録
  void _registerSubjects() {
    String subjectName = inputTextController.text;
    Map<String, Object> reqBody = {"subject_name": subjectName};

    //リクエストの送信
    widget.httpClient
        .post(url, headers: {'x-api-key': apiKey}, body: json.encode(reqBody))
        .then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> resBody = json.decode(responseBody);
      _datas.add(subjectName);
      setState(() {
        _datas = _datas;
      });
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

  //Validater
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

  //論理削除リクエストの送信
  void _deleteSubject(String subjectId) {
    widget.httpClient.delete(url + "/" + subjectId,
        headers: {'x-api-key': apiKey}).then((response) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> body = json.decode(responseBody);

      if (response.statusCode == 200) {
        setState(() {
          _datas = _datas
              .where((item) => (item["subject_id"] != subjectId))
              .toList();
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

  //最下部から出現するアレ
  void _showBottomForm(BuildContext context) {
    inputTextController.clear();
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        builder: (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: inputFormUI(),
            )));
  }

  void dispose() {
    inputTextController.dispose();
    super.dispose();
  }

  //Item
  Widget subjectItem(item) {
    return Row(children: <Widget>[
      Expanded(
        child: Text(
          item,
          style: TextStyle(fontSize: 20),
        ),
      ),
      RaisedButton(
          child: Icon(Icons.delete, color: Colors.red),
          shape: CircleBorder(
              side: BorderSide(
            color: Colors.black,
            width: 1.0,
            style: BorderStyle.none,
          )),
          onPressed: () => _deleteSubject(item["subject_id"])),
    ]);
  }

  //入力フォーム
  Widget inputFormUI() {
    return Row(
      children: <Widget>[
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter a new Subject',
              contentPadding: const EdgeInsets.all(20.0)),
          controller: inputTextController,
          scrollPadding: const EdgeInsets.all(20.0),
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
            color: Colors.orange,
            shape: StadiumBorder(),
            onPressed: _validateInputs),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: widget.title),
      body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: _datas.length,
            itemBuilder: (context, int index) {
              return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: subjectItem(_datas[index]));
            },
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showBottomForm(context),
      ),
    );
  }
}
