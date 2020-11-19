import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/themes_styles.dart';

class CreateCredential extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<CreateCredential> {
  TextEditingController _PasswordController = new TextEditingController();
  TextEditingController _ConfirmPasswordController =
      new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _PasswordField = new FocusNode();
  FocusNode _ConfirmPasswordField = new FocusNode();

  bool obsecureText = true;
  bool obsecureTextConfirm = true;

  List<TextInputFormatter> listPassword = new List<TextInputFormatter>();

  @override
  void initState() {
    listPassword.addAll([new LengthLimitingTextInputFormatter(20)]);

    super.initState();
  }

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
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        obscureText: obsecure,
        focusNode: focusNodeCurrent,
        onSubmitted: (String value) {
          if (focusNodeCurrent == _ConfirmPasswordField) {
            _ConfirmPasswordField.unfocus();
          } else {
            FocusScope.of(context).autofocus(focusNodeNext);
          }
        },
        inputFormatters: listPassword,
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

  Widget getUserData() {
    return new Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new Container(
            child: new ClipOval(
              child: new Image.asset(
                AssetStrings.imagePlaceholder,
                width: 48,
                height: 48,
              ),
            ),
          ),
          new SizedBox(
            width: 16.0,
          ),
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    child: new Text(
                  "Dibbendo Pranto",
                  style: TextThemes.smallBold,
                )),
                Container(
                  margin: new EdgeInsets.only(top: 1),
                  child: new Text(
                    "dibu.official@gmail.com",
                    style: TextThemes.greyTextFieldNormal,
                  ),
                ),
              ],
            ),
          )
        ],
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
                  height: 35.0,
                ),
                Container(
                    margin: new EdgeInsets.only(left: 20.0),
                    child: new Text(
                      "Enter Credential",
                      style: TextThemes.extraBold,
                    )),
                Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                  child: new Text(
                    "Set your 6-20 characters password",
                    style: TextThemes.grayNormal,
                  ),
                ),
                getUserData(),
                new SizedBox(
                  height: 38.0,
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
                  height: 46.0,
                ),
                Container(
                  alignment: Alignment.center,
                  child: new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        text: "By continuing, you agree to Payvor’s ",
                        style: TextThemes.grayNormalSmall,
                        children: <TextSpan>[
                          new TextSpan(
                            text: "Terms of Use",
                            style: TextThemes.blueMediumSmall,
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {},
                          ),
                          new TextSpan(
                            text: " and confirm that you have read the ",
                            style: TextThemes.grayNormalSmall,
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {},
                          ),
                          new TextSpan(
                            text: "Privacy Policy",
                            style: TextThemes.blueMediumSmall,
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {},
                          ),
                        ],
                      )),
                ),
                Container(
                    margin: new EdgeInsets.only(top: 170),
                    child:
                        getSetupButtonNew(callback, "Create an Account", 20)),
                new SizedBox(
                  height: 35.0,
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
