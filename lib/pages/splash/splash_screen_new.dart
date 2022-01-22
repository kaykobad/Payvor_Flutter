import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/pages/create_credential/create_credential.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/guest_view/guest_intro_screen.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/memory_management.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FadeIn();
}

enum UniLinksType { string, uri }

class FadeIn extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    moveToScreen();
  }



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.kPrimaryBlue,
        body: Container(
          margin:  EdgeInsets.only(top: 80.0),
          alignment: Alignment.center,
          child:  Column(children: <Widget>[
            Image.asset(
              AssetStrings.splashLogo,
              height: 240,
              width: 240,
            )
          ]),
        ),
      ),
    );
  }


  void moveToScreen() async {
    await MemoryManagement.init();
    var status = MemoryManagement.getUserLoggedIn() ?? false;

    var screenType = MemoryManagement.getScreenType();
    Timer _timer =  Timer(const Duration(seconds: 3), () {
      if (screenType == "1") {
        Navigator.pushAndRemoveUntil(
          context,
           CupertinoPageRoute(builder: (BuildContext context) {
            return (status) ?  DashBoardScreen() :  GuestIntroScreen();
          }),
          (route) => false,
        );
      } else if (screenType == "2") {
        Navigator.pushAndRemoveUntil(
          context,
           CupertinoPageRoute(builder: (BuildContext context) {
            return CreateCredential(
              type: true,
            );
          }),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
           CupertinoPageRoute(builder: (BuildContext context) {
            return (status) ?  DashBoardScreen() :  GuestIntroScreen();
          }),
          (route) => false,
        );
      }
    });
  }
}
