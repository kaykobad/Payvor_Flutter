import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/join_community.dart';
import 'package:payvor/pages/login.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                  child: new SvgPicture.asset(
                    AssetStrings.logo,
                    height: 117,
                    width: 140,
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
                            callbackSignin, "Login", 20)),
                    new SizedBox(
                      height: 16.0,
                    ),
                    Container(
                        child: getSetupButtonNew(callback, "Sign up", 20)),
                    new SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              )
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
