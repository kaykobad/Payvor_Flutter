import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/hired_user_response_details/hired_user_response-details.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/update_status/update_status_request.dart';
import 'package:payvor/pages/chat/private_chat.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/rating/rating_bar_new.dart';
import 'package:payvor/pages/stripe_card_added/stripe_card_added.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class PayFeebackDetails extends StatefulWidget {
  final String userId;
  final String postId;
  final int type;
  final ValueSetter<int> voidcallback;
  final int userType;
  final int paidUnpaid;

  PayFeebackDetails(
      {this.userId,
      this.postId,
      this.type,
      this.voidcallback,
      this.userType,
      this.paidUnpaid});

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
  int type = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  HiredUserDetailsResponse hiredUserDetailsResponse;
  var _isPaymentStatusUpdated=false;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi();
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    super.initState();
  }

  ValueSetter<int> callbackApi(int type) {
    widget.voidcallback(1);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBarNew(context),
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
                          height: 0,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        buildItemNew(),
                        widget.type == 0 ? paymentMethod : Container(),
                        widget?.type == 0
                            ? buildPaymentType(1, "Hand Cash",
                                "You can Pay to the receiver by handcash. Receiver will cost 0% fee.")
                            : Container(),
                        widget?.type == 0
                            ? Opacity(
                                opacity: 0.12,
                                child: new Container(
                                  height: 1.0,
                                  margin: new EdgeInsets.only(
                                      left: 17.0, right: 17.0),
                                  color: AppColors.dividerColor,
                                ),
                              )
                            : Container(),
                        widget?.type == 0
                            ? buildPaymentType(2, "Card",
                                "You can Pay to the receiver by debit/credit/paypal. Receiver will cost 3% fee.")
                            : Container(),
                        paymentBreak,
                        getRowsPayment(
                            ResString().get('job_payment'),
                            "€${hiredUserDetailsResponse?.data?.price?.toString() ?? ""}",
                            23.0),
                        getRowsPayment(
                            widget?.type == 1
                                ? ResString().get('payvor_service_fee') +
                                    "(${hiredUserDetailsResponse?.data?.servicePerc?.toString()}%)"
                                : ResString().get('payvor_service_fee') +
                                    "(0%)",
                            widget?.type == 0
                                ? "-€0"
                                : "-€${hiredUserDetailsResponse?.data?.serviceFee}",
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
                        paymentStatus,
                        widget?.type == 1
                            ? buildItemRating(
                                1, /* "Favor Ended"*/ "Congratz! You’re paid.")
                            : Container(),
                        new SizedBox(
                          height: 150.0,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          noFavorFound,
          hiredUserDetailsResponse != null ? giveFeedbackButton : Container(),
          new Center(
            child: getHalfScreenLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  get noFavorFound => Offstage(
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
      );

  get paymentBreak => Container(
      color: Colors.white,
      padding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
      margin: new EdgeInsets.only(top: 4),
      alignment: Alignment.centerLeft,
      child: new Text(
        ResString().get('payment_brkdown'),
        style: TextThemes.blackCirculerMediumHeight,
      ));

  get paymentMethod => Container(
      color: Colors.white,
      padding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
      margin: new EdgeInsets.only(top: 4),
      alignment: Alignment.centerLeft,
      child: new Text(
        "Payment Method",
        style: TextThemes.blackCirculerMediumHeight,
      ));

  get paymentStatus => new Container(
        color: Colors.white,
        padding: new EdgeInsets.only(left: 16, right: 16, top: 9, bottom: 21),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text(
              widget?.type == 0
                  ? "You’ll Pay"
                  : ResString().get('you_all_receive'),
              style: new TextStyle(
                  fontFamily: AssetStrings.circulerBoldStyle,
                  color: AppColors.bluePrimary,
                  fontSize: 15),
              textAlign: TextAlign.center,
            ),
            new Text(
              widget?.type == 0
                  ? "€${hiredUserDetailsResponse?.data?.price}"
                  : "€${hiredUserDetailsResponse?.data?.receiving}",
              style: new TextStyle(
                  fontFamily: AssetStrings.circulerBoldStyle,
                  color: AppColors.bluePrimary,
                  fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  get giveFeedbackButton => Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Material(
          elevation: 18.0,
          child: Container(
              color: Colors.white,
              padding: new EdgeInsets.only(top: 9, bottom: 28),
              child: getSetupButtonNew(
                  callback,
                  widget.type == 0 ? "Pay and Give Feedback" : "Give Feedback",
                  16,
                  newColor: AppColors.colorDarkCyan)),
        ),
      );

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
      }

      print(response);
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
    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        setState(() {});
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }
    var reportRequest = new UpdateStatusRequest(
        favour_id: hiredUserDetailsResponse?.data?.id?.toString(),
        status: "2",
        payment_type: type?.toString());

    var response = await provider.updateFavStatus(reportRequest, context);
   // var response=null;
    if (response is ReportResponse) {
      _isPaymentStatusUpdated=true;
      if (widget.voidcallback != null) {
        widget.voidcallback(1);
      }

    } else {
      APIError apiError = response;
      showInSnackBar(apiError?.error??"error");

    }
  }

  _moveToRatingScreen() {
    firebaseProvider.changeScreen(Material(
        child: Material(
            child: new RatingBarNewBar(
      id: widget?.postId?.toString(),
      type: widget?.type,
      image: widget.userType == Constants.HELPER
          ? hiredUserDetailsResponse?.data?.hiredUser?.profilePic ?? ""
          : hiredUserDetailsResponse?.data?.postedbyuser?.profilePic ?? "",
      name: widget.userType == Constants.HELPER
          ? hiredUserDetailsResponse?.data?.hiredUser?.name ?? ""
          : hiredUserDetailsResponse?.data?.postedbyuser?.name ?? "",
      userId: widget.userType == Constants.HELPER
          ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString() ?? ""
          : hiredUserDetailsResponse?.data?.postedbyuser?.id?.toString() ?? "",
      paymentAmount: hiredUserDetailsResponse?.data?.price?.toString(),
      paymentType: type == 1 ? "Hand Cash" : "Card",
      voidcallback: callbackApi,
    ))));
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
        // print(
        //     "hired_user ${hiredUserDetailsResponse?.data?.hiredUser?.toJson()}");
        var response = await Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new StripeCardAddedList(
              payingAmount: hiredUserDetailsResponse?.data?.price,
              hiredUserId: hiredUserDetailsResponse?.data?.hiredUser?.id ?? 0,
              hiredUserName:
                  hiredUserDetailsResponse?.data?.hiredUser?.name ?? "",
              hiredUserProfilePic:
                  hiredUserDetailsResponse?.data?.hiredUser?.profilePic ?? "",
              postId: widget?.postId,
            );
          }),
        );


        if(response!=null) {
          // Payment done update status
          if (response == true) {
            updateUserPaymentStatus();
            showBottomSheet("Payment Successful!",
                "You have paid the Helper successfully.", 1);
          } else {
            showBottomSheet("Payment Failed!", "Payment Failed!.", 0);
          }
        }
      }
      // If payment type hand cash than update the status
      else {
        updateUserPaymentStatus();
        showBottomSheet("Payment Successful!",
            "You have paid the Helper successfully.", 1);
      }
    } else { // Go for rating only

      firebaseProvider.changeScreen(Material(
          child: Material(
              child: new RatingBarNewBar(
                id: widget?.postId?.toString(),
        type: widget?.userType,
                image: widget.userType == Constants.HELPER
            ? hiredUserDetailsResponse?.data?.hiredUser?.profilePic ?? ""
            : hiredUserDetailsResponse?.data?.postedbyuser?.profilePic ?? "",
                name: widget.userType == Constants.HELPER
            ? hiredUserDetailsResponse?.data?.hiredUser?.name ?? ""
            : hiredUserDetailsResponse?.data?.postedbyuser?.name ?? "",
                userId: widget.userType == Constants.HELPER
            ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString() ?? ""
            : hiredUserDetailsResponse?.data?.postedbyuser?.id?.toString() ??
                "",
        paymentAmount: hiredUserDetailsResponse?.data?.price?.toString(),
        paymentType: type == 1 ? "Hand Cash" : "Card",
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
                          ? AppColors.greenDark
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
                        type == 1 ? "Rate Helper" : "Ok",
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
    // if payment status not updated due to some failure than try again for
   if(!_isPaymentStatusUpdated) updateUserPaymentStatus();
     Navigator.pop(context); // close current bottom sheet
    _moveToRatingScreen();
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
              alignment: Alignment.center,
              child: new Image.asset(
                AssetStrings.money,
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
                          type == 1
                          ? "Favor Owner has paid & ended the job. You can give a feedback in return."
                          : "Hiring Date",
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

  void goToChat() async {
    var currentUserId;
    var _userName;
    var _userProfilePic;
    var userData = MemoryManagement.getUserInfo();
    if (userData != null) {
      Map<String, dynamic> data = jsonDecode(userData);
      LoginSignupResponse userResponse = LoginSignupResponse.fromJson(data);
      _userName = userResponse.user.name ?? "";
      _userProfilePic = userResponse.user.profilePic ?? "";
      currentUserId = userResponse.user.id.toString();
    }
    var screen = PrivateChat(
      peerId: widget.userType == Constants.HELPER
          ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString()
          : hiredUserDetailsResponse?.data?.postedbyuser?.id?.toString(),
      peerAvatar: widget.userType == Constants.HELPER
          ? hiredUserDetailsResponse?.data?.hiredUser?.profilePic
          : hiredUserDetailsResponse?.data?.postedbyuser?.profilePic,
      userName: widget.userType == Constants.HELPER
          ? hiredUserDetailsResponse?.data?.hiredUser?.name
          : hiredUserDetailsResponse?.data?.postedbyuser?.name,
      isGroup: false,
      currentUserId: currentUserId,
      currentUserName: _userName,
      currentUserProfilePic: _userProfilePic,
    );

    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: screen);
      }),
    );
  }

  Widget buildItemNew() {
    return Container(
      color: Colors.white,
      child: new Column(
        children: [
          Container(
            padding: new EdgeInsets.only(
                left: 16.0, right: 16.0, top: 10, bottom: 10),
            margin: new EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 56.0,
                  height: 56.0,
                  alignment: Alignment.center,
                  child: new ClipOval(
                    child: getCachedNetworkImageWithurl(
                        url: widget.userType == Constants.HELPER
                            ? hiredUserDetailsResponse
                                    ?.data?.hiredUser?.profilePic ??
                                ""
                            : hiredUserDetailsResponse
                                    ?.data?.postedbyuser?.profilePic ??
                                "",
                        fit: BoxFit.fill,
                        size: 50),
                  ),
                ),
                Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: new EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: new Text(
                          widget.userType == Constants.HELPER
                              ? hiredUserDetailsResponse?.data?.hiredUser?.name
                              : hiredUserDetailsResponse?.data?.postedbyuser?.name,
                          style: TextThemes.blackCirculerLarge,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            new CupertinoPageRoute(
                                builder: (BuildContext context) {
                              return Material(
                                  child: new ChatMessageDetails(
                                    hireduserId: widget.userType == Constants.HELPER
                                    ? hiredUserDetailsResponse
                                        ?.data?.hiredUser?.id
                                        ?.toString()
                                    : hiredUserDetailsResponse
                                        ?.data?.postedbyuser?.id
                                        ?.toString(),
                                userButtonMsg: true,
                              ));
                            }),
                          );
                        },
                        child: new Container(
                          width: double.infinity,
                          margin: new EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 5),
                          color: Colors.white,
                          child: new Text(
                            "View Profile",
                            style: TextThemes.blueTextFieldMediumm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      goToChat();
                    },
                    child: Container(
                      decoration: new BoxDecoration(
                          border: new Border.all(
                              color: AppColors.lightGrey.withOpacity(0.5),
                              width: 1),
                          shape: BoxShape.circle),
                      padding: new EdgeInsets.all(5),
                      child: Icon(
                        Icons.chat_outlined,
                        color: AppColors.kTinderSwipeLikeDislikeTextColor,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.12,
            child: new Container(
              height: 1.0,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child: new Text(
              hiredUserDetailsResponse?.data?.title ?? "",
              style: TextThemes.blackCirculerMedium,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(builder: (BuildContext context) {
                  return Material(
                      child: PostFavorDetails(
                        id: widget?.postId,
                        isButtonDesabled: true,
                      ));
                }),
              );
            },
            child: Container(
              color: Colors.white,
              alignment: Alignment.centerLeft,
              margin: new EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 7, bottom: 16),
              child: new Text(
                "View Original Post",
                style: TextThemes.blueTextFieldMediumm,
              ),
            ),
          ),
          Opacity(
            opacity: 0.12,
            child: new Container(
              height: 1.0,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Container(
                      child: new Text(
                    "Posted Date",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                ),
                Container(
                  child: Container(
                      child: new Text(
                    "Hiring Date",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                )
              ],
            ),
          ),
          Container(
            margin: new EdgeInsets.only(
                left: 16.0, right: 16.0, top: 7, bottom: 16),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: new Text(
                    formatDateString(
                        hiredUserDetailsResponse?.data?.createdAt?.toString() ??
                            ""),
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  child: new Text(
                    formatDateString(
                        hiredUserDetailsResponse?.data?.hireDate?.toString() ??
                            ""),
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.12,
            child: new Container(
              height: 1.0,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Container(
                      child: new Text(
                    "Amount",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                ),
                Container(
                  child: Container(
                      child: new Text(
                    "Favor Status",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                )
              ],
            ),
          ),
          Container(
            margin: new EdgeInsets.only(
                left: 16.0, right: 16.0, top: 7, bottom: 16),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: new Text(
                    "€ " + hiredUserDetailsResponse?.data?.price?.toString() ??
                        "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                widget?.paidUnpaid != null && widget?.paidUnpaid == 1
                    ? Container(
                        child: new Text(
                        hiredUserDetailsResponse?.data?.status == 1
                            ? "Not Paid"
                            : "Paid",
                        style: new TextStyle(
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 16,
                            color: hiredUserDetailsResponse?.data?.status == 1
                                ? AppColors.statusYellow
                                : AppColors.statusGreen),
                      ))
                    : Container(
                        child: new Text(
                          hiredUserDetailsResponse?.data?.status == 1
                              ? "Active"
                              : "Inactive",
                          style: TextThemes.readAlert,
                        ),
                      ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.12,
            child: new Container(
              height: 1.0,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
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
                  hireduserId: widget.userType == Constants.HELPER
                  ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString()
                  : hiredUserDetailsResponse?.data?.postedbyuser?.id
                      ?.toString(),
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
                    url: widget.userType == Constants.HELPER
                        ? hiredUserDetailsResponse
                                ?.data?.hiredUser?.profilePic ??
                            ""
                        : hiredUserDetailsResponse
                                ?.data?.postedbyuser?.profilePic ??
                            "",
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
                      widget.userType == Constants.HELPER
                          ? hiredUserDetailsResponse?.data?.hiredUser?.name
                          : hiredUserDetailsResponse?.data?.postedbyuser?.name,
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
                            widget?.userType == Constants.HELPER
                                ? "Hired Favors"
                                : "Next Jobs",
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


}
