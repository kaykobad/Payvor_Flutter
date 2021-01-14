import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_details/report_request.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/payment/payment_dialog.dart';
import 'package:payvor/pages/payment/post_payment.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/rating/rating_bar.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/pages/search/search_name.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/shimmers/shimmer_details.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PayFeebackDetails extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;

  PayFeebackDetails({@required this.lauchCallBack});

/*  final String id;

  PostFavorDetails({this.id});*/

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PayFeebackDetails>
    with AutomaticKeepAliveClientMixin<PayFeebackDetails> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  AuthProvider provider;

  var ids = "";

  var isCurrentUser = false;

  bool offstageLoader = false;
  int type = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _DescriptionField = new FocusNode();

  FavourDetailsResponse favoriteResponse;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
/*

    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    ids = userinfo?.user?.id.toString() ?? "";
*/

    Future.delayed(const Duration(milliseconds: 300), () {
      //  hitApi();
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    super.initState();
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

    var response = await provider.getFavorPostDetails(context, "1");

    if (response is FavourDetailsResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        favoriteResponse = response;

        var userid = favoriteResponse?.data?.userId.toString();

        if (userid == ids) {
          isCurrentUser = true;
        }

        print("user $userid");
        print("usermain $ids");
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }

    setState(() {});
  }

  hitReportApi() async {
    offstageLoader = true;
    setState(() {});

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        offstageLoader = false;
        setState(() {});
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }
    var reportrequest = new ReportPostRequest(
        favour_id: favoriteResponse?.data?.id?.toString());

    var response = await provider.reportUser(reportrequest, context);

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        showInSnackBar(response.status.message);
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }

    setState(() {});
  }

  hitDeletePostApi() async {
    offstageLoader = true;
    setState(() {});

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        offstageLoader = false;
        setState(() {});
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }
    //  var reportrequest=new ReportPostRequest(favour_id: favoriteResponse?.data?.id?.toString());

    var response = await provider.deletePost(
        favoriteResponse?.data?.id?.toString(), context);

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        showInSnackBar(response.status.message);
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  void callback() async {
    widget.lauchCallBack(Material(child: Material(child: new RatingBarNew())));

    /*  await Future.delayed(Duration(milliseconds: 200));
    showInSnackBar("Favour applied successfully");
    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context); //back to previous screen
   // showBottomSheet();*/
  }

  redirect() async {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
            child: new PostFavour(
          favourDetailsResponse: favoriteResponse,
          isEdit: true,
        ));
      }),
    );
  }

  Widget buildItemRating(int type, String first) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
        color: Colors.white,
        margin: new EdgeInsets.only(top: 4),
        child: Row(
          children: <Widget>[
            new Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                  color: type == 1
                      ? Color.fromRGBO(222, 248, 236, 1)
                      : Color.fromRGBO(255, 107, 102, 0.17),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: new SvgPicture.asset(
                AssetStrings.shape,
                height: 18,
                width: 18,
              ),
            ),
            Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Text(
                      first,
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                    child: Container(
                        child: new Text(
                      type == 1 ? "Owner has ended the favor" : "Hiring Date",
                      style: TextThemes.greyTextFieldNormalNw,
                    )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getRowsPayment(String firstText, String amount, double tops) {
    return new Container(
      color: Colors.white,
      padding: new EdgeInsets.only(left: 16, right: 16, top: tops),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(
            firstText,
            style: new TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                color: AppColors.moreText,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
          new Text(
            amount,
            style: new TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                color: Colors.black,
                fontSize: 14),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget buildItemUser() {
    return Container(
      color: Colors.white,
      padding:
          new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
      margin: new EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 50.0,
            height: 50.0,
            alignment: Alignment.center,
            child: new ClipOval(
              child: getCachedNetworkImageWithurl(
                  url: "", fit: BoxFit.fill, size: 50),
            ),
          ),
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new Text(
                    "ggjgjgjgjg",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 5),
                  child: Row(
                    children: [
                      Container(
                          child: new Text(
                        "Favor Post Owner",
                        style: TextThemes.greyTextFieldNormalNw,
                      )),
                      /*   Container(
                        width: 3,
                        height: 3,
                        margin: new EdgeInsets.only(left: 4, right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkgrey,
                        ),
                      ) ,
                    Container(
                          child: new Text(
                            "VERIFIED",
                            style: TextThemes.blueMediumSmallNew,
                          )),*/
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color.fromRGBO(183, 183, 183, 1.0),
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentType(int mainType, String title, String desc) {
    return InkWell(
      onTap: () {
        type = mainType;
        setState(() {});
      },
      child: Container(
        color: Colors.white,
        padding:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            type == mainType
                ? new Container(
                    width: 17.0,
                    height: 17.0,
                    padding: new EdgeInsets.all(5),
                    margin: new EdgeInsets.only(top: 2),
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                        color: Color.fromRGBO(9, 165, 255, 1),
                        shape: BoxShape.circle),
                    child: new Container(
                      decoration: new BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ))
                : new Container(
                    width: 17.0,
                    height: 17.0,
                    padding: new EdgeInsets.all(5),
                    margin: new EdgeInsets.only(top: 2),
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                        border: new Border.all(
                            color: Color.fromRGBO(103, 99, 99, 1.0),
                            width: 1.0),
                        shape: BoxShape.circle)),
            Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Text(
                      title,
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 10.0, top: 5),
                    child: Container(
                        child: new Text(
                      desc,
                      style: TextThemes.greyTextFieldNormalNw,
                    )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: favoriteResponse == null
                ? SingleChildScrollView(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          height: 30,
                          width: double.infinity,
                          color: Colors.transparent,
                        ),
                        Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Container(
                                    height: 96.0,
                                    width: 96.0,
                                    child: ClipOval(
                                      child: getCachedNetworkImageWithurl(
                                        url: "",
                                        size: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  new Container(
                                    height: 96.0,
                                    width: 96.0,
                                    child: ClipOval(
                                      child: getCachedNetworkImageWithurl(
                                        url: "",
                                        size: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: new Container(
                                    margin: new EdgeInsets.only(top: 31),
                                    decoration: new BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle),
                                    width: 30,
                                    height: 30),
                              )
                            ],
                          ),
                        ),
                        new Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: new EdgeInsets.only(top: 16.0),
                          color: Colors.white,
                          child: new Text(
                            "Help me carry some books",
                            style: TextThemes.blackCirculerLarge,
                          ),
                        ),
                        new Container(
                          height: 22,
                          color: Colors.white,
                        ),
                        Opacity(
                          opacity: 0.12,
                          child: new Container(
                            height: 1.0,
                            margin:
                                new EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            widget.lauchCallBack(Material(
                                child: Material(
                                    child: new ChatMessageDetails(id: "55"))));
                          },
                          child: new Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: new EdgeInsets.only(top: 14.0, bottom: 14),
                            color: Colors.white,
                            child: new Text(
                              "View Original Post",
                              style: TextThemes.blueTextFieldMedium,
                            ),
                          ),
                        ),
                        buildItemUser(),
                        buildItemRating(2, "02 Jan 2021"),
                        Container(
                            color: Colors.white,
                            padding: new EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 16),
                            margin: new EdgeInsets.only(top: 4),
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              ResString().get('payment_brkdown'),
                              style: TextThemes.blackCirculerMediumHeight,
                            )),
                        buildPaymentType(1, "Hand Cash",
                            "You can Pay to the receiver by handcash. Receiver will cost 0% fee."),
                        Opacity(
                          opacity: 0.12,
                          child: new Container(
                            height: 1.0,
                            margin:
                                new EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        buildPaymentType(2, "Card/Paypal",
                            "You can Pay to the receiver by debit/credit/paypal. Receiver will cost 3% fee."),
                        Container(
                            color: Colors.white,
                            padding: new EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 16),
                            margin: new EdgeInsets.only(top: 4),
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              "Payment Method",
                              style: TextThemes.blackCirculerMediumHeight,
                            )),
                        getRowsPayment(
                            ResString().get('job_payment'), "€5", 23.0),
                        getRowsPayment(
                            ResString().get('payvor_service_fee') + "(20%)",
                            "€20",
                            9.0),
                        new Container(
                          height: 13,
                          color: Colors.white,
                        ),
                        Opacity(
                          opacity: 0.12,
                          child: new Container(
                            height: 1.0,
                            margin:
                                new EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        new Container(
                          color: Colors.white,
                          padding: new EdgeInsets.only(
                              left: 16, right: 16, top: 9, bottom: 21),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              new Text(
                                ResString().get('you_all_receive'),
                                style: new TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              new Text(
                                "€10",
                                style: new TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        buildItemRating(1, "Favor Ended"),
                        new SizedBox(
                          height: 150.0,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          Offstage(
            offstage: true,
            child: new Center(
              child: new Text(
                "No Favors Found",
                style: new TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          ),
          Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                margin: new EdgeInsets.only(
                  top: 30,
                  left: 16,
                  right: 5,
                ),
                child: new Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          padding: new EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: new SvgPicture.asset(
                              AssetStrings.back,
                              width: 21.0,
                              height: 18.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Container()
                    ],
                  ),
                ),
              )),
          favoriteResponse == null
              ? Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Material(
                    elevation: 18.0,
                    child: Container(
                        color: Colors.white,
                        padding: new EdgeInsets.only(top: 9, bottom: 28),
                        child: getSetupButtonNew(
                            callback, "Pay and Give Feedback", 16,
                            newColor: AppColors.colorDarkCyan)),
                  ),
                )
              : Container(),
          new Center(
            child: getHalfScreenLoader(
              status: offstageLoader,
              context: context,
            ),
          ),
          Visibility(visible: provider.getLoading(), child: ShimmerDetails())
          /* new Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
