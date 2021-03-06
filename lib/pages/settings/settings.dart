import 'dart:core';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:launch_review/launch_review.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/pages/edit_profile/edit_user_profile.dart';
import 'package:payvor/pages/guest_view/guest_intro_screen.dart';
import 'package:payvor/pages/settings/add_recive_payment_card.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  final String id;

  Settings({@required this.id});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Settings>
    with AutomaticKeepAliveClientMixin<Settings> {
  var screenSize;


  AuthProvider provider;
  FirebaseProvider firebaseProvider;
  String output = "";

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

    var status = MemoryManagement.getPushStatus() ?? "0";
    //print("status $status");

    if (status == "0") {
      _switchValue = false;
    }


  }

  void _logout() async {
    await MemoryManagement.clearMemory();
    await FirebaseMessaging.instance.deleteToken();
    Navigator.pushAndRemoveUntil(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new GuestIntroScreen();
      }),
      (route) => false,
    );
  }

  void updatePushStatus() async {
    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {},
      onSuccess: () {},
    );

    if (gotInternetConnection) {
      var response = await provider.updatePushNotiStatus(
          context, widget?.id?.toString() ?? "");

      if (response != null && response is ReportResponse) {
        var status = MemoryManagement.getPushStatus() ?? "0";

        //print("status $status");

        if (status == "0") {
          MemoryManagement.setPushStatus(token: "1");
        } else {
          MemoryManagement.setPushStatus(token: "0");
        }
      } else {
        _switchValue = !_switchValue;

        setState(() {});
      }
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
                          margin: new EdgeInsets.only(right: 25.0, top: 10),
                          width: getScreenSize(context: context).width,
                          child: new Text(
                            "Settings",
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

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
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
                    height: 8,
                  ),
                  buildItemRecentSearch(
                      0, "Receiving Payment AC", AssetStrings.receiveData),
                  buildItemRecentSearch(
                      1, "Edit Account", AssetStrings.settingEdit),
                  buildItemRecentSearch(
                      2, "Push Notifications", AssetStrings.settingNoti),
                  new Container(
                    height: 8,
                  ),
                  buildItemRecentSearch(
                      3, "Terms and Condition", AssetStrings.settingTerms),
                  buildItemRecentSearch(
                      4, "Privacy and Policy", AssetStrings.settingPrivacy),
                  buildItemRecentSearch(5, "Help", AssetStrings.settingHelp),
                  new Container(
                    height: 8,
                  ),
                  buildItemRecentSearch(
                      6, "Share with Friends", AssetStrings.settingShare),
                  buildItemRecentSearch(7, "Rate us", AssetStrings.settingRate),
                  new SizedBox(
                    height: 120.0,
                  ),
                  InkWell(
                    onTap: () {
                      _logout();
                    },
                    child: new Container(
                      color: Colors.white,
                      width: screenSize.width,
                      padding: new EdgeInsets.only(
                          top: 20, bottom: 20, left: 16, right: 16),
                      child: new Text(
                        "Sign Out",
                        style: new TextStyle(
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 16,
                            color: AppColors.redLight),
                      ),
                    ),
                  )
                ],
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

  void callbackDone() async {}

  @override
  bool get wantKeepAlive => true;

  Widget buildItemRecentSearch(int type, String data, String icon) {
    return InkWell(
      onTap: () {
        if (type == 0) {
          firebaseProvider
              .changeScreen(Material(child: new AddReceivePaymentCard()));
        } else if (type == 1) {
          firebaseProvider.changeScreen(Material(child: new EditProfile()));
        } else if (type == 3) {
          _launchURL(Constants.TermOfUses);
        } else if (type == 4) {
          _launchURL(Constants.privacyPolicy);
        } //review app
        else if (type == 7) {
          LaunchReview.launch(
              androidAppId: "com.app.payvor", iOSAppId: "1558962094");
        } else if (type == 6) {
          Share.share('check out the app https://payvor.page.link/app');
        }
        //go to help section
        else if (type == 5) {
          _sendEmail();
        }
      },
      child: Container(
        color: Colors.white,
        padding:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 20, bottom: 20),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                icon,
                height: type == 0 ? 23 : 20,
                width: type == 0 ? 23 : 20,
              ),
              new SizedBox(
                width: 24,
              ),
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
              type == 2
                  ? FlutterSwitch(
                      height: 24.0,
                      width: 37.0,
                      toggleSize: 18.0,
                      borderRadius: 12.0,
                      padding: 2,
                      activeColor: AppColors.colorDarkCyan,
                      value: _switchValue,
                      onToggle: (value) {
                        setState(() {
                          _switchValue = value;
                        });

                        updatePushStatus();
                      },
                    )
                  : Container(
                      margin: new EdgeInsets.only(left: 7.0),
                      child: new Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Color.fromRGBO(183, 183, 183, 1),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  void _sendEmail() async {
    final Email email = Email(
      body: 'Your query goes here...',
      subject: 'Payvor help',
      recipients: ['info@payvor.io'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}
