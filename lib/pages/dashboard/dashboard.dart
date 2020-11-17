import 'dart:io';

import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/constants.dart';

import '../dummy.dart';


class DashBoardScreen extends StatefulWidget {
  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  // Properties & Variables needed

  //bottom navigator keys

  final _homeScreen = GlobalKey<NavigatorState>();
  final _chatScreen = GlobalKey<NavigatorState>();
  final _notificationScreen = GlobalKey<NavigatorState>();
  final _profileScreen = GlobalKey<NavigatorState>();

  int currentTab = 0; // to keep track of active tab index

  final PageStorageBucket bucket = PageStorageBucket();

  Color selectedColor = AppColors.kFirstGradientColor;
  Color unselectedColor = Colors.grey[400];
  double selectedDotSize = 20;

  Future<bool> _onBackPressed() async {
    bool canPop = false;
    switch (currentTab) {
      case 0:
        {
          canPop = _homeScreen.currentState.canPop();
          if (canPop) _homeScreen.currentState.pop();
          break;
        }
      case 3:
        {
          canPop = _profileScreen.currentState.canPop();
          if (canPop) _profileScreen.currentState.pop();

          break;
        }

      case 1:
        {
          canPop = _chatScreen.currentState.canPop();
          if (canPop) _chatScreen.currentState.pop();

          break;
        }
      case 2:
        {
          canPop = _notificationScreen.currentState.canPop();
          if (canPop) _notificationScreen.currentState.pop();

          break;
        }
    }
    if (!canPop) //check if screen popped or not and showing home tab data
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Exit the app?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  exit(0); //close app
                },
              ),
            ],
          );
        },
      ) ??
          false;
  }

  redirect() async {
    //Navigator.of(context).pushNamed(Routes.nearpost);

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
//      body: PageStorage(
//        child: screens[currentTab],
//        bucket: bucket,
//      ),
        body: IndexedStack(
          index: currentTab,
          children: <Widget>[
            Navigator(
              key: _homeScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) => Dummy(),
                  ),
            ),
            Navigator(
              key: _chatScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) => Dummy(),
                  ),
            ),
            Navigator(
              key: _notificationScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) => Dummy(),
                  ),
            ),
            Navigator(
              key: _profileScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) => Dummy(),
                  ),
            ),
          ],
        ),
        floatingActionButton: Container(
          height: MediaQuery.of(context).size.width * 0.2,
          width: MediaQuery.of(context).size.width * 0.2,
          child: FloatingActionButton(

            child:CustomFloatingButton(),
            onPressed: () {
              redirect();
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAlias,
          shape: CircularNotchedRectangle(),
          notchMargin: 20.0,
          child: Container(
            height: 80,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _bottomTabWidget(Icons.home, currentTab == 0, 0),
                      _bottomTabWidget(Icons.explore, currentTab == 1, 1),
                    ],
                  ),
                ),

                // Right Tab bar icons
                SizedBox(
                  width: 80,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _bottomTabWidget(
                          Icons.notifications_none, currentTab == 2, 2),
                      _bottomTabWidget(Icons.account_circle, currentTab == 3, 3)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomTabWidget(IconData icon, bool isChecked, int pos) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentTab = pos;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: Constants.bottomIconSize,
            color: isChecked ? selectedColor : unselectedColor,
          ),
          SizedBox(
            height: 6,
          ),
          Visibility(
              visible: isChecked,
              child: Container(
                height: 5,
                width: 5,
                decoration: new BoxDecoration(
                  color: isChecked ? selectedColor : unselectedColor,
                  shape: BoxShape.circle,
                ),
              ))
        ],
      ),
    );
  }
}

class CustomFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 85,
      height: 85,
      child: Icon(
        Icons.add,
        size: 24,
      ),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [
            AppColors.kFirstGradientColor,
            AppColors.kSecondGradientColor
          ])),
    );
  }

}
