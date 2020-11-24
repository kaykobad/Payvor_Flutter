import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_twitter/flutter_twitter.dart';
import 'package:payvor/pages/forgot_password.dart';
import 'package:payvor/pages/google_login.dart';
import 'package:payvor/pages/phone_number_add.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/themes_styles.dart';

class LoginScreenNew extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenNew> {
  TextEditingController _EmailController = new TextEditingController();
  TextEditingController _PasswordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _EmailField = new FocusNode();
  FocusNode _PasswordField = new FocusNode();
  IconData icon = Icons.visibility_off;
  bool obsecureText = true;
  bool boolCheckBox = false;

  var twitterLogin = new TwitterLogin(
    consumerKey: 'NjhbcYuBWb8RZAOnbd2nlbYD0',
    consumerSecret: 'rqXzFc5wPl7UnyvDjTSH4aaPHRB39i3BE6FjaDgJ3nFalp04dl',
  );

  Widget space() {
    return new SizedBox(
      height: 30.0,
    );
  }

  Widget getView() {
    return new Container(
      height: 1.0,
      color: Colors.grey.withOpacity(0.7),
    );
  }

  Widget getTextField(
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      {bool obsectextType}) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      padding: new EdgeInsets.only(top: 2.0, bottom: 2.0, right: 10.0),
      decoration: new BoxDecoration(
          color: Colors.transparent,
          border: new Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: new BorderRadius.circular(8.0)),
      child: new TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        obscureText: obsectextType ? obsecureText : false,
        focusNode: focusNodeCurrent,
        onSubmitted: (String value) {
          if (focusNodeCurrent == _PasswordField) {
            _PasswordField.unfocus();
          } else {
            FocusScope.of(context).autofocus(focusNodeNext);
          }
        },
        decoration: new InputDecoration(
          border: InputBorder.none,
          contentPadding: new EdgeInsets.only(top: 15.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14.0),
            child: new Image.asset(
              svgPicture,
              width: 20.0,
              height: 20.0,
            ),
          ),
          suffixIcon: obsectextType
              ? Offstage(
            offstage: !obsectextType,
            child: InkWell(
              onTap: () {
                obsecureText = !obsecureText;
                setState(() {});
              },
              child: Container(
                width: 30.0,
                alignment: Alignment.centerRight,
                child: new Text(
                  obsecureText ? "show" : "hide",
                  style: TextThemes.blackTextSmallNormal,
                ),
              ),
            ),
          )
              : Container(
            width: 1.0,
            height: 1.0,
          ),
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery
        .of(context)
        .size;
    return SafeArea(
      child: Scaffold(
        appBar: getAppBarNew(context),
        backgroundColor: Colors.white,
        key: _scaffoldKeys,
        body: new SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: screensize.width,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new SizedBox(
                  height: 36.0,
                ),
                Container(
                    margin: new EdgeInsets.only(left: 20.0),
                    child: new Text(
                      "Welcome back!",
                      style: TextThemes.extraBold,
                    )),
                Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                  child: new Text(
                    "To continue, please verify your information",
                    style: TextThemes.grayNormal,
                  ),
                ),
                space(),
                new SizedBox(
                  height: 15.0,
                ),
                getTextField(
                    "Email Address",
                    _EmailController,
                    _EmailField,
                    _PasswordField,
                    TextInputType.emailAddress,
                    AssetStrings.emailPng,
                    obsectextType: false),
                new SizedBox(
                  height: 18.0,
                ),
                getTextField("Password", _PasswordController, _PasswordField,
                    _PasswordField, TextInputType.text, AssetStrings.passPng,
                    obsectextType: true),
                new SizedBox(
                  height: 51.0,
                ),
                new Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          boolCheckBox = !boolCheckBox;
                          setState(() {});
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: boolCheckBox
                                ? Icon(
                              Icons.check_box,
                              size: 22.0,
                              color: Colors.lightBlueAccent,
                            )
                                : Icon(
                              Icons.check_box_outline_blank,
                              size: 22.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      new SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                          child: InkWell(
                              onTap: () {
                                boolCheckBox = !boolCheckBox;
                                setState(() {});
                              },
                              child: new Text("Remember me",
                                  style: TextThemes.blackTextSmallMedium))),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            new CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return new ForgotPassword();
                                }),
                          );
                        },
                        child: new Text(
                          "FORGOT PASSWORD?",
                          style: TextThemes.redTextSmallMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                new SizedBox(
                  height: 32.0,
                ),
                Container(child: getSetupButtonNew(callback, "Login", 20)),
                Container(
                  alignment: Alignment.center,
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 51),
                  child: new Text(" or login with",
                      style: TextThemes.greyTextFieldMedium),
                ),
                space(),
                Container(
                  alignment: Alignment.center,
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          getFacebookUserInfo();
                        },
                        child: new SvgPicture.asset(
                          AssetStrings.facebook,
                          height: 48,
                          width: 48,
                        ),
                      ),
                      new SizedBox(
                        width: 16.0,
                      ),
                      InkWell(
                        onTap: () {
                          getTwitterInfo();
                        },
                        child: new SvgPicture.asset(
                          AssetStrings.twitter,
                          height: 48,
                          width: 48,
                        ),
                      ),
                      new SizedBox(
                        width: 16.0,
                      ),
                      InkWell(
                        onTap: () {
                          getInstaUserInfo();
                        },
                        child: new Image.asset(
                          AssetStrings.insta,
                          height: 48,
                          width: 48,
                        ),
                      ),
                    ],
                  ),
                ),
                space(),
                new SizedBox(
                  height: 17.0,
                ),
                Container(
                  alignment: Alignment.center,
                  child: new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        text: "Don't have an account? ",
                        style: TextThemes.greyDarkTextFieldMedium,
                        children: <TextSpan>[
                          new TextSpan(
                            text: "SIGN UP",
                            style: TextThemes.redTextSmallMedium,
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {},
                          ),
                        ],
                      )),
                ),
                new SizedBox(
                  height: 17.0,
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
        return new PhoneNumberAdd();
      }),
    );
  }


  void getInstaUserInfo() async {
    var googleSignInAccount = await new SocialLogin()
        .getToken("671655060202677", "015b739c9f1a115c79f0b7c7288c9cd2");

    if (googleSignInAccount != null) {
      print("tokenss + $googleSignInAccount");
    }
  }

  void getTwitterInfo() async {
    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        var session = result.session;
        print(session.token);
        print(session.username);
        print(session.userId);
        break;
      case TwitterLoginStatus.cancelledByUser:
        //    _showCancelMessage();
        break;
      case TwitterLoginStatus.error:
        // _showErrorMessage(result.error);
        break;
    }
  }

  void getFacebookUserInfo() async {
    var googleSignInAccount = await new SocialLogin().initiateFacebookLogin();

    if (googleSignInAccount != null && googleSignInAccount is Map) {
      var nameUser = googleSignInAccount["name"];
      var id = googleSignInAccount["id"];
      var email = googleSignInAccount["email"];
      var photodata = googleSignInAccount["picture"];
      var photourl = photodata["data"];
      // MemoryManagement.setuserName(username: nameUser);

      var photo = photourl["url"];

      print("$nameUser");
      print("$email");
      print("$photodata");
      print("$photourl");
      print("$photo");
      /*  MemoryManagement.setImage(image:photo);
      _EmailController.text=email;
      loginSocial(email,id);*/

    }
    else {
      /*showAlert(
        context: context,
        titleText: "ERROR",
        message: "There are some authenticate issues.Please try again later.",
        actionCallbacks: {
          "OK": () {

          }
        },
      );*/
    }
  }
}
