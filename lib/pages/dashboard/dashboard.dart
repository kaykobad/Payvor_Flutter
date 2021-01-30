import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/chat/chat_screen.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/dummy.dart';
import 'package:payvor/pages/intro_screen/splash_intro_new.dart';
import 'package:payvor/pages/post/post_home.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/search/search_home.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:provider/provider.dart';

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
  final _dummyScreen = GlobalKey<NavigatorState>();

  int currentTab = 0; // to keep track of active tab index

  final PageStorageBucket bucket = PageStorageBucket();

  Color selectedColor = AppColors.bluePrimary;
  Color unselectedColor = AppColors.moreText;

  // double selectedDotSize = 20;
  double selectedDotSize = 0;
  FirebaseProvider _firebaseProvider;
  bool _isNewActivityFound = false;

  String userName = "";
  String userId = "";
  String profile = "";

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    var data = await Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: new PostFavour());
      }),
    );

    (currentTab == 0)
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  ValueChanged<Widget> homeCallBack(Widget screen) {
    _redirect(screen);
  }

  ValueChanged<int> callbackChangePage(int type) {
    currentTab = type;
    setState(() {});
  }

  void _redirect(Widget screen) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    var value = await Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return screen;
      }),
    );
    print("callback $value");
    (currentTab == 0)
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  VoidCallback logoutCallBack() {
    _logout();
  }

  void _logout() async {
    await MemoryManagement.clearMemory();

    Navigator.pushAndRemoveUntil(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new SplashIntroScreenNew();
      }),
      (route) => false,
    );
  }

  @override
  void initState() {
    // TODO: implement initState

    print("dashboard");

    MemoryManagement.setScreenType(type: "3");
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    Future.delayed(Duration(milliseconds: 200), () {
      _setupCounterChangeListener();
    });

    var userData = MemoryManagement.getUserInfo();
    if (userData != null) {
      Map<String, dynamic> data = jsonDecode(userData);
      LoginSignupResponse userResponse = LoginSignupResponse.fromJson(data);
      userName = userResponse.user.name ?? "";
      profile = userResponse.user.profilePic ?? "";
      userId = userResponse.user.id.toString();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _firebaseProvider.notificationStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    _firebaseProvider = Provider.of<FirebaseProvider>(context);
    _firebaseProvider.setHomeContext(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: AppColors.kAppScreenBackGround,
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
                        SearchCompany(
                        lauchCallBack: homeCallBack,
                        callbackmyid: callbackChangePage,
                        userid: userId?.toString(),
                      ),
                  )),
            Navigator(
              key: _chatScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) =>
                        PostScreen(
                          lauchCallBack: homeCallBack,
                        ),
                  ),
            ),
            Navigator(
              key: _dummyScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) =>
                        Dummy(
                          logoutCallBack: logoutCallBack,
                        ),
                  ),
            ),
            Navigator(
              key: _notificationScreen,
              onGenerateRoute: (route) =>
                  MaterialPageRoute(
                    settings: route,
                    builder: (context) =>
                        ChatScreen(logoutCallBack: logoutCallBack,),
                  ),
            ),
            Navigator(
              key: _profileScreen,
              onGenerateRoute: (route) => MaterialPageRoute(
                settings: route,
                builder: (context) => Dummy(logoutCallBack: logoutCallBack),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: CustomFloatingButton(),
          onPressed: () {
            redirect();
          },
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          // height: 65,
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: bottomMenuIconWidget( AssetStrings.home_inactive),
                  activeIcon: bottomMenuIconWidget( AssetStrings.home_active),
                  label: ""),
              BottomNavigationBarItem(
                  icon: bottomMenuIconWidget( AssetStrings.job_inactive),
                  activeIcon: bottomMenuIconWidget( AssetStrings.job_active),
                  label: ""),
              BottomNavigationBarItem(
                  icon: firstWidget(AppColors.kWhite, AssetStrings.group),
                  activeIcon: firstWidget(AppColors.kWhite, AssetStrings.group),
                  label: ""),
              BottomNavigationBarItem(
                  icon: bottomMenuIconWidget(
                      (_isNewActivityFound) ? AssetStrings
                          .activity_unselected_with_noti : AssetStrings
                          .activity_not_selected),
                  activeIcon: bottomMenuIconWidget(
                      (_isNewActivityFound) ? AssetStrings
                          .activity_selected_with_noti : AssetStrings
                          .activity_selected),
                  label: ""),

              BottomNavigationBarItem(
                  icon: bottomMenuIconWidget( AssetStrings.profile_inactive),
                  activeIcon: bottomMenuIconWidget( AssetStrings.profile_active),
                  label: ""),
            ],
            currentIndex: currentTab,
            onTap: (int index) {
              setState(() {
                currentTab = index;
                if (index == 0) //for home tab
                    {
                  SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.light);

                  _homeScreen.currentState?.popUntil((route) => route.isFirst);
                } else if (index == 2) {
                  redirect();
                } else {
                  SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark);
                }
              });
            },
          ),
        ),

      ),
    );
  }




  Widget firstWidget(Color color, String image) {
    return SvgPicture.asset(image, width: Constants.bottomIconSize,
        height: Constants.bottomIconSize,
        color: color);
  }

  Widget bottomMenuIconWidget(String image) {
    return SvgPicture.asset(image, width: Constants.bottomIconSize,
      height: Constants.bottomIconSize,
    );
  }

  void _setupCounterChangeListener() {
    _firebaseProvider.setStreamNotifier(StreamController<bool>()) ;
    _firebaseProvider.notificationStreamController.stream.listen((event) {
      print("notificatoion count status $event");

      if(event!=_isNewActivityFound)
        {
          print("update called");
          _isNewActivityFound=event;
          setState(() {

          });
        }

    });
  }

}


class CustomFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 87,
      height: 87,
      padding: new EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle),


      child: Container(

        width: 85,
        height: 85,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: new SvgPicture.asset(
            AssetStrings.plushome,
          ),
        ),
        decoration: BoxDecoration(
            color: AppColors.colorDarkCyan,
            shape: BoxShape.circle),
      ),
    );
  }

}
