import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/pages/reset_password.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/themes_styles.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ForgotPassword> {

  TextEditingController _EmailController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _EmailField = new FocusNode();


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


  Widget getTextField(String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      {bool obsectextType}) {
    return
      Container(

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
    var screensize = MediaQuery
        .of(context)
        .size;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKeys,
        appBar: getAppBarNew(context),
        backgroundColor: Colors.white,
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
                      "Forgot Password", style: TextThemes.extraBold,)),


                Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                  child: new Text(
                    "Enter your email and receive a link to reset your password",
                    style: TextThemes.grayNormal,),
                ),

                new SizedBox(
                  height: 26.0,
                ),

                getTextField(
                    "Email Address",
                    _EmailController,
                    _EmailField,
                    _EmailField,
                    TextInputType.emailAddress,
                    AssetStrings.emailPng
                ),

                new SizedBox(
                  height: 101.0,
                ),

                Container(
                    child: getSetupButtonNew(
                        callback, "Send reset link", 20)),

                new SizedBox(
                  height: 20.0,
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
        return new ResetPassword();
      }),
    );
  }
}
