import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/search/search_home.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
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

  Color selectedColor = AppColors.bluePrimary;
  Color unselectedColor = AppColors.moreText;

  // double selectedDotSize = 20;
  double selectedDotSize = 0;

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
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: new PostFavour());
      }),
    );
  }

  ValueChanged<Widget> homeCallBack(Widget screen) {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return screen;

      }),
    );
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
          sizing: StackFit.loose,
          children: <Widget>[
            Navigator(
              key: _homeScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) =>
                        SearchCompany(lauchCallBack: homeCallBack,),
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
          height: MediaQuery
              .of(context)
              .size
              .width * 0.22,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.2,
          margin: new EdgeInsets.only(top: 20.0),
          child: FloatingActionButton(

            child: CustomFloatingButton(),
            onPressed: () {
              redirect();
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAlias,
           shape: CircularNotchedRectangle(),
          notchMargin: 15.0,
          child: Container(
            color: Colors.transparent,
            height: 85,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _bottomTabWidget(AssetStrings.home, currentTab == 0, 0),
                      _bottomTabWidget(AssetStrings.job, currentTab == 1, 1),
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
                          AssetStrings.group, currentTab == 2, 2),
                      _bottomTabWidget(AssetStrings.profile, currentTab == 3, 3)
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

  Widget _bottomTabWidget(String icon, bool isChecked, int pos) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        if (pos == 0) //for home tab
            {
          _homeScreen.currentState?.popUntil((route) => route.isFirst);
        }
        setState(() {
          currentTab = pos;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new SvgPicture.asset(
            icon,
            width: Constants.bottomIconSize,
            height: Constants.bottomIconSize,
            color: isChecked ? selectedColor : unselectedColor,
          ),
          SizedBox(
            height: 3,
          ),
          /* Visibility(
              visible: isChecked,
              child: Container(
                height: 5,
                width: 5,
                decoration: new BoxDecoration(
                  color: isChecked ? selectedColor : unselectedColor,
                  shape: BoxShape.circle,
                ),
              ))*/
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
        size: 40,
      ),
      decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [
            AppColors.colorCyanPrimary,
            AppColors.colorCyanPrimary
          ])),
    );
  }

}
