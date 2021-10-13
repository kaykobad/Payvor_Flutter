import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/pages/join_community/join_community.dart';
import 'package:payvor/pages/login/login.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';

class GuestView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FadeIn();
}

class FadeIn extends State<GuestView> {
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
      color: AppColors.blue,
      home: Scaffold(
        backgroundColor: AppColors.blue,
        body: SafeArea(
          child: Container(
            width: size.width,
            color: AppColors.blue,
            child: Stack(
              children: <Widget>[
                //  BackgroundImage(),
                new Column(children: <Widget>[
                 /* InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: new EdgeInsets.only(top: 20, left: 24),
                      child: new Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),*/
                  Container(
                    alignment: Alignment.center,
                    margin: new EdgeInsets.only(top: 124),
                    child: new Image.asset(
                      AssetStrings.guestView,
                      width: 168,
                      height: 131,
                    ),
                  ),
                  new Container(
                    alignment: Alignment.center,
                    margin: new EdgeInsets.only(top: 34),
                    child: new Text(
                      "You’re on Guest View",
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 20,
                        color: AppColors.kWhite,
                      ),
                    ),
                  ),
                  new Container(
                    alignment: Alignment.center,
                    margin: new EdgeInsets.only(top: 6, left: 40, right: 40),
                    child: new Text(
                      "You need to login or create an account to view this screen",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.grayy,
                      ),
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
                          child: getSetupButtonNew(callback, "Login", 20,
                              newColor: AppColors.blue)),
                      new SizedBox(
                        height: 16.0,
                      ),
                      Container(
                          child: getSetupDecoratorButtonNew(
                              callbackSignin, "Create an Account", 20,
                              newColor: AppColors.blue,
                              textColor: AppColors.kBlack)),
                      new SizedBox(
                        height: 16.0,
                      ),
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
      ),
    );
  }

  void callback() {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new LoginScreenNew();
      }),
    );
  }

  void callbackSignin() {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new JoinCommunityNew();
      }),
    );
  }
}
