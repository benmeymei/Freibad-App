import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function onTap;

  CustomBottomNavigationBar({this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => onTap(index),
      elevation: 10,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).accentColor,
      backgroundColor: Theme.of(context).backgroundColor,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.vpn_key),
          title: Text('Codes'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.date_range),
          title: Text('Pick'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
    );
  }
}
