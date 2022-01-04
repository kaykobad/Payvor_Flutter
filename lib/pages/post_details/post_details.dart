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
import 'package:payvor/model/promotion/promotion_response.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/payment/payment_dialog.dart';
import 'package:payvor/pages/payment/post_payment.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/pages/search/search_name.dart';
import 'package:payvor/pages/stripe_card_added/stripe_card_added.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/shimmers/shimmer_details.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PostFavorDetails extends StatefulWidget {
  final String id;
  ValueSetter<int> voidcallback;
  bool isButtonDesabled;
  String distance;

  PostFavorDetails(
      {this.id,
      this.voidcallback,
      this.isButtonDesabled = false,
      this.distance});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PostFavorDetails>
    with AutomaticKeepAliveClientMixin<PostFavorDetails> {
  var screenSize;

  // final StreamController<bool> _loaderStreamController = StreamController<bool>();
  ScrollController scrollController = ScrollController();
  bool guestViewMain = false;

  List<String> listOption = ["Report", "Share", "Hide Post"];

  PropmoteDataResponse propmoteDataResponse = PropmoteDataResponse();

  AuthProvider provider;
  var ids = "";
  var isCurrentUser = false;
  bool offstageLoader = false;
  String distance = "";
  FirebaseProvider providerFirebase;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  // FocusNode _DescriptionField = FocusNode();

  FavourDetailsResponse favoriteResponse;

  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(value ?? "Something went wrong")));
  }

  @override
  void initState() {
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    ids = userinfo?.user?.id.toString() ?? "";

    var guestUser = MemoryManagement.getGuestUser();
    if (guestUser != null) {
      guestViewMain = guestUser;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi();
      hitApiPromotion(0);
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    if (widget?.distance != null) {
      distance = widget?.distance;
    }

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

    var response = await provider.getFavorPostDetails(context, widget.id);

    if (response is FavourDetailsResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        favoriteResponse = response;

        var userid = favoriteResponse?.data?.userId.toString();

        if (userid == ids) {
          isCurrentUser = true;
        }

//        print(" is applied already"
//            " ${favoriteResponse?.data?.is_user_applied}");
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  hitApiPromotion(int type) async {
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

    var response = await provider.getPromotionData(context);

    if (response is PropmoteDataResponse) {
      if (response != null && response.data != null) {
        propmoteDataResponse = response;
        if (type == 1) {
          showBottomSheet();
        }
      }
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);
      if (type == 1) {
        showInSnackBar(apiError.error);
      }
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
        favour_id: favoriteResponse?.data?.id?.toString());

    var response = await provider.reportUser(reportrequest, context);

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        showInSnackBar(response.success);
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
    //  var reportrequest=ReportPostRequest(favour_id: favoriteResponse?.data?.id?.toString());

    var response = await provider.deletePost(
        favoriteResponse?.data?.id?.toString(), context);

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        if (widget.voidcallback != null) {
          widget.voidcallback(1);
          Navigator.pop(context);
        }
        showInSnackBar(response.success);
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

  void _hidePostBlockUserApi(int type) async {
    setState(() {
      offstageLoader = true;
    });

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

    var response = await provider.hidePost(
        favoriteResponse?.data?.id?.toString(), type, context);

    setState(() {
      offstageLoader = false;
    });

    if (response is ReportResponse) {
      if (widget.voidcallback != null) {
        widget.voidcallback(1);
        Navigator.pop(context);
      }

      print(response);
    } else {
      APIError apiError = response;
      showInSnackBar(apiError.error);
    }
  }

  hitApplyFavApi() async {
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
        favour_id: favoriteResponse?.data?.id?.toString());

    var response = await provider.applyFav(reportrequest, context);

    offstageLoader = false;

    if (response is ReportResponse) {
      showBottomSuccessPayment("Apply Successful!",
          "You have applied to the favor Successfully", "Keep Applying", 0);
    } else {
      APIError apiError = response;
      print(apiError.error);
      showInSnackBar(apiError.error);
    }

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  void callback() async {
    if ((favoriteResponse?.data?.is_user_applied != 1) &&
        (widget.isButtonDesabled != null && !widget.isButtonDesabled)) {
      //  var status= MemoryManagement.getPaymentStatus()??"";
      var firstTimePayment = MemoryManagement.getFirstPaymentStatus() ?? false;
      var paymentStatus = MemoryManagement.getPaymentStatus() ?? false;

      if (!paymentStatus && !firstTimePayment) {
        showBottomPaymentMethod();
        MemoryManagement.setFirstPaymentStatus(status: true);
      } else {
        // showBottomPaymentMethod();
        hitApplyFavApi();
        //  showInSnackBar(response.status.message);

        // showBottomPaymentMethod();
      }
    }

    /* await Future.delayed(Duration(milliseconds: 200));
    showInSnackBar("Favour applied successfully");
    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context); //back to previous screen*/
  }

  void callbackPromote() async {
    if (propmoteDataResponse != null && propmoteDataResponse.data != null) {
      showBottomSheet();
    } else {
      hitApiPromotion(1);
    }
  }

  void callbackPaymentSuccess() async {
    Navigator.pop(context); //back to previous screen
  }

  void callbackPaymentAddMethod() async {
    Navigator.pop(context); //back to previous screen
    /* providerFirebase
        ?.changeScreen(Material(child: AddPaymentMethodFirst()));*/
    providerFirebase?.changeScreen(Material(child: StripeCardAddedList(payingAmount: "0",)));
  }

  void callbackPaymentSuccessBack() async {
    Navigator.pop(context);
    Navigator.pop(context); //back to previous screen
  }

  Widget buildItem() {
    return Container(
      color: Colors.white,
      padding:
          EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    favoriteResponse?.data.title ?? "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Image.asset(
                        AssetStrings.locationHome,
                        width: 11,
                        height: 14,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Container(
                          child: Container(
                            child: Text(
                              favoriteResponse?.data.location +
                                      " - " +
                                      distance ??
                                  "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              style: TextThemes.greyDarkTextHomeLocation,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Text(
                "€${favoriteResponse?.data.price ?? ""}",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }

  redirect() async {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
            child: PostFavour(
          favourDetailsResponse: favoriteResponse,
          isEdit: true,
          voidcallback: voidCallBackUpdateSearch,
        ));
      }),
    );
  }

  Widget getBottomText(String icon, String text, double size) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (text == "Report Post") {
          _showConfirmDialog(1, 'Are you sure want to report this post?');
        } else if (text == "Share Post") {
          _share();
        } else if (text == "Edit Post") {
          redirect();
        } else if (text == "Hide Post") {
          _showConfirmDialog(
              3, 'Are you sure want to hide this post from your home?');
        } else if (text == "Block User") {
          _showConfirmDialog(4,
              'You will not be able to see any posts from this user in future.Are you sure want to block this user?');
        } else if (text == "Delete Post") {
          _showConfirmDialog(2, 'Are you sure want to delete this post?');
        }
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  icon,
                  width: size,
                  height: size,
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Container(
              child: Text(
                text,
                style: text == "Delete Post"
                    ? TextThemes.darkRedMedium
                    : TextThemes.darkBlackMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomSheets() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 43, left: 27),
                      child:
                          getBottomText(AssetStrings.share, "Share Post", 22)),
                  !isCurrentUser
                      ? Container(
                          margin: EdgeInsets.only(top: 35, left: 27),
                          child: getBottomText(
                              AssetStrings.slash, "Report Post", 22))
                      : Container(),
                  !isCurrentUser
                      ? Container(
                          margin: EdgeInsets.only(top: 35, left: 27),
                          child: getBottomText(
                              AssetStrings.slash, "Block User", 22))
                      : Container(),
                  !isCurrentUser
                      ? Container(
                          margin: EdgeInsets.only(top: 35, left: 27),
                          child: getBottomText(
                              AssetStrings.slash, "Hide Post", 22))
                      : Container(),
                  isCurrentUser
                      ? Container(
                          margin: EdgeInsets.only(top: 35, left: 27),
                          child:
                              getBottomText(AssetStrings.edit, "Edit Post", 22))
                      : Container(),
                  isCurrentUser
                      ? Container(
                          margin: EdgeInsets.only(top: 35, left: 27),
                          child: getBottomText(
                              AssetStrings.delete, "Delete Post", 22))
                      : Container(),
                  Opacity(
                    opacity: 0.12,
                    child: Container(
                      height: 1.0,
                      margin: EdgeInsets.only(top: 35, left: 27, right: 27),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 35, left: 24),
                      child: getBottomText(AssetStrings.cross, " Cancel", 18)),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0)),
            child: Container(
              height: MediaQuery.of(context).size.height / 1.4,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: PaymentDialogPost(
                      data: propmoteDataResponse, voidcallback: voidCallBacks)),
            ),
          );
        });
  }

  void _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    String selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, 80, 30, 0),
      items: listOption.map((String popupRoute) {
        return PopupMenuItem<String>(
          child: Text(popupRoute),
          value: popupRoute,
        );
      }).toList(),
      elevation: 3.0,
    );

    if (selected == "Report") {
      print("Report");
      //   _showConfirmDialog();
    } else {
      print("Share");
      _share();
    }
  }

  Widget buildItemRating(int type, String first) {
    return InkWell(
      onTap: () {
        if (type == 1) {
          print("review_post from my post details creen");
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (BuildContext context) {
              return Material(
                  child: ReviewPost(
                id: favoriteResponse?.data?.userId?.toString() ?? "",
              ));
            }),
          );
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (BuildContext context) {
              return Material(
                  child: SearchHomeByName(
                lat: favoriteResponse?.data?.lat,
                long: favoriteResponse?.data?.long,
                description: favoriteResponse?.data?.description,
                id: favoriteResponse?.data?.id.toString(),
              ));
            }),
          );
        }
      },
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
                  color: Color.fromRGBO(255, 107, 102, 0.17),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                type == 1 ? AssetStrings.shape : AssetStrings.referIcon,
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
                    child: type == 1
                        ? Row(
                            children: [
                              Image.asset(
                                AssetStrings.rating,
                                width: 13,
                                height: 13,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Container(
                                  child: Text(
                                favoriteResponse?.data?.ratingAvg.toString() ??
                                    "",
                                style: TextThemes.greyTextFieldNormalNw,
                              )),
                              Container(
                                width: 3,
                                height: 3,
                                margin: EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.darkgrey,
                                ),
                              ),
                              Container(
                                  child: Text(
                                "${favoriteResponse?.data?.ratingCount.toString() ?? "0"} Reviews",
                                style: TextThemes.greyTextFieldNormalNw,
                              )),
                            ],
                          )
                        : Container(
                            child: Text(
                            "Refer someone who is good fit for the job",
                            style: TextThemes.greyTextFieldNormalNw,
                          )),
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

  Widget buildItemUser() {
    return InkWell(
      onTap: () {
        if (!isCurrentUser) {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (BuildContext context) {
              return Material(
                  child: ChatMessageDetails(
                id: "",
                name: favoriteResponse.data.user.name ?? "",
                image: favoriteResponse.data.user.profilePic ?? "",
                hireduserId: favoriteResponse.data.user.id.toString() ?? "",
              ));
            }),
          );
        }
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
                    url: favoriteResponse.data.user.profilePic ?? "",
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
                      favoriteResponse?.data?.user?.name ?? "",
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 3),
                    child: Row(
                      children: [
                        Container(
                            child: Text(
                          "Favor Post Owner",
                          style: TextThemes.greyTextFieldNormalNw,
                        )),
                        favoriteResponse?.data?.user?.perc == 100
                            ? Container(
                                width: 3,
                                height: 3,
                                margin: EdgeInsets.only(left: 4, right: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.darkgrey,
                                ),
                              )
                            : Container(),
                        favoriteResponse?.data?.user?.perc == 100
                            ? Container(
                                child: Text(
                                "VERIFIED",
                                style: TextThemes.blueMediumSmallNew,
                              ))
                            : Container(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            favoriteResponse?.data?.user?.perc == 100
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Image.asset(AssetStrings.verify),
                      width: 21,
                      height: 21,
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<ValueSetter> voidCallBackUpdateSearch(int type) async {
    print("update favor");
    widget?.voidcallback(1);
  }

  Future<ValueSetter> voidCallBacks(int type) async {
    if (type == 1) {
      //  showPaymentDialog();
    } else {
      showBottomSuccessPayment(
          "Successful!",
          "Payment is Successful! It will take some time to be appeared higher up in the feed.",
          "I Understand",
          1);
    }
  }

  void showPaymentDialog() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0)),
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: PaymentDialog(voidcallback: voidCallBacks)),
            ),
          );
        });
  }

  void showBottomPaymentMethod() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        isDismissible: false,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 22),
                    child: Image.asset(AssetStrings.artworkPayment,
                        width: 120.0, height: 105.0),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: Text(
                      "Add Payment Method",
                      style: TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 35, right: 35),
                    alignment: Alignment.center,
                    child: Text(
                      "You’ve to add a account to apply for the favors. You’ll be paid to the account you are going to add ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        height: 1.5,
                        color: Color.fromRGBO(114, 117, 112, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40, left: 16, right: 16),
                    child: getSetupButtonNew(
                        callbackPaymentAddMethod, "Add Now", 0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  Container(
                    height: 41,
                  )
                ],
              )));
        });
  }

  void showBottomSuccessPayment(String title, String description, String buttonText, int type) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26.0),
            topRight: Radius.circular(26.0),
          ),
        ),
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.only(top: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86.0,
                  height: 86.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.greenDark,
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      /* //_showPopupMenu(details.globalPosition);
                           showBottomSheet();*/
                    },
                    child: SvgPicture.asset(
                      AssetStrings.check,
                      width: 42.0,
                      height: 42.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 24),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AssetStrings.circulerMedium,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8, left: 18, right: 18),
                  alignment: Alignment.center,
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AssetStrings.circulerNormal,
                      fontSize: 16,
                      color: Color.fromRGBO(114, 117, 112, 1),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 44, left: 16, right: 16),
                  child: getSetupButtonNew(
                      type == 1
                          ? callbackPaymentSuccess
                          : callbackPaymentSuccessBack,
                      buttonText,
                      0,
                      newColor: AppColors.colorDarkCyan,
                  ),
                ),
                Container(height: 26)
              ],
            ),
          );
        });
  }

  Future<void> _showConfirmDialog(int type, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                //Text('This is a demo alert dialog.'),
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('YES'),
              onPressed: () {
                if (type == 1) {
                  hitReportApi();
                } else if (type == 2) {
                  hitDeletePostApi();
                } else if (type == 3) {
                  _hidePostBlockUserApi(0); //Hide post
                } else {
                  _hidePostBlockUserApi(1); //Block user
                }

                //showInSnackBar("Post reported successfully");
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _share() async {
    Share.share('check out this post https://google.com');
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    providerFirebase = Provider.of<FirebaseProvider>(context);
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: favoriteResponse != null && favoriteResponse.data != null
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 214,
                          width: double.infinity,
                          child: ClipRRect(
                            // margin: EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                            borderRadius: BorderRadius.circular(0.0),

                            child: getCachedNetworkImageRect(
                              url: favoriteResponse.data.image,
                              size: 214,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        buildItem(),
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
                                left: 16.0, right: 16.0, top: 16.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ResString().get('description'),
                              style: TextThemes.blackCirculerMediumHeight,
                            )),
                        Container(
                          padding: EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 10.0, bottom: 18),
                          color: Colors.white,
                          width: double.infinity,
                          child: ReadMoreText(
                            favoriteResponse?.data?.description ?? "",
                            trimLines: 4,
                            colorClickableText: AppColors.colorDarkCyan,
                            trimMode: TrimMode.Line,
                            style: TextStyle(
                              color: AppColors.moreText,
                              fontFamily: AssetStrings.circulerNormal,
                              fontSize: 14.0,
                            ),
                            trimCollapsedText: '...more',
                            trimExpandedText: ' less',
                          ),
                        ),
                        buildItemUser(),
                        !isCurrentUser
                            ? buildItemRating(1, "User Ratings")
                            : Container(),
                        // !isCurrentUser
                        //     ? buildItemRating(2, "Refer Others")
                        //     : Container(),
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
                        getRowsPayment(ResString().get('job_payment'),
                            "€${favoriteResponse?.data?.price}", 23.0),
                        getRowsPayment(
                            !isCurrentUser
                                ? ResString().get('payvor_service_fee') +
                                    "(${favoriteResponse?.data?.service_perc?.toString()}%)"
                                : ResString().get('payvor_service_fee') +
                                    "(0%)",
                            isCurrentUser
                                ? "-€0"
                                : "-€${favoriteResponse?.data?.service_fee}",
                            9.0),
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
                                !isCurrentUser
                                    ? ResString().get('you_all_receive')
                                    : "You’ll Pay",
                                style: TextStyle(
                                    fontFamily: AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                isCurrentUser
                                    ? "€${favoriteResponse?.data?.price}"
                                    : "€${favoriteResponse?.data?.receiving}",
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
          Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                margin: EdgeInsets.only(
                  top: 36,
                  left: 16,
                  right: 8,
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
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.greyProfile.withOpacity(0.4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: .4,
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              AssetStrings.back,
                              width: 21.0,
                              height: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 30.0,
                        height: 30.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColors.greyProfile.withOpacity(0.4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: .4,
                              ),
                            ],
                        ),
                        child: GestureDetector(
                            onTapDown: (TapDownDetails details) {
                              //_showPopupMenu(details.globalPosition);
                              showBottomSheets();

                              //    showBottomSheetSuccesss();
                              //  showBottomSheet();
                            },
                            child: Icon(Icons.more_vert, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              )),
          favoriteResponse != null && favoriteResponse.data != null
              ? !isCurrentUser
                  ? Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
            child: !guestViewMain
                          ? Material(
                              elevation: 18.0,
                              child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(top: 9, bottom: 28),
                                  child: getSetupButtonColor(callback,
                                      ResString().get('apply_for_fav'), 16,
                                      newColor: (widget.isButtonDesabled != null &&
                                                  widget.isButtonDesabled) ||
                                              favoriteResponse?.data?.is_user_applied == 1
                                          ? AppColors.desabledGray
                                          : AppColors.colorDarkCyan)),
                            )
                          : Container(),
                    )
                  : Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: widget.isButtonDesabled != null &&
                              !widget.isButtonDesabled
                          ? Material(
                        // elevation: 18.0,
                              child: Container(
                                  /*  color: Colors.white,
                                  padding:
                                      EdgeInsets.only(top: 9, bottom: 28),
                                  child: getSetupButtonNew(callbackPromote,
                                      "Promote your Favor", 16)*/
                                  ),
                            )
                          : Container(),
                    )
              : Container(),
          Center(
            child: getHalfScreenLoader(
              status: offstageLoader,
              context: context,
            ),
          ),
          Visibility(visible: provider.getLoading(), child: ShimmerDetails())
          /* Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
