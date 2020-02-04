import 'package:flutter/material.dart';

//We need title arg
class Header extends StatelessWidget with PreferredSizeWidget {
  Header({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
    );
  }
}
