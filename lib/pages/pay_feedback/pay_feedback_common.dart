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
import 'package:payvor/pages/chat/private_chat.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/rating/rating_bar_new.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class PayFeebackDetailsCommon extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;
  final String userId;
  final String postId;
  final bool giveFeedback;
  final ValueSetter<int> voidcallback;
  final int userType;
  final int paidUnpaid;

  PayFeebackDetailsCommon(
      {@required this.lauchCallBack,
      this.userId,
      this.postId,
      this.giveFeedback,
      this.voidcallback,
      this.userType,
      this.paidUnpaid});


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PayFeebackDetailsCommon>
    with AutomaticKeepAliveClientMixin<PayFeebackDetailsCommon> {
  var screenSize;
  ScrollController scrollController =  ScrollController();
  AuthProvider provider;
  var ids = "";
  var isCurrentUser = false;
  bool offstageLoader = false;
  int type = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  HiredUserDetailsResponse hiredUserDetailsResponse;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar( SnackBar(content:  Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi();
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

  ValueSetter<int> callbackApi(int type) {
    widget.voidcallback(1);
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBarNew(context),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
           Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: hiredUserDetailsResponse != null
                ? SingleChildScrollView(
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                         Container(
                          height: 0,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        buildItemNew(),
                        paymentBreak,
                        getRowsPayment(
                            ResString().get('job_payment'),
                            "€${hiredUserDetailsResponse?.data?.price?.toString() ?? ""}",
                            23.0),
                        widget?.userType == 1
                            ? getRowsPayment(
                                !isCurrentUser
                                    ? ResString().get('payvor_service_fee') +
                                        "(${hiredUserDetailsResponse?.data?.servicePerc?.toString()}%)"
                                    : ResString().get('payvor_service_fee') +
                                        "(0%)",
                                isCurrentUser
                                    ? "-€0"
                                    : "-€${hiredUserDetailsResponse?.data?.serviceFee}",
                                9.0)
                            : Container(),
                         Container(
                          height: 13,
                          color: Colors.white,
                        ),
                        Opacity(
                          opacity: 0.12,
                          child:  Container(
                            height: 1.0,
                            margin:
                                 EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        paymentStatys,
                         SizedBox(
                          height: 150.0,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          noFavor,
          widget.giveFeedback ? feedbackButton : Container(),
           Center(
            child: getHalfScreenLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void callback() async {
    widget.lauchCallBack(Material(
        child: Material(
            child:  RatingBarNewBar(
      id: widget?.postId?.toString(),
      type: 1,
      image: widget.userType == 0
          ? hiredUserDetailsResponse?.data?.hiredUser?.profilePic ?? ""
          : hiredUserDetailsResponse?.data?.postedbyuser?.profilePic ?? "",
      name: widget.userType == 0
          ? hiredUserDetailsResponse?.data?.hiredUser?.name ?? ""
          : hiredUserDetailsResponse?.data?.postedbyuser?.name ?? "",
      userId: widget.userType == 0
          ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString() ?? ""
          : hiredUserDetailsResponse?.data?.postedbyuser?.id?.toString() ?? "",
      paymentAmount: hiredUserDetailsResponse?.data?.price?.toString(),
      paymentType: type == 1 ? "Hand Cash" : "Card",
      voidcallback: callbackApi,
    ))));
  }

  redirect() async {}

  String formatDateString(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      print("date error ${e.toString()}");
      return "";
    }
  }


  Widget getRowsPayment(String firstText, String amount, double tops) {
    return  Container(
      color: Colors.white,
      padding:  EdgeInsets.only(left: 16, right: 16, top: tops),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            firstText,
            style:  TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                color: AppColors.moreText,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
           Text(
            amount,
            style:  TextStyle(
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
      peerId: widget.userType == 0
          ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString()
          : hiredUserDetailsResponse?.data?.postedbyuser?.id?.toString(),
      peerAvatar: widget.userType == 0
          ? hiredUserDetailsResponse?.data?.hiredUser?.profilePic
          : hiredUserDetailsResponse?.data?.postedbyuser?.profilePic,
      userName: widget.userType == 0
          ? hiredUserDetailsResponse?.data?.hiredUser?.name
          : hiredUserDetailsResponse?.data?.postedbyuser?.name,
      isGroup: false,
      currentUserId: currentUserId,
      currentUserName: _userName,
      currentUserProfilePic: _userProfilePic,
    );

    Navigator.push(
      context,
       CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: screen);
      }),
    );
  }

  Widget buildItemNew() {
    return Container(
      color: Colors.white,
      child:  Column(
        children: [
          Container(
            padding:  EdgeInsets.only(
                left: 16.0, right: 16.0, top: 10, bottom: 10),
            margin:  EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                 Container(
                  width: 56.0,
                  height: 56.0,
                  alignment: Alignment.center,
                  child:  ClipOval(
                    child: getCachedNetworkImageWithurl(
                        url: widget.userType == 0
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
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin:  EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child:  Text(
                          widget.userType == 0
                              ? hiredUserDetailsResponse?.data?.hiredUser?.name
                              : hiredUserDetailsResponse?.data?.postedbyuser?.name,
                          style: TextThemes.blackCirculerLarge,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                             CupertinoPageRoute(
                                builder: (BuildContext context) {
                              return Material(
                                  child:  ChatMessageDetails(
                                    hireduserId: widget.userType == 0
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
                        child:  Container(
                          width: double.infinity,
                          margin:  EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 5),
                          color: Colors.white,
                          child:  Text(
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
                      decoration:  BoxDecoration(
                          border:  Border.all(
                              color: AppColors.lightGrey.withOpacity(0.5),
                              width: 1),
                          shape: BoxShape.circle),
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        "assets/png/chat_icon.png",
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.12,
            child:  Container(
              height: 1.0,
              margin:  EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            margin:  EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child:  Text(
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
              margin:  EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 7, bottom: 16),
              child:  Text(
                "View Original Post",
                style: TextThemes.blueTextFieldMediumm,
              ),
            ),
          ),
          Opacity(
            opacity: 0.12,
            child:  Container(
              height: 1.0,
              margin:  EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            margin:  EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Container(
                      child:  Text(
                    "Posted Date",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                ),
                Container(
                  child: Container(
                      child:  Text(
                    "Hiring Date",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                )
              ],
            ),
          ),
          Container(
            margin:  EdgeInsets.only(
                left: 16.0, right: 16.0, top: 7, bottom: 16),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child:  Text(
                    formatDateString(
                        hiredUserDetailsResponse?.data?.createdAt?.toString() ??
                            ""),
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  child:  Text(
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
            child:  Container(
              height: 1.0,
              margin:  EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            margin:  EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Container(
                      child:  Text(
                    "Amount",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                ),
                Container(
                  child: Container(
                      child:  Text(
                    "Favor Status",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                )
              ],
            ),
          ),
          Container(
            margin:  EdgeInsets.only(
                left: 16.0, right: 16.0, top: 7, bottom: 16),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child:  Text(
                    "€ " + hiredUserDetailsResponse?.data?.price?.toString() ??
                        "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                widget?.paidUnpaid != null && widget?.paidUnpaid == 1
                    ? Container(
                        child:  Text(
                        hiredUserDetailsResponse?.data?.status == 1
                            ? "Not Paid"
                            : "Paid",
                        style:  TextStyle(
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 16,
                            color: hiredUserDetailsResponse?.data?.status == 1
                                ? AppColors.statusYellow
                                : AppColors.statusGreen),
                      ))
                    : Container(
                        child:  Text(
                          hiredUserDetailsResponse?.data?.status == 1
                              ? "Not Paid"
                              : "Paid",
                          style: hiredUserDetailsResponse?.data?.status == 1
                              ? TextThemes.readAlert.copyWith(color: Color(0xFFFFAB00))
                              : TextThemes.readAlert.copyWith(color: Color(0xFF28D175)),
                        ),
                      ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.12,
            child:  Container(
              height: 1.0,
              margin:  EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
        ],
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
               SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.white,
                child: Container(
                  margin:  EdgeInsets.only(top: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin:  EdgeInsets.only(left: 17.0, top: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child:  Padding(
                            padding: const EdgeInsets.all(3.0),
                            child:  SvgPicture.asset(
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
                          margin:  EdgeInsets.only(right: 25.0, top: 10),
                          width: getScreenSize(context: context).width,
                          child:  Text(
                            widget?.userType == 0
                                ? "Hired Favors"
                                : "Next Jobs",
                            style:  TextStyle(
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

  get noFavor => Offstage(
        offstage: true,
        child:  Center(
          child:  Text(
            "No Favors Found",
            style:  TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
        ),
      );

  get feedbackButton => Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Material(
          elevation: 18.0,
          child: Container(
              color: Colors.white,
              padding:  EdgeInsets.only(top: 9, bottom: 28),
              child: getSetupButtonNew(callback, "Give Feedback", 16,
                  newColor: AppColors.colorDarkCyan)),
        ),
      );

  get paymentStatys =>  Container(
        color: Colors.white,
        padding:  EdgeInsets.only(left: 16, right: 16, top: 9, bottom: 21),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              widget?.userType == Constants.HELPER
                  ? "You’ll Pay"
                  : ResString().get('you_all_receive'),
              style:  TextStyle(
                  fontFamily: AssetStrings.circulerBoldStyle,
                  color: AppColors.bluePrimary,
                  fontSize: 15),
              textAlign: TextAlign.center,
            ),
             Text(
              isCurrentUser || widget?.userType == 0
                  ? "€${hiredUserDetailsResponse?.data?.price}"
                  : "€${hiredUserDetailsResponse?.data?.receiving}",
              style:  TextStyle(
                  fontFamily: AssetStrings.circulerBoldStyle,
                  color: AppColors.bluePrimary,
                  fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  get paymentBreak => Container(
      color: Colors.white,
      padding:  EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
      margin:  EdgeInsets.only(top: 4),
      alignment: Alignment.centerLeft,
      child:  Text(
        ResString().get('payment_brkdown'),
        style: TextThemes.blackCirculerMediumHeight,
      ));
}
