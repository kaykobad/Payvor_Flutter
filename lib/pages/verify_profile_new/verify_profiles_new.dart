import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/forgot_password/forgot_password_request.dart';
import 'package:payvor/model/forgot_password/forgot_password_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/pages/otp/enter_otp.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:provider/provider.dart';

class VerificationProfiles extends StatefulWidget {
  int type;

  VerificationProfiles({this.type});

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<VerificationProfiles> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GlobalKey<FormState> _fieldKey = new GlobalKey<FormState>();

  AuthProvider provider;
  var email = "";
  String emailVerify = "0";

  @override
  void initState() {
    super.initState();
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);

    emailVerify = userinfo?.user?.is_email_verified?.toString() ?? "0";

    if (userinfo?.user?.type == "Re" && userinfo?.user?.email?.isNotEmpty) {
      email = userinfo?.user?.email ?? "";
    }
  }

  Widget getAppBarNew(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(53.0),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              new SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.white,
                child: Container(
                  margin: new EdgeInsets.only(top: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: new EdgeInsets.only(left: 17.0, top: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: new Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: new SvgPicture.asset(
                              AssetStrings.back,
                              width: 16.0,
                              height: 16.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: new EdgeInsets.only(right: 35.0, top: 10),
                          width: getScreenSize(context: context).width,
                          child: new Text(
                            "Verify Profile",
                            style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
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
        new ForgotPasswordRequest(email: email);
    var response = await provider.forgotPassword(forgotrequest, context);

    if (response is ForgotPasswordResponse) {
      try {
        showInSnackBar(response.status.message);

        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new OtoVerification(
              type: 2,
              phoneNumber: email,
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

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: getAppBarNew(context),
      backgroundColor: AppColors.backgroundGray,
      body: Container(
          child: ClipRRect(
        child: Stack(
          children: [
            Form(
              key: _fieldKey,
              child: Column(
                children: [
                  Container(
                    margin: new EdgeInsets.only(top: 5),
                    child: new Column(
                      children: [
                        getData(
                            "Email Address",
                            "Verify your email address and use Perimity to its full potential! Click to the link in your verfication email to confirm your email address.",
                            0,
                            false),
                        new SizedBox(
                          height: 5,
                        ),
                        /*   getData(
                            "Bank Account",
                            "Set up a Recieving Bank Account with iban digits. The amount you will be paid for any favor will be deposited to this account.",
                            0,
                            false)*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: new Center(
                child: getHalfScreenLoader(
                  status: provider.getLoading(),
                  context: context,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Future<bool> callbackSuccess() async {
    print("success");
  }

  Widget getData(String first, String second, int type, bool isVerified) {
    return Container(
      color: Colors.white,
      padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: new Image.asset(
              AssetStrings.locationHome,
              width: 11,
              height: 14,
            ),
          ),
          Container(
            margin: new EdgeInsets.only(top: 20),
            child: new Text(
              first,
              style: new TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            margin: new EdgeInsets.only(top: 10),
            child: new Text(
              second,
              style: new TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: AppColors.grayLight.withOpacity(0.9)),
            ),
          ),
          InkWell(
            onTap: () {
              hitApi();
            },
            child: Container(
              margin: new EdgeInsets.only(top: 20),
              padding: new EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: AppColors.colorDarkCyan,
              child: new Text(
                "Send verification",
                style: new TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          new SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  void setError(dynamic error) {
    showInSnackBar(error.toString());
  }

  void showInSnackBar(String value) {
    //  ;
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
