import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/pages/guest_view/guest_view.dart';
import 'package:payvor/pages/join_community/join_community.dart';
import 'package:payvor/pages/login/login.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';

class GuestIntroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FadeIn();
}

class FadeIn extends State<GuestIntroScreen> {
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
                      child: getSetupButtonBorderNew(
                          callbackSignin, "Login", 20,
                          border: Color.fromRGBO(103, 99, 99, 0.19),
                          newColor: AppColors.colorDarkCyan,
                          textColor: Colors.white),
                    ),
                    new SizedBox(
                      height: 16.0,
                    ),
                    Container(
                        child: getSetupButtonNew(
                            callback, "Create an Account", 20)),
                    new Container(
                      margin: new EdgeInsets.only(
                          left: 20, right: 20, top: 32, bottom: 30),
                      child: new Row(
                        children: [
                          Expanded(
                            child: new Container(
                              height: 1.0,
                              color: AppColors.colorGray,
                            ),
                          ),
                          new Container(
                            margin: new EdgeInsets.only(left: 8, right: 8),
                            child: new Text(
                              "OR",
                              style: new TextStyle(
                                  color: AppColors.lightGrayNew, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: new Container(
                              height: 1.0,
                              color: AppColors.colorGray,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: getSetupButtonBorderNew(
                          callbackGuest, "Guest View", 20,
                          border: AppColors.colorGray,
                          newColor: AppColors.grayView,
                          textColor: Colors.black),
                    ),
                    new SizedBox(
                      height: 60.0,
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

  void callbackGuest() {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new GuestView();
      }),
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
