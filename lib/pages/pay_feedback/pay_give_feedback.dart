import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/hired_user_response_details/hired_user_response-details.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_details/report_request.dart';
import 'package:payvor/model/update_status/update_status_request.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/rating/rating_bar.dart';
import 'package:payvor/paypalpayment/webviewpayment.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class PayFeebackDetails extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;
  final String userId;
  final String postId;
  final int type;
  final ValueSetter<int> voidcallback;

  PayFeebackDetails(
      {@required this.lauchCallBack,
      this.userId,
      this.postId,
      this.type,
      this.voidcallback});

/*  final String id;

  PostFavorDetails({this.id});*/

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PayFeebackDetails>
    with AutomaticKeepAliveClientMixin<PayFeebackDetails> {
  var screenSize;

  FirebaseProvider firebaseProvider;

  ScrollController scrollController = new ScrollController();

  AuthProvider provider;

  var ids = "";

  var isCurrentUser = false;

  bool offstageLoader = false;
  int type = 1;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _DescriptionField = new FocusNode();

  HiredUserDetailsResponse hiredUserDetailsResponse;

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
      hitApi();
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    super.initState();
  }


  ValueSetter<int> callbackApi(int type) {
    widget.voidcallback(1);
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

    var response = await provider.getHiredFavorDetails(
        context, widget?.postId?.toString());

    if (response is HiredUserDetailsResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        hiredUserDetailsResponse = response;

        var userid = hiredUserDetailsResponse?.data?.userId.toString();

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
        favour_id: hiredUserDetailsResponse?.data?.id?.toString());

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

  updateUserPaymentStatus() async {
    provider.setLoading();
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
    var reportrequest = new UpdateStatusRequest(
        favour_id: hiredUserDetailsResponse?.data?.id?.toString(),
        status: "2",
        payment_type: type?.toString());

    var response = await provider.updateFavStatus(reportrequest, context);

    provider.hideLoader();

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        if (widget.voidcallback != null) {
          widget.voidcallback(1);
        }

        firebaseProvider.changeScreen(Material(
            child: Material(
                child: new RatingBarNew(
          id: widget?.postId?.toString(),
          type: widget?.type,
          image: widget.type == 0
              ? hiredUserDetailsResponse?.data?.hiredUser?.profilePic ?? ""
              : hiredUserDetailsResponse?.data?.postedbyuser?.profilePic ?? "",
          name: widget.type == 0
              ? hiredUserDetailsResponse?.data?.hiredUser?.name ?? "" : hiredUserDetailsResponse?.data
                      ?.postedbyuser?.name ?? "",
                  userId: widget.type == 0
                      ? hiredUserDetailsResponse?.data?.hiredUser?.id
                      ?.toString() ?? ""
                      : hiredUserDetailsResponse?.data?.postedbyuser?.id
                      ?.toString() ?? "",
                  paymentAmount: hiredUserDetailsResponse?.data?.receiving
                      ?.toString(),
                  paymentType: type == 1 ? "Hand Cash" : "Card/Paypal",
                  voidcallback: callbackApi,

                ))));
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
        hiredUserDetailsResponse?.data?.id?.toString(), context);

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
    if (widget.type == 0 && type == 0) {
      showInSnackBar("Please select payment type");

      return;
    }

    if (widget.type == 0) {
      if (type == 2) {
        var getdata = await Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new WebviewPayment(
              type: "favour",
              itemId: widget?.postId?.toString(),
            );
          }),
        );

        if (getdata is bool) {
          if (getdata == true) {
            showBottomSheet("Successful!", "Payment Successful!.", 1);
            /*Navigator.pop(context);
        widget.voidcallback(1);*/
          } else {
            showBottomSheet("Failed!", "Payment Failed!.", 0);
          }
        }
      } else {
        updateUserPaymentStatus();
      }
    } else {
      // updateUserPaymentStatus();

      firebaseProvider.changeScreen(Material(
          child: Material(
              child: new RatingBarNew(
        id: widget?.postId?.toString(),
        type: widget?.type,
        image: widget.type == 0
            ? hiredUserDetailsResponse?.data?.hiredUser?.profilePic ?? ""
            : hiredUserDetailsResponse?.data?.postedbyuser?.profilePic ?? "",
        name: widget.type == 0
            ? hiredUserDetailsResponse?.data?.hiredUser?.name ?? ""
            : hiredUserDetailsResponse?.data?.postedbyuser?.name ?? "",
        userId: widget.type == 0
            ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString() ?? ""
            : hiredUserDetailsResponse?.data?.postedbyuser?.id?.toString() ??
                "",
        paymentAmount: hiredUserDetailsResponse?.data?.receiving?.toString(),
        paymentType: type == 1 ? "Hand Cash" : "Card/Paypal",
        voidcallback: callbackApi,
      ))));
    }
  }

  void showBottomSheet(String text, String desc, int type) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86.0,
                    height: 86.0,
                    margin: new EdgeInsets.only(top: 38),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: type == 1
                          ? Color.fromRGBO(37, 26, 101, 1)
                          : Color.fromRGBO(255, 107, 102, 1.0),
                      shape: BoxShape.circle,
                    ),
                    child: type == 1
                        ? new SvgPicture.asset(
                            AssetStrings.check,
                            width: 42.0,
                            height: 42.0,
                            color: Colors.white,
                          )
                        : new SvgPicture.asset(
                            AssetStrings.cross,
                            width: 42.0,
                            height: 42.0,
                            color: Colors.white,
                          ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 40),
                    child: new Text(
                      text,
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 10),
                    child: new Text(
                      desc,
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        color: Color.fromRGBO(114, 117, 112, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: getSetupButtonNew(
                        type == 1 ? callbackSuccess : callbackSuccessFailed,
                        "Ok",
                        0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }

  Future<bool> callbackSuccessFailed() async {
    Navigator.pop(context);
  }

  Future<bool> callbackSuccess() async {
    Navigator.pop(context);
    updateUserPaymentStatus();
  }

  /*  await Future.delayed(Duration(milliseconds: 200));
    showInSnackBar("Favour applied successfully");
    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context); //back to previous screen
   // showBottomSheet();*/

  redirect() async {
    /*  Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
            child: new PostFavour(
          favourDetailsResponse: favoriteResponse,
          isEdit: true,
        ));
      }),
    );*/
  }


  String formatDateString(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      print("date error ${e.toString()}");
      return "";
    }
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
              child: new Image.asset(
              type == 1 ? AssetStrings.checkTick : AssetStrings.combine_shape,
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
                child: new ChatMessageDetails(
                  hireduserId: widget.type == 0 ? hiredUserDetailsResponse?.data
                      ?.hiredUser?.id?.toString() : hiredUserDetailsResponse
                      ?.data?.postedbyuser?.id?.toString(),
                  userButtonMsg: true,
                ));
          }),
        );
      },
      child: Container(
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
                    url: widget.type == 0 ? hiredUserDetailsResponse?.data
                        ?.hiredUser?.profilePic ?? "" : hiredUserDetailsResponse
                        ?.data?.postedbyuser?.profilePic ?? "",
                    fit: BoxFit.fill,
                    size: 50),
              ),
            ),
            Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Text(
                      widget.type == 0 ? hiredUserDetailsResponse?.data
                          ?.hiredUser?.name : hiredUserDetailsResponse?.data
                          ?.postedbyuser?.name,
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 5),
                    child: Row(
                      children: [
                        Container(
                            child: new Text(
                              widget?.type == 0
                                  ? "You have hired the person"
                                  : "Favor Post Owner",
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
                            color: Color.fromRGBO(171, 171, 171, 1.0),
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
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: hiredUserDetailsResponse != null
                ? SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.white,
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
                                        url: hiredUserDetailsResponse?.data
                                            ?.postedbyuser?.profilePic ?? "",
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
                                        url: hiredUserDetailsResponse?.data
                                            ?.hiredUser?.profilePic ?? "",
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
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: InkWell(
                                            onTap: () {},
                                            child: new Padding(
                                              padding: const EdgeInsets.all(
                                                  1.5),
                                              child: new Image.asset(
                                                AssetStrings.chatSend,
                                                width: 32,
                                                height: 32,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          left: 0.0,
                                          right: 0.0,
                                          child: InkWell(
                                            onTap: () {},
                                            child: new Container(
                                              margin: new EdgeInsets.only(
                                                  top: 7.3),
                                              child: new Image.asset(
                                                AssetStrings.combineUser,
                                                width: 16,
                                                height: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    width: 32,
                                    height: 32

                                ),
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
                            hiredUserDetailsResponse?.data?.title ?? "",
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
                            Navigator.push(
                              context,
                              new CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                    return Material(
                                        child: new PostFavorDetails(
                                          id: widget?.postId,
                                          isButtonDesabled: true,
                                        ));
                                  }),
                            );
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
                  buildItemRating(2, formatDateString(
                      hiredUserDetailsResponse
                                    ?.data?.hireDate
                                    ?.toString() ?? "")),

                  widget.type == 0 ? Container(
                      color: Colors.white,
                      padding: new EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16),
                      margin: new EdgeInsets.only(top: 4),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        "Payment Method"
                        ,
                        style: TextThemes.blackCirculerMediumHeight,
                      )) : Container(),
                  widget?.type == 0
                      ? buildPaymentType(1, "Hand Cash",
                      "You can Pay to the receiver by handcash. Receiver will cost 0% fee.")
                      : Container(),
                  widget?.type == 0 ? Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin:
                      new EdgeInsets.only(left: 17.0, right: 17.0),
                      color: AppColors.dividerColor,
                    ),
                  ) : Container(),
                  widget?.type == 0
                      ? buildPaymentType(2, "Card/Paypal",
                      "You can Pay to the receiver by debit/credit/paypal. Receiver will cost 3% fee.")
                      : Container(),
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
                  getRowsPayment(
                      ResString().get('job_payment'),
                      "€${hiredUserDetailsResponse?.data?.price?.toString() ??
                          ""}", 23.0),
                  getRowsPayment(
                      ResString().get('payvor_service_fee') +
                          "(${hiredUserDetailsResponse?.data?.servicePerc
                              ?.toString()}%)",
                      "-€${hiredUserDetailsResponse?.data?.serviceFee?.toString() ?? ""}",
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
                                widget?.type == 0 ? "You’ll Pay" : ResString()
                                    .get('you_all_receive'),
                                style: new TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              new Text(
                                "€${hiredUserDetailsResponse?.data?.receiving
                                    ?.toString() ?? ""}",
                                style: new TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                  widget?.type == 1
                      ? buildItemRating(1, "Favor Ended")
                      : Container(),
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
                              width: 18.0,
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
          hiredUserDetailsResponse != null
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
                            callback, widget.type == 0
                            ? "Pay and Give Feedback"
                            : "Give Feedback", 16,
                            newColor: AppColors.colorDarkCyan)),
                  ),
                )
              : Container(),
          new Center(
            child: getHalfScreenLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
          /* new Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
