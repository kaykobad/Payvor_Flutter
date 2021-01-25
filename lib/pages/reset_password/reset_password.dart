import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/common_response/common_success_response.dart';
import 'package:payvor/model/reset_password/reset_pass_request.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

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
  AuthProvider provider;

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

/*
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
  }*/


  Widget getTextField(String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      int type,
      bool obsecure) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      height: Constants.textFieldHeight,
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

          enabledBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
              borderRadius: new BorderRadius.circular(8)

          ),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: AppColors.colorCyanPrimary,

              ),
              borderRadius: new BorderRadius.circular(8)


          ),
          contentPadding: new EdgeInsets.only(top: 10.0),
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
              margin: new EdgeInsets.only(right: 10.0, bottom: 4),
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

  hitApi() async {
    provider.setLoading();

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

    ResetPasswordRequest loginRequest = new ResetPasswordRequest(
        new_pas: _PasswordController.text,
        cnf_pas: _ConfirmPasswordController.text);
    var response = await provider.resetPassword(loginRequest, context);

    if (response is CommonSuccessResponse) {
      try {
        showInSnackBar(response.success);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      } catch (ex) {}

      provider.hideLoader();
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    return Material(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Scaffold(
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
                        height: Constants.backIconsSpace,
                      ),
                      Container(
                          margin: new EdgeInsets.only(left: 20.0),
                          child: new Text(
                            ResString().get('new_password'),
                            style: TextThemes.extraBold,
                          )),
                      Container(
                        margin:
                        new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                        child: new Text(
                          ResString().get('enter_new_pass'),
                          style: TextThemes.grayNormal,
                        ),
                      ),
                      space(),
                      new SizedBox(
                        height: 15.0,
                      ),
                      getTextField(
                          ResString().get('password'),
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
                          ResString().get('repeat_password'),
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
                          child: getSetupButtonNew(
                              callback, ResString().get('set_new_pass'), 20)),
                      new SizedBox(
                        height: 25.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            new Center(
              child: getFullScreenProviderLoader(
                status: provider.getLoading(),
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void callback() {
    var password = _PasswordController.text;
    var confirmPassword = _ConfirmPasswordController.text;
    if (password.isEmpty || password.trim().length == 0) {
      showInSnackBar(ResString().get('enter_password'));
      return;
    } else if (confirmPassword.isEmpty || confirmPassword.length == 0) {
      showInSnackBar(ResString().get('confirm_password'));
      return;
    } else if (password != confirmPassword) {
      showInSnackBar(ResString().get('pass_and_confirm_not_match'));
      return;
    }

    hitApi();
  }
}
