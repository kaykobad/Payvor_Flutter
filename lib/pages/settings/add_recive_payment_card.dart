import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/stripe/stripe_get_users.dart';
import 'package:payvor/pages/stripe_card_added/add_stripe_card.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:provider/provider.dart';

class AddReceivePaymentCard extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<AddReceivePaymentCard>
    with AutomaticKeepAliveClientMixin<AddReceivePaymentCard> {
  var screenSize;

  List<Data> listRecent = List();
  GetStripeResponse response;

  Widget widgets;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();

  AuthProvider provider;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content: new Text(value ?? Messages.genericError)));
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      hitStripeApi();
    });
  }

  hitStripeApi() async {
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

    var responses = await provider.getAddedCards(context);

    if (responses is GetStripeResponse) {
      provider.hideLoader();

      if (responses != null &&
          responses?.status?.code == 200 &&
          responses?.customer != null) {
        listRecent?.clear();
        response = responses;
        listRecent?.addAll(responses?.customer.data);
      }

      setState(() {});

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = responses;
      showInSnackBar(apiError.error);
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
                  margin: new EdgeInsets.only(top: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            margin: new EdgeInsets.only(left: 15),
                            child: new Icon(
                              Icons.arrow_back,
                              color: Colors.black87,
                            )),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: new EdgeInsets.only(right: 25.0, left: 10),
                          width: getScreenSize(context: context).width,
                          child: new Text(
                            "Receiving Payment AC",
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
              Opacity(
                opacity: 0.7,
                child: new Container(
                  height: 0.5,
                  margin: new EdgeInsets.only(top: 12),
                  color: AppColors.dividerColor,
                ),
              ),
            ],
          ),
        ));
  }

  Future<ValueSetter> voidCallBacks(int type) async {
    hitStripeApi();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBarNew(context),
      backgroundColor: AppColors.whiteGray,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: new Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      margin: new EdgeInsets.only(top: 16, left: 20, right: 10),
                      child: new Text(
                        "Add Card Number",
                        style: new TextStyle(
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                    new Container(
                      margin: new EdgeInsets.only(top: 6, left: 20, right: 10),
                      child: new Text(
                        "Please note the that the amount you will be paid for any favor will be deposited to this card.",
                        style: new TextStyle(
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 16,
                            color: AppColors.moreText),
                      ),
                    ),
                    listRecent != null && listRecent?.length > 0
                        ? Container(
                            alignment: Alignment.center,
                            child: buildContestListSearch(),
                          )
                        : Container(),
                    listRecent == null || listRecent?.length == 0
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                new CupertinoPageRoute(
                                    builder: (BuildContext context) {
                                  return AddStripeCardDetails(
                                    voidcallback: voidCallBacks,
                                  );
                                }),
                              );
                            },
                      child: Container(
                          margin:
                              new EdgeInsets.only(top: 25, left: 20, right: 20),
                          padding: new EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: new BoxDecoration(
                              border: new Border.all(
                                  color: AppColors.grayy, width: 1),
                              borderRadius: new BorderRadius.circular(5.0),
                              color: AppColors.kWhite),
                          child: new Container(
                            alignment: Alignment.center,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Icon(
                                  Icons.add_circle,
                                  color: AppColors.redLight,
                                ),
                                Container(
                                  margin: new EdgeInsets.only(left: 8.0),
                                  child: new Text(
                                          "Add New Card",
                                          style: new TextStyle(
                                              color: AppColors.redLight,
                                              fontFamily:
                                                  AssetStrings.circulerMedium,
                                              fontSize: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          )
                        : Container(),
                    new SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            ),
            new Center(
              child: Container(
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

  buildContestListSearch() {
    return Container(
      margin: new EdgeInsets.only(top: 30, left: 20, right: 20),
      decoration: new BoxDecoration(
          border: new Border.all(color: AppColors.grayy, width: 1),
          borderRadius: new BorderRadius.circular(5.0),
          color: AppColors.kWhite),
      child: new ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildItemRecentSearch(listRecent[index]);
        },
        itemCount: listRecent?.length,
      ),
    );
  }

  Widget buildItemRecentSearch(Data data) {
    return InkWell(
      onTap: () {
        /*  print("callled");
        if (response != null &&
            response?.customer != null &&
            response?.customer?.data != null) {
          for (var dataItem in response?.customer?.data) {
            dataItem?.isCheck = false;
          }
          data?.isCheck = true;

          setState(() {});
        }*/
      },
      child: Container(
        padding: new EdgeInsets.only(left: 14.0, right: 14.0, top: 12),
        child: Column(
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    width: 30,
                    height: 30,
                    child: new Image.asset(
                      getCardImage(data?.brand),
                      width: 25,
                      height: 25,
                    ),
                  ),
                  new SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Container(
                      child: new Text(
                        data != null
                            ? "${data?.brand} ending in ${data?.last4}"
                            : "",
                        style: new TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  new SizedBox(
                    width: 5,
                  ),
                  Container(
                    child: new Container(
                      child: new Icon(
                        Icons.check,
                        color: data?.isCheck != null && data?.isCheck
                            ? AppColors.colorDarkCyan
                            : Colors.transparent,
                        size: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 8),
              child: Opacity(
                opacity: 0.2,
                child: new Container(
                  height: 1.0,
                  color: AppColors.dividerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void callbackDone() async {}

  void callback() async {
    Navigator.of(context).pop(true);
  }

  void callbackReport() async {}

  @override
  bool get wantKeepAlive => true;
}
