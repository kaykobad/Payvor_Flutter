import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/splash_intro_new.dart';
import 'package:payvor/utils/AssetStrings.dart';
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
        body: Center(
          child: Container(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new SvgPicture.asset(
                    AssetStrings.logo,
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(
                    height: 10,
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

    Timer _timer = new Timer(const Duration(seconds: 2), () {
      var token = MemoryManagement.getAccessToken();
      Navigator.pushAndRemoveUntil(
        context,
        new CupertinoPageRoute(builder: (BuildContext context) {
          return (token == null)
              ? new SplashIntroScreenNew()
              : new SplashIntroScreenNew();
        }),
        (route) => false,
      );
    });
  }
}
