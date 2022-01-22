import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/common_response/common_success_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/update_profile/update_profile_request.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/privacypolicy/webview_page.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class CreateCredential extends StatefulWidget {
  final bool type;

  CreateCredential({this.type});

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

  String name = "";
  String email = "";

  AuthProvider provider;

  bool isVerified = false;

  var _termAndConditionCheck = false;

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

  hitApi() async {
    provider.setLoading();
    UpdateProfileRequest updateProfileRequest = new UpdateProfileRequest();
    updateProfileRequest.password = _PasswordController.text;

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

    var response =
        await provider.createCredential(updateProfileRequest, context);

    provider.hideLoader();
    if (response is CommonSuccessResponse) {
      // var infoData = jsonDecode(MemoryManagement.getUserInfo());
      // var userinfo = LoginSignupResponse.fromJson(infoData);

     // MemoryManagement.setScreenType(type: "3");
     //  MemoryManagement.setUserInfo(userInfo: json.encode(response));
     //  MemoryManagement.setUserLoggedIn(isUserLoggedin: true);
     //  Navigator.pushAndRemoveUntil(
     //    context,
     //    new CupertinoPageRoute(builder: (BuildContext context) {
     //      return DashBoardScreen();
     //    }),
     //    (route) => false,
     //  );
      showInSnackBar("Password updated successfully!");
      MemoryManagement.setAccessToken(accessToken: "");
      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      });



    } else {
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
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
      height: Constants.textFieldHeight,
      child: new TextField(
        controller: controller,
        style: TextThemes.blackTextFieldNormal,
        obscureText: obsecure,
        keyboardType: textInputType,
        onChanged: (value) {
          if (_PasswordController?.text?.trim().length > 6 &&
              _ConfirmPasswordController?.text?.trim().length > 6) {
            isVerified = true;
          } else {
            isVerified = false;
          }

          setState(() {});
        },
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
              borderRadius: new BorderRadius.circular(8)),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: AppColors.colorCyanPrimary,
              ),
              borderRadius: new BorderRadius.circular(8)),
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
                  name,
                  style: TextThemes.smallBold,
                )),
                Container(
                  margin: new EdgeInsets.only(top: 1),
                  child: new Text(
                    email,
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

  Widget getAppBarNewBlank(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Material(
          color: Colors.white,
          child: Container(
            alignment: Alignment.topLeft,
            margin: new EdgeInsets.only(left: 17.0, top: 47),
            child: InkWell(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);

    return Material(
      child: Stack(
        children: [
          Scaffold(
            key: _scaffoldKeys,
            appBar: widget.type != null && widget.type
                ? getAppBarNewBlank(context)
                : getAppBarNew(context),
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
                          "New Password",
                          style: TextThemes.extraBold,
                        )),
                    Container(
                      margin:
                          new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                      child: new Text(
                        "Enter the new Password and confirm with Repeat Password field",
                        style: TextThemes.grayNormal,
                      ),
                    ),
                    //  getUserData(),
                    new SizedBox(
                      height: 32.0,
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

                    Container(
                        margin: new EdgeInsets.only(top: 30),
                        child: getSetupButtonNew(
                            callback, "Set up New Password", 20,
                            newColor: isVerified
                                ? AppColors.kPrimaryBlue
                                : AppColors.grayDark)),
                    new SizedBox(
                      height: 35.0,
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
    );
  }

  void onChecked(bool value) {
    setState(() {
      _termAndConditionCheck = value;
      // print('value: $value');
    });
  }

  get termAndConditionWidget => Padding(
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: new Row(
          children: <Widget>[
            new Checkbox(
              value: _termAndConditionCheck,
              onChanged: onChecked,
            ),
            termAndConditionText
          ],
        ),
      );

  get termAndConditionText => Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: new RichText(
            text: new TextSpan(
          text: ResString().get('by_continue'),
          style: TextThemes.grayNormalSmall,
          children: <TextSpan>[
            new TextSpan(
              text: ResString().get('term_of_uses'),
              style: TextThemes.blueMediumSmall,
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  print("called");
                  _redirect(
                      heading: ResString().get('term_of_uses'),
                      url: Constants.TermOfUses);
                },
            ),
            new TextSpan(
              text: ResString().get('confirm_that'),
              style: TextThemes.grayNormalSmall,
            ),
            new TextSpan(
              text: ResString().get('privacy_policy'),
              style: TextThemes.blueMediumSmall,
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  _redirect(
                      heading: ResString().get('privacy_policy'),
                      url: Constants.privacyPolicy);
                },
            ),
          ],
        )),
      );

  _redirect({@required String heading, @required String url}) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new WebViewPages(
                  heading: heading,
                  url: url,
                )));
  }

  void callback() {
    if (isVerified) {
      var password = _PasswordController.text;
      var confirmPassword = _ConfirmPasswordController.text;
      if (password.isEmpty || password.trim().length == 0) {
        showInSnackBar(ResString().get('enter_password'));
        return;
      } else if (confirmPassword.isEmpty || confirmPassword.length == 0) {
        showInSnackBar(ResString().get('confirm_password'));
        return;
      } else if (password.compareTo(confirmPassword) != 0) {
        showInSnackBar(ResString().get('password_not_match'));
        return;
      } else if (password.length < 6 || password.length > 20) {
        showInSnackBar(ResString().get('password_should_6_20_char'));
        return;
      }
      hitApi();
    }
  }
}
