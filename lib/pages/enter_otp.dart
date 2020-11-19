import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:pin_view/pin_view.dart';
import 'package:quiver/async.dart';

class OtoVerification extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<OtoVerification> {
  TextEditingController _PasswordController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();

  CountdownTimer countDownTimer;
  int _start = 31;
  int _current = 0;
  String pinText;
  double offstage = 1.0;

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
        print(_current);

        if (_current == 1) {
          timer();
        }
      });
    });

    sub.onDone(() {
      print(countDownTimer.toString());
      sub.cancel();
      // colorResend = AppColors.kBlack;
    });
  }

  void timer() {
    Timer(Duration(seconds: 1), () {
      offstage = 1.0;
    });
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
                      "Verify Phone Number",
                      style: TextThemes.extraBold,
                    )),
                Container(
                  margin: new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                  child: new RichText(
                      text: new TextSpan(
                    text: "Please enter the code that is sent to your phone ",
                    style: TextThemes.grayNormal,
                    children: <TextSpan>[
                      new TextSpan(
                        text: " +198373235",
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
                        FocusScope.of(context).requestFocus(new FocusNode());
                        pinText = pin;
                        print(pin);
                      }),
                ),
                new SizedBox(
                  height: 85.0,
                ),
                offstage == 1.0
                    ? Container()
                    : Container(
                        alignment: Alignment.center,
                        margin: new EdgeInsets.only(left: 20.0),
                        child: new Text(
                          "The verification code will expire in " + "$_current",
                          style: TextThemes.greyDarkTextFieldItalic,
                        )),
                Opacity(
                  opacity: offstage,
                  child: InkWell(
                    onTap: () {
                      if (offstage == 1.0) {
                        startTimer();
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
                        margin: new EdgeInsets.only(left: 20.0, top: 18),
                        child: new Text(
                          "RESEND CODE",
                          style: TextThemes.redTextSmallMedium,
                        )),
                  ),
                ),
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
    /*Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new LoginScreen();
      }),
    );*/
  }
}
