import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/intro_screen/splash_intro_new.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/memory_management.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FadeIn();
}

class FadeIn extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    moveToScreen();
  }

  @override
  Widget build(BuildContext context) {
//    var width = MediaQuery
//        .of(context)
//        .size
//        .width;
//    var height = MediaQuery
//        .of(context)
//        .size
//        .height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.kPrimaryBlue,
        body: Center(
          child: Container(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Lottie.asset(
                    'assets/payvor.json',
                    repeat: true,
                    reverse: false,
                    animate: true,
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  void moveToScreen() async {
    //ebale firebase store local caceh
//    await Firestore.instance.settings(
//           persistenceEnabled: true,
//    );
    await MemoryManagement.init();
    //show tutorial on home screen
    //  MemoryManagement.setToolTipState(state:TUTORIALSTATE.HOME.index);
   var status= MemoryManagement.getUserLoggedIn()??false;
    Timer _timer = new Timer(const Duration(seconds: 2), () {

      Navigator.pushAndRemoveUntil(
        context,
        new CupertinoPageRoute(builder: (BuildContext context) {
          return (status)
              ? new DashBoardScreen()
              : new SplashIntroScreenNew();
        }),
        (route) => false,
      );
    });
  }
}