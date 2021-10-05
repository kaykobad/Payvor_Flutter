import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/forgot_password/forgot_password_request.dart';
import 'package:payvor/model/forgot_password/forgot_password_response.dart';
import 'package:payvor/pages/otp/enter_otp.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/ValidatorFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  final int type;

  ForgotPassword({this.type});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ForgotPassword> {
  TextEditingController _EmailController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _EmailField = new FocusNode();

  AuthProvider provider;

  bool isVerified = false;

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

    ForgotPasswordRequest forgotrequest =
        new ForgotPasswordRequest(email: _EmailController.text);
    var response = await provider.forgotPassword(forgotrequest, context);

    if (response is ForgotPasswordResponse) {
      try {
        showInSnackBar(response.status.message);

        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new OtoVerification(
              phoneNumber: _EmailController.text,
              type: widget?.type ?? 1,
              countryCode: "",
            );
          }),
        );
      } catch (ex) {}

      provider.hideLoader();
    } else {
      provider.hideLoader();
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
      {bool obsectextType}) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      height: Constants.textFieldHeight,
      child: new TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        onChanged: (value) {
          if (value.trim().toString().length > 0) {
            if (isEmailFormatValid(value.trim())) {
              isVerified = true;
            } else {
              isVerified = false;
            }
          } else {
            isVerified = false;
          }

          setState(() {});
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
          suffixIcon: new Container(width: 1,),
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
    provider = Provider.of<AuthProvider>(context);

    return Material(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Scaffold(
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
                        height: Constants.backIconsSpace,
                      ),
                      Container(
                          margin: new EdgeInsets.only(left: 20.0),
                          child: new Text(
                            ResString().get('forgot_password'),
                            style: TextThemes.extraBold,
                          )),
                      Container(
                        margin:
                        new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                        child: new Text(
                           "Please enter your email to get a new password",
                          style: TextThemes.grayNormal,
                        ),
                      ),
                      new SizedBox(
                        height: 26.0,
                      ),
                      getTextField(
                          ResString().get('email_address'),
                          _EmailController,
                          _EmailField,
                          _EmailField,
                          TextInputType.emailAddress,
                          AssetStrings.emailPng),
                      new SizedBox(
                        height: 30.0,
                      ),
                      Container(
                          child: getSetupButtonColor(
                              callback, "Send reset link", 20,
                              newColor: isVerified
                                  ? AppColors.kPrimaryBlue
                                  : AppColors.grayDark)),
                      new SizedBox(
                        height: 20.0,
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
    if (isVerified) {
      /*var email = _EmailController.text;
      if (_EmailController.text.isEmpty ||
          _EmailController.text.trim().length == 0) {
        showInSnackBar(ResString().get('enter_email'));
        return;
      } else if (!isEmailFormatValid(email.trim())) {
        showInSnackBar(ResString().get('enter_valid_email'));
        return;
      }*/

      hitApi();
    }
  }
}
