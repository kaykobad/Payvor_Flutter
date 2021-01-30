import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/pages/join_community/join_community.dart';
import 'package:payvor/pages/login/login.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';

class SplashIntroScreenNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FadeIn();
}

class FadeIn extends State<SplashIntroScreenNew> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: size.width,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              //  BackgroundImage(),
              new Column(children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  margin: new EdgeInsets.only(top: 124),
                  child: new Image.asset(
                    AssetStrings.logopng,
                    width: 140,
                    height: 123,
                  ),
                ),
              ]),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: new Column(
                  children: <Widget>[
                    Container(
                        child: getSetupDecoratorButtonNew(
                            callbackSignin, ResString().get('login'), 20)),
                    new SizedBox(
                      height: 16.0,
                    ),
                    Container(
                        child: getSetupButtonNew(
                            callback, ResString().get('sign_up'), 20)),
                    new SizedBox(
                      height: 90.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void callback() {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new JoinCommunityNew();
      }),
    );
  }

  void callbackSignin() {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new LoginScreenNew();
      }),
    );
  }
}
