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
import 'package:payvor/model/post_details/report_request.dart';
import 'package:payvor/model/update_status/update_status_request.dart';
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

/*  final String id;

  PostFavorDetails({this.id});*/

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PayFeebackDetailsCommon>
    with AutomaticKeepAliveClientMixin<PayFeebackDetailsCommon> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      StreamController<bool>();
  ScrollController scrollController = ScrollController();

  AuthProvider provider;

  var ids = "";

  var isCurrentUser = false;

  bool offstageLoader = false;
  int type = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  FocusNode _DescriptionField = FocusNode();

  HiredUserDetailsResponse hiredUserDetailsResponse;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
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
    var reportrequest = ReportPostRequest(
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
    var reportrequest = UpdateStatusRequest(
        favour_id: hiredUserDetailsResponse?.data?.id?.toString(),
        status: "2",
        payment_type: type?.toString());

    var response = await provider.updateFavStatus(reportrequest, context);

    provider.hideLoader();

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        widget.lauchCallBack(Material(
            child: Material(
                child: RatingBarNewBar(
          id: widget?.postId?.toString(),
          type: 1,
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
          paymentAmount: hiredUserDetailsResponse?.data?.receiving?.toString(),
          paymentType: type == 1 ? "Hand Cash" : "Card",
          voidcallback: callbackApi,
        ))));
      }

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
    //  var reportrequest=ReportPostRequest(favour_id: favoriteResponse?.data?.id?.toString());

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
    widget.lauchCallBack(Material(
        child: Material(
            child: RatingBarNewBar(
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
      paymentAmount: hiredUserDetailsResponse?.data?.receiving?.toString(),
      paymentType: type == 1 ? "Hand Cash" : "Card",
      voidcallback: callbackApi,
    ))));
  }

  redirect() async {
    /*  Navigator.push(
      context,
      CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
            child: PostFavour(
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
            EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
        color: Colors.white,
        margin: EdgeInsets.only(top: 4),
        child: Row(
          children: <Widget>[
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                  color: type == 1
                      ? Color.fromRGBO(222, 248, 236, 1)
                      : Color.fromRGBO(255, 107, 102, 0.17),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Image.asset(
                AssetStrings.combine_shape,
                height: 18,
                width: 18,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      first,
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                    child: Container(
                        child: Text(
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
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: tops),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            firstText,
            style: TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                color: AppColors.moreText,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            amount,
            style: TextStyle(
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
    //move to private chat screen
    //widget.fullScreenWidget(screen);

    Navigator.push(
      context,
      CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: screen);
      }),
    );
  }

  Widget buildItemUser() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
                child: ChatMessageDetails(
                  hireduserId: widget.userType == 0
                  ? hiredUserDetailsResponse?.data?.hiredUser?.id?.toString()
                  : hiredUserDetailsResponse?.data?.postedbyuser?.id
                      ?.toString(),
              userButtonMsg: false,
            ));
          }),
        );
      },
      child: Container(
        color: Colors.white,
        padding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
        margin: EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 50.0,
              height: 50.0,
              alignment: Alignment.center,
              child: ClipOval(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      widget.userType == 0
                          ? hiredUserDetailsResponse?.data?.hiredUser?.name ??
                          ""
                          : hiredUserDetailsResponse?.data?.postedbyuser
                          ?.name ?? "",
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 5),
                    child: Row(
                      children: [
                        Container(
                            child: Text(
                              widget?.userType == Constants.HELPER
                              ? "You have hired the person"
                              : "Favor Post Owner",
                          style: TextThemes.greyTextFieldNormalNw,
                        )),
                        /*   Container(
                          width: 3,
                          height: 3,
                          margin: EdgeInsets.only(left: 4, right: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkgrey,
                          ),
                        ) ,
                      Container(
                            child: Text(
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
            EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            type == mainType
                ? Container(
                    width: 17.0,
                    height: 17.0,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(top: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(9, 165, 255, 1),
                        shape: BoxShape.circle),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ))
                : Container(
                    width: 17.0,
                    height: 17.0,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(top: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromRGBO(171, 171, 171, 1.0),
                            width: 1.0),
                        shape: BoxShape.circle)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      title,
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 5),
                    child: Container(
                        child: Text(
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

  Widget buildItemNew() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: 16.0, right: 16.0, top: 10, bottom: 10),
            margin: EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 56.0,
                  alignment: Alignment.center,
                  child: ClipOval(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Text(
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
                                  child: ChatMessageDetails(
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
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 5),
                          color: Colors.white,
                          child: Text(
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
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.lightGrey.withOpacity(0.5),
                              width: 1),
                          shape: BoxShape.circle),
                      padding: EdgeInsets.all(5),
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
            child: Container(
              height: 1.0,
              margin: EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child: Text(
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
              margin: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 7, bottom: 16),
              child: Text(
                "View Original Post",
                style: TextThemes.blueTextFieldMediumm,
              ),
            ),
          ),
          Opacity(
            opacity: 0.12,
            child: Container(
              height: 1.0,
              margin: EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Container(
                      child: Text(
                    "Posted Date",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                ),
                Container(
                  child: Container(
                      child: Text(
                    "Hiring Date",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: 16.0, right: 16.0, top: 7, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    formatDateString(
                        hiredUserDetailsResponse?.data?.createdAt?.toString() ??
                            ""),
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  child: Text(
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
            child: Container(
              height: 1.0,
              margin: EdgeInsets.only(left: 17.0, right: 17.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Container(
                      child: Text(
                    "Amount",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                ),
                Container(
                  child: Container(
                      child: Text(
                    "Favor Status",
                    style: TextThemes.greyTextFieldNormalNw,
                  )),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: 16.0, right: 16.0, top: 7, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    "€ " + hiredUserDetailsResponse?.data?.price?.toString() ??
                        "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                widget?.paidUnpaid != null && widget?.paidUnpaid == 1
                    ? Container(
                        child: Text(
                        hiredUserDetailsResponse?.data?.status == 1
                            ? "Not Paid"
                            : "Paid",
                        style: TextStyle(
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 16,
                            color: hiredUserDetailsResponse?.data?.status == 1
                                ? AppColors.statusYellow
                                : AppColors.statusGreen),
                      ))
                    : Container(
                        child: Text(
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
            child: Container(
              height: 1.0,
              margin: EdgeInsets.only(left: 17.0, right: 17.0),
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
                  margin: EdgeInsets.only(top: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 17.0, top: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: SvgPicture.asset(
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
                          margin: EdgeInsets.only(right: 25.0, top: 10),
                          width: getScreenSize(context: context).width,
                          child: Text(
                            widget?.userType == 0
                                ? "Hired Favors"
                                : "Next Jobs",
                            style: TextStyle(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 0,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        /*   Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 96.0,
                                    width: 96.0,
                                    child: ClipOval(
                                      child: getCachedNetworkImageWithurl(
                                        url: hiredUserDetailsResponse?.data
                                                ?.postedbyuser?.profilePic ??
                                            "",
                                        size: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 96.0,
                                    width: 96.0,
                                    child: ClipOval(
                                      child: getCachedNetworkImageWithurl(
                                        url: hiredUserDetailsResponse
                                                ?.data?.hiredUser?.profilePic ??
                                            "",
                                        size: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                    margin: EdgeInsets.only(top: 31),
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(1.5),
                                              child: Image.asset(
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
                                            child: Container(
                                              margin:
                                              EdgeInsets.only(top: 7.3),
                                              child: Image.asset(
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
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    width: 32,
                                    height: 32),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 16.0),
                          color: Colors.white,
                          child: Text(
                            hiredUserDetailsResponse?.data?.title ?? "",
                            style: TextThemes.blackCirculerLarge,
                          ),
                        ),
                        Container(
                          height: 22,
                          color: Colors.white,
                        ),
                        Opacity(
                          opacity: 0.12,
                          child: Container(
                            height: 1.0,
                            margin:
                                EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                return Material(
                                    child: PostFavorDetails(
                                  id: widget?.postId,
                                  isButtonDesabled: true,
                                ));
                              }),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 14.0, bottom: 14),
                            color: Colors.white,
                            child: Text(
                              "View Original Post",
                              style: TextThemes.blueTextFieldMedium,
                            ),
                          ),
                        ),*/
                        buildItemNew(),
                        //    buildItemUser(),
                        /*  buildItemRating(
                            2,
                            formatDateString(hiredUserDetailsResponse
                                    ?.data?.hireDate
                                    ?.toString() ??
                                "")),*/
                        Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 16),
                            margin: EdgeInsets.only(top: 4),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ResString().get('payment_brkdown'),
                              style: TextThemes.blackCirculerMediumHeight,
                            )),
                        getRowsPayment(
                            ResString().get('job_payment'),
                            "€${hiredUserDetailsResponse?.data?.price?.toString() ?? ""}",
                            23.0),
                        /*  getRowsPayment(
                            ResString().get('payvor_service_fee') +
                                "(${hiredUserDetailsResponse?.data?.servicePerc?.toString()}%)",
                            "-€${hiredUserDetailsResponse?.data?.serviceFee?.toString() ?? ""}",
                            9.0),*/

                        widget?.userType == 1 ? getRowsPayment(
                            !isCurrentUser
                                ? ResString().get('payvor_service_fee') +
                                "(${hiredUserDetailsResponse?.data?.servicePerc
                                    ?.toString()}%)"
                                : ResString().get('payvor_service_fee') +
                                "(0%)",
                            isCurrentUser
                                ? "-€0"
                                : "-€${hiredUserDetailsResponse?.data
                                ?.serviceFee}",
                            9.0) : Container(),
                        Container(
                          height: 13,
                          color: Colors.white,
                        ),
                        Opacity(
                          opacity: 0.12,
                          child: Container(
                            height: 1.0,
                            margin:
                            EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 9, bottom: 21),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget?.userType == Constants.HELPER
                                    ? "You’ll Pay"
                                    : ResString().get('you_all_receive'),
                                style: TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              /*  Text(
                                "€${hiredUserDetailsResponse?.data?.receiving?.toString() ?? ""}",
                                style: TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
*/

                              Text(
                                isCurrentUser || widget?.userType == 0
                                    ? "€${hiredUserDetailsResponse?.data?.price}"
                                    : "€${hiredUserDetailsResponse?.data?.receiving}",
                                style: TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 150.0,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          Offstage(
            offstage: true,
            child: Center(
              child: Text(
                "No Favors Found",
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          ),
          /*    Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                margin: EdgeInsets.only(
                  top: 30,
                  left: 16,
                  right: 5,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              AssetStrings.back,
                              width: 19.0,
                              height: 19.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Container()
                    ],
                  ),
                ),
              )),*/
          widget.giveFeedback
              ? Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Material(
                    elevation: 18.0,
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 9, bottom: 28),
                        child: getSetupButtonNew(callback, "Give Feedback", 16,
                            newColor: AppColors.colorDarkCyan)),
                  ),
                )
              : Container(),
          Center(
            child: getHalfScreenLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
          /* Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
