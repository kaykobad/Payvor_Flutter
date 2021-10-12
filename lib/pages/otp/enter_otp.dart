import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/otp/otp_forgot_request.dart';
import 'package:payvor/model/otp/otp_request.dart';
import 'package:payvor/model/otp/resendotpresponse.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:pin_view/pin_view.dart';
import 'package:provider/provider.dart';
import 'package:quiver/async.dart';

class OtoVerification extends StatefulWidget {
  final String phoneNumber;
  final int type;
  final String countryCode;

  OtoVerification({this.phoneNumber, this.type, this.countryCode});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<OtoVerification> {
  TextEditingController _PasswordController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();

  AuthProvider provider;

  CountdownTimer countDownTimer;
  int _start = 31;
  int _current = 0;
  String pinText;
  double offstage = 1.0;
  String noPhone = "";

  Widget space() {
    return new SizedBox(
      height: 30.0,
    );
  }

  @override
  void initState() {
    super.initState();

    /*  if (widget.type == 0) {
      noPhone = widget.phoneNumber != null
          ? "+" + widget.countryCode + widget.phoneNumber
          : "";
      startTimer();
      Future.delayed(Duration(milliseconds: 300), () {
        hitResendApi();
      });
    } else {

    }*/

    noPhone = widget.phoneNumber != null ? widget.phoneNumber : "";
  }

  Widget getView() {
    return new Container(
      height: 1.0,
      color: Colors.grey.withOpacity(0.7),
    );
  }

  void startTimer() {
    offstage = 0.5;
    if (countDownTimer != null) {
      countDownTimer.cancel();
    }

    countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
        // colorResend = Colors.black.withOpacity(0.4);
        //print(_current);

        if (_current == 1) {
          timer();
        }
      });
    });

    sub.onDone(() {
      //print(countDownTimer.toString());
      sub.cancel();
      // colorResend = AppColors.kBlack;
    });
  }

  void timer() {
    Timer(Duration(seconds: 1), () {
      offstage = 1.0;
    });
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

    OtpRequest loginRequest =
        new OtpRequest(otp: pinText, id: noPhone ?? "", type: "email");
    var response = await provider.verifyOtp(loginRequest, context);
    provider.hideLoader();
    if (response is LoginSignupResponse) {
      MemoryManagement.setAccessToken(accessToken: response.data);
      MemoryManagement.setUserInfo(userInfo: json.encode(response));
      MemoryManagement.setUserLoggedIn(isUserLoggedin: true);
      Navigator.pushAndRemoveUntil(
        context,
        new CupertinoPageRoute(builder: (BuildContext context) {
          return DashBoardScreen();
        }),
        (route) => false,
      );
    } else {
      APIError apiError = response;
      //print(apiError.error);

      showInSnackBar("Invalid Otp");
    }
  }

  hitForgotApi() async {
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

    OtpForgotRequest loginRequest = new OtpForgotRequest(
        otp: pinText, email: widget.phoneNumber ?? "", type: "email");
    var response = await provider.verifyEmailVerify(loginRequest, context);
    provider.hideLoader();
    if (response is LoginSignupResponse) {
      //print("typpppee ${widget?.type?.toString()}");

      if (widget?.type?.toString() == "2") {
        var infoData = jsonDecode(MemoryManagement.getUserInfo());
        var userinfo = LoginSignupResponse.fromJson(infoData);
        userinfo?.user?.is_email_verified = 1;

        MemoryManagement.setUserInfo(userInfo: json.encode(response));

        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        MemoryManagement.setUserInfo(userInfo: json.encode(response));
        MemoryManagement.setAccessToken(accessToken: response?.data);
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return Material(child: new DashBoardScreen());
          }),
        );
      }
    } else {
      APIError apiError = response;
      //print(apiError.error);

      showInSnackBar(apiError.messag);
    }
  }

  hitResendApi() async {
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
    var phoneNumber = "${widget.countryCode}${widget.phoneNumber}";
    var response =
        await provider.getotp(widget.phoneNumber, widget.countryCode, context);
    provider.hideLoader();
    if (response is ResendOtpResponse) {
      // showInSnackBar("Your otp code is ${response.data.otp}");
    } else {
      APIError apiError = response;
      //print(apiError.error);
      showInSnackBar(Messages.genericError);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    countDownTimer.cancel();
    super.dispose();
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
                            widget.type == 0
                                ? ResString().get('verify_number')
                                : ResString().get('verify_email'),
                            style: TextThemes.extraBold,
                          )),
                      Container(
                        margin: new EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 6),
                        child: new RichText(
                            text: new TextSpan(
                          text: widget.type == 0
                              ? ResString().get('enter_code_that')
                              : ResString().get('enter_code_that_email'),
                          style: TextThemes.grayNormal,
                          children: <TextSpan>[
                            new TextSpan(
                              text: noPhone,
                              style: TextThemes.blackTextFieldNormal,
                            ),
                          ],
                        )),
                      ),
                      space(),
                      new SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                        child: PinView(
                            count: 4,
                            // describes the field number
                            autoFocusFirstField: false,
                            obscureText: true,
                            // defaults to true
                            inputDecoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.grey.withOpacity(0.5)),
                                  borderRadius: new BorderRadius.circular(8.0)),
                              focusedBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.grey.withOpacity(0.5)),
                                  borderRadius: new BorderRadius.circular(8.0)),
                              enabledBorder: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.grey.withOpacity(0.5)),
                                  borderRadius: new BorderRadius.circular(8.0)),
                            ),
                            margin: EdgeInsets.all(10),
                            // margin between the fields// describes whether the text fields should be obscure or not, defaults to false
                            style: TextThemes.blackTextSmallMedium,
                            submit: (String pin) {
                              // when all the fields are filled
                              // submit function runs with the pin
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              pinText = pin;
                              //print(pin);

                              if (widget.type == 0) {
                                hitApi();
                              } else {
                                hitForgotApi();
                              }
                            }),
                      ),
                      new SizedBox(
                        height: 85.0,
                      ),
                      widget.type == 0
                          ? offstage == 1.0
                              ? Container()
                              : Container(
                                  alignment: Alignment.center,
                                  margin: new EdgeInsets.only(left: 20.0),
                                  child: new Text(
                                    ResString().get('verify_code') +
                                        "$_current",
                                    style: TextThemes.greyDarkTextFieldItalic,
                                  ))
                          : Container(),
                      widget.type == 0
                          ? Opacity(
                              opacity: offstage,
                              child: InkWell(
                                onTap: () {
                                  if (offstage == 1.0) {
                                    startTimer();
                                    hitResendApi();
                                  }
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    margin: new EdgeInsets.only(
                                        left: 20.0, top: 18),
                                    child: new Text(
                                      ResString().get('resend_code'),
                                      style: TextThemes.redTextSmallMedium,
                                    )),
                              ),
                            )
                          : Container(),
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
    /*Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new LoginScreen();
      }),
    );*/
  }
}
