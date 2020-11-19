import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/themes_styles.dart';

class JoinCommunityNew extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<JoinCommunityNew> {
  TextEditingController _EmailController = new TextEditingController();
  TextEditingController _FullNameController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _EmailField = new FocusNode();
  FocusNode __FullNameField = new FocusNode();

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
        focusNode: focusNodeCurrent,
        onSubmitted: (String value) {
          if (focusNodeCurrent == __FullNameField) {
            __FullNameField.unfocus();
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
    var screensize = MediaQuery.of(context).size;
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
                      "Join the community here!",
                      style: TextThemes.extraBold,
                    )),
                Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                  child: new Text(
                    "Enter your details to create an account",
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
                    __FullNameField,
                    TextInputType.emailAddress,
                    AssetStrings.emailPng),
                new SizedBox(
                  height: 18.0,
                ),
                getTextField("Full Name", _FullNameController, __FullNameField,
                    __FullNameField, TextInputType.text, AssetStrings.fullname),
                new SizedBox(
                  height: 54.0,
                ),
                Container(child: getSetupButtonNew(callback, "Sign Up", 20)),
                Container(
                  alignment: Alignment.center,
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 98),
                  child: new Text("or signup with",
                      style: TextThemes.greyTextFieldMedium),
                ),
                space(),
                Container(
                  alignment: Alignment.center,
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new SvgPicture.asset(
                        AssetStrings.facebook,
                        height: 48,
                        width: 48,
                      ),
                      new SizedBox(
                        width: 16.0,
                      ),
                      new SvgPicture.asset(
                        AssetStrings.twitter,
                        height: 48,
                        width: 48,
                      ),
                      new SizedBox(
                        width: 16.0,
                      ),
                      new Image.asset(
                        AssetStrings.insta,
                        height: 48,
                        width: 48,
                      ),
                    ],
                  ),
                ),
                space(),
                new SizedBox(
                  height: 27.0,
                ),
                Container(
                  alignment: Alignment.center,
                  child: new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        text: "Already have an account? ",
                        style: TextThemes.greyDarkTextFieldMedium,
                        children: <TextSpan>[
                          new TextSpan(
                            text: "LOGIN",
                            style: TextThemes.redTextSmallMedium,
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {},
                          ),
                        ],
                      )),
                ),
                new SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void callback() {
    /*Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new LoginScreen();
      }),
    );*/
  }
}
