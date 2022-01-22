import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginrequest.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/pages/chat/payvor_firebase_user.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/join_community/join_community.dart';
import 'package:payvor/pages/login/login.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:provider/provider.dart';

class GuestIntroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FadeIn();
}

class FadeIn extends State<GuestIntroScreen> {
  FirebaseProvider firebaseProvider;
  AuthProvider provider;
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKeys,
        body: Container(
          width: size.width,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              new Column(children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  margin: new EdgeInsets.only(top: 100),
                  child: new Image.asset(
                    AssetStrings.payvorIntro,
                    width: 100,
                    height: 80,
                  ),
                ),
                new Container(
                  child: new Text(
                    "Perimity",
                    style: new TextStyle(
                        color: AppColors.kPrimaryBlue,
                        fontSize: 36,
                        fontFamily: AssetStrings.circulerBoldStyle),
                  ),
                )
              ]),
              bottomView,
              new Center(
                child: getFullScreenProviderLoader(
                  status: provider.getLoading(),
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  hitApi() async {
    provider.setLoading();
    var response;

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        provider.hideLoader();
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }

    LoginRequest loginRequest =
        new LoginRequest(password: "123456", email: "guest@gmail.com");
    response = await provider.login(loginRequest, context);
    MemoryManagement.socialMediaStatus("0");

    if (response is LoginSignupResponse) {
      provider.setLoading();

      LoginSignupResponse loginSignupResponse = response;
      MemoryManagement.setAccessToken(accessToken: loginSignupResponse.data);
      MemoryManagement.setUserInfo(userInfo: json.encode(response));
      MemoryManagement.setGuestUser(type: true);

      var email = "guest@gmail.com";

      try {
        print("email $email");
        //firebase login
        var firebaseId = await firebaseProvider.signIn(
            email, Constants.FIREBASE_USER_PASSWORD);

        await firebaseProvider
            .updateFirebaseUser(getUser(response, firebaseId, email));
      } catch (ex) {
        print("error ${ex.toString()}");

        var firebaseId = await firebaseProvider.signUp(
            email, Constants.FIREBASE_USER_PASSWORD);
        //save user info to fire store user collection
        var user = getUser(response, firebaseId, email);
        user.created = DateTime.now()
            .toIso8601String(); //if user is not registered with firebase
        await firebaseProvider.createFirebaseUser(user);
      }
      provider.hideLoader();
      MemoryManagement.setUserLoggedIn(isUserLoggedin: true);
      Navigator.push(
        context,
        new CupertinoPageRoute(builder: (BuildContext context) {
          return new DashBoardScreen();
        }),
      );


    } else {
      firebaseProvider.hideLoader();
      APIError apiError = response;
      showInSnackBar(apiError.error ?? Messages.unAuthorizedError);
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  get bottomView => Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: new Column(
          children: <Widget>[
            Container(
              child: getSetupButtonBorderNew(callbackSignin, "Login", 20,
                  border: Color.fromRGBO(103, 99, 99, 0.19),
                  newColor: AppColors.colorDarkCyan,
                  textColor: Colors.white),
            ),
            new SizedBox(
              height: 16.0,
            ),
            Container(
                child: getSetupButtonNew(callback, "Create an Account", 20)),
            new Container(
              margin:
                  new EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 30),
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
              child: getSetupButtonBorderNew(callbackGuest, "Guest View", 20,
                  border: AppColors.colorGray,
                  newColor: AppColors.grayView,
                  textColor: Colors.black),
            ),
            new SizedBox(
              height: 60.0,
            ),
          ],
        ),
      );

  PayvorFirebaseUser getUser(
      LoginSignupResponse signupResponse, String firebaseId, String email) {
    return new PayvorFirebaseUser(
        fullName: signupResponse.user.name,
        email: email,
        location: signupResponse.user.location,
        updated: DateTime.now().toIso8601String(),
        created: DateTime.now().toIso8601String(),
        filmShapeId: signupResponse.user.id,
        firebaseId: firebaseId,
        isOnline: true,
        thumbnailUrl: signupResponse.user.profilePic);
  }

  void callbackGuest() {
    hitApi();
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
