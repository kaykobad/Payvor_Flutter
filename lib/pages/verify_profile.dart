import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/forgot_password/forgot_password_request.dart';
import 'package:payvor/model/forgot_password/forgot_password_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/pages/add_payment_method/add_payment_method.dart';
import 'package:payvor/pages/edit_profile/edit_user_profile.dart';
import 'package:payvor/pages/otp/enter_otp.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VerifyProfile extends StatefulWidget {
/*  final String id;
  final int type;
  final String image;
  final String name;
  final String userId;
  final String paymentType;
  final String paymentAmount;
  final ValueSetter<int> voidcallback;

  RatingBarNew(
      {@required this.id,
        this.type,
        this.image,
        this.name,
        this.userId,
        this.paymentType,
        this.paymentAmount,
        this.voidcallback});*/

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<VerifyProfile>
    with AutomaticKeepAliveClientMixin<VerifyProfile> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();

  AuthProvider provider;
  FirebaseProvider firebaseProvider;

  String emailVerify = "0";

  bool mProfileUpdated = false;
  bool mPaymentUpdated = false;

  bool fromRegister = false;

  var email = "";

  bool _switchValue = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  double _rating;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content: new Text(value ?? Messages.genericError)));
  }

  @override
  void initState() {
    super.initState();

    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);

    emailVerify = userinfo?.user?.is_email_verified?.toString() ?? "0";

    if (userinfo?.user?.type == "Re" && userinfo?.user?.email?.isNotEmpty) {
      email = userinfo?.user?.email ?? "";
      fromRegister = true;
    }

    mPaymentUpdated = MemoryManagement.getPaymentStatus() ?? false;
  }

  Widget getAppBarNew(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0),
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
                    crossAxisAlignment: CrossAxisAlignment.baseline,
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
                          margin: new EdgeInsets.only(right: 25.0, top: 10),
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

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);
    return VisibilityDetector(
      key: Key('my-widget-key'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (visiblePercentage == 100) {
          var infoData = jsonDecode(MemoryManagement.getUserInfo());
          var userinfo = LoginSignupResponse.fromJson(infoData);

          var profile = userinfo?.user?.profilePic ?? "";

          if (profile.isNotEmpty && profile.length > 0) {
            mProfileUpdated = true;
          } else {
            mProfileUpdated = false;
            ;
          }

          mPaymentUpdated = MemoryManagement.getPaymentStatus() ?? false;

          setState(() {});
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: getAppBarNew(context),
        backgroundColor: AppColors.whiteGray,
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: new Container(
                color: AppColors.whiteGray,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      height: 5,
                    ),
                    buildItemRecentSearch(
                        1, "Phone Number", AssetStrings.settingEdit, true),
                    fromRegister
                        ? new Container(
                            height: 4,
                          )
                        : Container(),
                    fromRegister
                        ? buildItemRecentSearch(
                            2,
                            "Email Address",
                            AssetStrings.settingNoti,
                            emailVerify == "1" ? true : false)
                        : Container(),
                    new Container(
                      height: 4,
                    ),
                    buildItemRecentSearch(
                        3,
                        "Upload Profile Photo",
                        AssetStrings.settingTerms,
                        mProfileUpdated ? true : false),
                    new Container(
                      height: 4,
                    ),
                    buildItemRecentSearch(
                        4,
                        "Add Payment Method",
                        AssetStrings.settingPrivacy,
                        mPaymentUpdated ? true : false),
                  ],
                ),
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

  void callbackDone() async {}

  @override
  bool get wantKeepAlive => true;

  Widget buildItemRecentSearch(
      int type, String data, String icon, bool visibile) {
    return InkWell(
      onTap: () {
        if (type == 4 && mPaymentUpdated == false) {
          firebaseProvider
              .changeScreen(Material(child: new AddPaymentMethod()));
        } else if (type == 3) {
          firebaseProvider.changeScreen(Material(child: new EditProfile()));
        } else if (type == 2 && emailVerify == "0") {
          hitApi();
          //  verify user email;
        }
      },
      child: Container(
        color: Colors.white,
        padding:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 22, bottom: 22),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: new Text(
                    data,
                    style: new TextStyle(
                      color: Colors.black,
                      fontFamily: AssetStrings.circulerMedium,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              new SizedBox(
                width: 8,
              ),
              Container(
                padding:
                    new EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                decoration: new BoxDecoration(
                    color: !visibile
                        ? AppColors.colorDarkCyan
                        : Color.fromRGBO(221, 242, 255, 1),
                    borderRadius: new BorderRadius.circular(2)),
                child: new Row(
                  children: [
                    visibile
                        ? new Image.asset(
                            AssetStrings.iconTicks,
                            width: 20,
                            height: 20,
                          )
                        : Container(),
                    new Container(
                      margin: new EdgeInsets.only(
                          left: visibile ? 6 : 19.5,
                          right: visibile ? 0 : 19.5,
                          top: visibile ? 0 : 1,
                          bottom: visibile ? 0 : 1),
                      child: new Text(
                        visibile ? "Verified" : "Verify",
                        style: new TextStyle(
                            fontSize: 16,
                            color: visibile
                                ? AppColors.colorDarkCyan
                                : Colors.white,
                            fontFamily: AssetStrings.circulerMedium),
                      ),
                    )
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
