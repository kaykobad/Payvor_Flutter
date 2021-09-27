import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/filter/search_item.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/rating/give_rating_request.dart';
import 'package:payvor/pages/report_problem.dart';
import 'package:payvor/pages/stripe_card_added/add_stripe_card.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class StripeCardAddedList extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<StripeCardAddedList>
    with AutomaticKeepAliveClientMixin<StripeCardAddedList> {
  var screenSize;

  TextEditingController _DescriptionController = new TextEditingController();
  FocusNode _DesField = new FocusNode();

  List<DataModelReport> listRecent = List();

  Widget widgets;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();

  AuthProvider provider;
  IconData _selectedIcon;

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

  hitRatingApi() async {
    if (_rating < 1.0) {
      showInSnackBar("Please give a rating");
      return;
    }
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

    var request = new GiveRatingRequest(
        favour_id: "",
        rating: _rating.toString(),
        description: _DescriptionController.text.toString());

    var response = await provider.giveUserRating(request, context);

    if (response is ReportResponse) {
      provider.hideLoader();

      if (response != null && response?.status?.code == 200) {}

      setState(() {});

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);
      showInSnackBar("Rating already given");
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
                      Container(
                          margin: new EdgeInsets.only(left: 15),
                          child: new Icon(
                            Icons.clear,
                            color: Colors.black87,
                          )),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: new EdgeInsets.only(right: 25.0, left: 10),
                          width: getScreenSize(context: context).width,
                          child: new Text(
                            "Make Payment",
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

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBarNew(context),
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: new Container(
                color: AppColors.backgroundGray,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: new EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: new EdgeInsets.only(top: 30),
                            height: 170,
                            decoration: new BoxDecoration(
                                border: new Border.all(
                                    color: AppColors.grayy, width: 1),
                                borderRadius: new BorderRadius.circular(5.0),
                                color: Colors.white),
                          ),
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: new Container(
                                  height: 84.0,
                                  width: 84.0,
                                  child: ClipOval(
                                    child: getCachedNetworkImageWithurl(
                                      url: "" ?? "",
                                      size: 84,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              new Container(
                                alignment: Alignment.center,
                                margin: new EdgeInsets.only(
                                    top: 16, left: 10, right: 10),
                                child: new Text(
                                  "Avinash Tiwary" ?? "",
                                  style: new TextStyle(
                                      fontFamily: AssetStrings.circulerMedium,
                                      fontSize: 20,
                                      color: Colors.black),
                                ),
                              ),
                              new Container(
                                alignment: Alignment.center,
                                width: 175,
                                margin: new EdgeInsets.only(top: 16),
                                padding: new EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                                decoration: new BoxDecoration(
                                  color: AppColors.redLight.withOpacity(0.1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    new Image.asset(
                                      AssetStrings.searches,
                                      width: 18.0,
                                      height: 18.0,
                                      color: AppColors.redLight,
                                    ),
                                    Container(
                                      margin: new EdgeInsets.only(left: 10),
                                      constraints:
                                          new BoxConstraints(maxWidth: 100),
                                      child: new Text(
                                        "€ 50" ?? "",
                                        maxLines: 2,
                                        style: new TextStyle(
                                            fontFamily:
                                                AssetStrings.circulerMedium,
                                            fontSize: 20,
                                            color: AppColors.redLight),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 24, left: 16, right: 16),
                      child: getSetupButtonNewCustom(
                          callback, "Pay with Apple", 0,
                          imagePath: AssetStrings.paypal,
                          newColor: AppColors.kBlack,
                          textColor: AppColors.kWhite),
                    ),
                    new Container(
                      height: 16,
                    ),
                    Container(
                      margin: new EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Opacity(
                              opacity: 0.2,
                              child: new Container(
                                height: 1.0,
                                color: AppColors.dividerColor,
                              ),
                            ),
                          ),
                          Container(
                            margin:
                                new EdgeInsets.only(left: 11.0, right: 11.0),
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              "OR PAY WITH",
                              style: new TextStyle(
                                  color: AppColors.lightGray.withOpacity(0.6),
                                  fontFamily: AssetStrings.circulerMedium,
                                  fontSize: 12.0),
                            ),
                          ),
                          Expanded(
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
                    Container(
                      alignment: Alignment.center,
                      child: buildContestListSearch(),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          new CupertinoPageRoute(
                              builder: (BuildContext context) {
                            return AddStripeCardDetails();
                          }),
                        );
                      },
                      child: Container(
                          margin:
                              new EdgeInsets.only(top: 15, left: 20, right: 20),
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
                                        fontFamily: AssetStrings.circulerMedium,
                                        fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                    new SizedBox(
                      height: 20.0,
                    ),
                    Container(
                        margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                        child: getSetupButtonNew(callback, "Pay with Card", 0,
                            newColor: AppColors.colorDarkCyan)),
                    new SizedBox(
                      height: 40.0,
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
          return buildItemRecentSearch(index);
        },
        itemCount: 3,
      ),
    );
  }

  Widget buildItemRecentSearch(int index) {
    return InkWell(
      onTap: () {},
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
                    padding: new EdgeInsets.all(9),
                    decoration: new BoxDecoration(
                        color: Color.fromRGBO(238, 238, 238, 1),
                        shape: BoxShape.circle),
                    child: new Image.asset(
                      AssetStrings.addPaypal,
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
                        "Master Card ending in 2468",
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
                  InkWell(
                    onTap: () {},
                    child: Container(
                      child: new Container(
                        child: new Icon(
                          Icons.check,
                          color: AppColors.colorDarkCyan,
                          size: 18,
                        ),
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
    hitRatingApi();
  }

  void callbackReport() async {}

  @override
  bool get wantKeepAlive => true;
}
