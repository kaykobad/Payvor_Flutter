import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/add_card_details/add_card_payment.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:provider/provider.dart';

class AddPaymentMethod extends StatefulWidget {
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

class _HomeState extends State<AddPaymentMethod>
    with AutomaticKeepAliveClientMixin<AddPaymentMethod> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();

  AuthProvider provider;
  FirebaseProvider firebaseProvider;

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
                            "Add Payment Method",
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
                    height: 7,
                  ),
                  buildItemRecentSearch(
                      1, "Add Paypal", AssetStrings.addPaypal),
                  new Container(
                    height: 6,
                  ),
                  /*  buildItemRecentSearch(
                      2, "Add Credit/Debit Card", AssetStrings.addCard),*/
                ],
              ),
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
        firebaseProvider.changeScreen(Material(
            child: new AddCardDetails(
          type: 1,
        )));
      },
      child: Container(
        color: Colors.white,
        padding:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 15, bottom: 15),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                width: 43,
                height: 43,
                padding: new EdgeInsets.all(9),
                decoration: new BoxDecoration(
                    color: Color.fromRGBO(238, 238, 238, 1),
                    shape: BoxShape.circle),
                child: new Image.asset(
                  icon,
                  width: 18,
                  height: 18,
                ),
              ),
              new SizedBox(
                width: 12,
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
              Container(
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
}
