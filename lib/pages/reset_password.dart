import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/pages/enter_otp.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/themes_styles.dart';

class ResetPassword extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ResetPassword> {
  TextEditingController _PasswordController = new TextEditingController();
  TextEditingController _ConfirmPasswordController =
      new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _PasswordField = new FocusNode();
  FocusNode _ConfirmPasswordField = new FocusNode();

  bool obsecureText = true;
  bool obsecureTextConfirm = true;

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
      int type,
      bool obsecure) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      padding: new EdgeInsets.only(top: 2.0, bottom: 2.0, right: 10.0),
      decoration: new BoxDecoration(
          color: Colors.transparent,
          border: new Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: new BorderRadius.circular(8.0)),
      child: new TextField(
        controller: controller,
        style: TextThemes.blackTextFieldNormal,
        obscureText: obsecure,
        keyboardType: textInputType,
        onSubmitted: (String value) {
          if (focusNodeCurrent == _ConfirmPasswordField) {
            _ConfirmPasswordField.unfocus();
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
          suffixIcon: InkWell(
            onTap: () {
              if (type == 1) {
                obsecureText = !obsecureText;
              } else {
                obsecureTextConfirm = !obsecureTextConfirm;
              }

              setState(() {});
            },
            child: Container(
              width: 30.0,
              alignment: Alignment.centerRight,
              child: new Text(
                type == 1
                    ? obsecureText
                        ? "show"
                        : "hide"
                    : obsecureTextConfirm
                        ? "show"
                        : "hide",
                style: TextThemes.blackTextSmallNormal,
              ),
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
        key: _scaffoldKeys,
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
                      "New Password",
                      style: TextThemes.extraBold,
                    )),
                Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                  child: new Text(
                    "Enter the new password ",
                    style: TextThemes.grayNormal,
                  ),
                ),
                space(),
                new SizedBox(
                  height: 15.0,
                ),
                getTextField(
                    "Password",
                    _PasswordController,
                    _PasswordField,
                    _ConfirmPasswordField,
                    TextInputType.text,
                    AssetStrings.passPng,
                    1,
                    obsecureText),
                new SizedBox(
                  height: 18.0,
                ),
                getTextField(
                    "Repeat Password",
                    _ConfirmPasswordController,
                    _ConfirmPasswordField,
                    _ConfirmPasswordField,
                    TextInputType.text,
                    AssetStrings.passPng,
                    2,
                    obsecureTextConfirm),
                new SizedBox(
                  height: 25.0,
                ),
                Container(
                    child: getSetupButtonNew(callback, "Set New Password", 20)),
                new SizedBox(
                  height: 25.0,
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
        return new OtoVerification();
      }),
    );
  }
}
