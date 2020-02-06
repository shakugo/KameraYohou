import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'KameraYohou',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('User Info'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Subject List'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed("/register");
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
