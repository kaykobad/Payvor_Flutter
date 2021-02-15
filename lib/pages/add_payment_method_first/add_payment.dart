import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/add_paypal/get_paypal_data.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/common_response/common_success_response.dart';
import 'package:payvor/pages/add_payment_method/add_payment_method.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:provider/provider.dart';

class AddPaymentMethodFirst extends StatefulWidget {
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

class _HomeState extends State<AddPaymentMethodFirst>
    with AutomaticKeepAliveClientMixin<AddPaymentMethodFirst> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();

  AuthProvider provider;
  FirebaseProvider firebaseProvider;

  List<Data> dataList = List<Data>();

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
    Future.delayed(const Duration(milliseconds: 300), () {
      hitAddApi();
    });
  }

  hitAddApi() async {
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

    provider.setLoading();

    var response = await provider.getPaypalMethod(context);

    if (response is GetPaypalData) {
      provider.hideLoader();

      if (response?.data != null) {
        dataList.add(response?.data);
      }

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  hitDeleteApi(int index, String id) async {
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

    provider.setLoading();

    var response = await provider.deletePaypalMethod(context, id);

    if (response is CommonSuccessResponse) {
      provider.hideLoader();
      showInSnackBar("Paypal method deleted successfully");

      dataList?.removeAt(index);

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

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
                            "Payment Method",
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
                  dataList?.length == 0 ? buildItemItemAddCard() : Container(),
                  new Container(
                    height: 24,
                  ),
                  dataList?.length > 0
                      ? Container(
                          margin: new EdgeInsets.only(left: 16),
                          child: new Text(
                            "Added Methods",
                            style: new TextStyle(
                              color: Colors.black,
                              fontFamily: AssetStrings.circulerMedium,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )
                      : Container(),
                  new Container(
                    height: 24,
                  ),
                  buildContestListSearch(),
                  new Container(
                    height: 6,
                  ),
                  /*  buildItemRecentSearch(
                      2, "**** **** **** 8787", AssetStrings.addCard),*/
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
    );
  }

  Future<bool> showDeletePaypal(int index, String id) async {
    return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Paypal Method?'),
              content: Text('Do you want to delete this id?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('YES'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    hitDeleteApi(index, id?.toString());
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  buildContestListSearch() {
    return Container(
      color: Colors.white,
      child: new ListView.builder(
        padding: new EdgeInsets.all(0.0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildItemRecentSearch(index, dataList[index]);
        },
        itemCount: dataList.length,
      ),
    );
  }

  void callbackDone() async {}

  @override
  bool get wantKeepAlive => true;

  Widget buildItemItemAddCard() {
    return InkWell(
      onTap: () {
        firebaseProvider.changeScreen(Material(child: new AddPaymentMethod()));
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
                padding: new EdgeInsets.all(12),
                decoration: new BoxDecoration(
                    color: Color.fromRGBO(221, 242, 255, 1),
                    shape: BoxShape.circle),
                child: new Image.asset(AssetStrings.addPayment),
              ),
              new SizedBox(
                width: 12,
              ),
              Expanded(
                child: Container(
                  child: new Text(
                    "Add Payment Method",
                    style: new TextStyle(
                      color: AppColors.colorDarkCyan,
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

  Widget buildItemRecentSearch(int index, Data data) {
    return InkWell(
      onTap: () {},
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
                    data?.paypalId?.toString() ?? "",
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
              InkWell(
                onTap: () {
                  showDeletePaypal(index, data?.id?.toString());
                },
                child: Container(
                  padding:
                      new EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                  decoration: new BoxDecoration(
                      color: Color.fromRGBO(255, 237, 237, 1),
                      borderRadius: new BorderRadius.circular(2)),
                  child: new Container(
                    margin: new EdgeInsets.only(left: 6),
                    child: new Text(
                      "Remove",
                      style: new TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(255, 107, 102, 1),
                          fontFamily: AssetStrings.circulerMedium),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
