import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MyBottomNavigationBarDemo extends StatefulWidget {
  @override
  _MyBottomNavigationBarDemoState createState() =>
      _MyBottomNavigationBarDemoState();
}

class _MyBottomNavigationBarDemoState extends State<MyBottomNavigationBarDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bottom Navigation Bar Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.deepPurple,
        buttonBackgroundColor: Colors.deepPurple,
        animationCurve: Curves.bounceIn,
        height: 60,
        animationDuration: Duration(
          milliseconds: 200,
        ),
        index: 2,
        items: <Widget>[
          Icon(Icons.favorite, size: 30, color: Colors.white),
          Icon(Icons.verified_user, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
          Icon(Icons.more_horiz, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          //Handle button tap
        },
      ),
    );
  }
}
