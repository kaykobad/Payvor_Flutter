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
import 'package:payvor/pages/payment/payment_dialog.dart';
import 'package:payvor/pages/payment/post_payment.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
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
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PostFavorDetails extends StatefulWidget {
  final String id;
  ValueSetter<int> voidcallback;

  PostFavorDetails({this.id, this.voidcallback});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PostFavorDetails>
    with AutomaticKeepAliveClientMixin<PostFavorDetails> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  List<String> listOption = ["Report", "Share"];

  PropmoteDataResponse propmoteDataResponse = new PropmoteDataResponse();

  AuthProvider provider;

  var ids = "";

  var isCurrentUser = false;

  bool offstageLoader = false;

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
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    ids = userinfo?.user?.id.toString() ?? "";

    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi();
      hitApiPromotion(0);
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

    var response = await provider.getFavorPostDetails(context, widget.id);

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
    }
    else {
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
    setState(() {

    });

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        offstageLoader = false;
        setState(() {

        });
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
        showInSnackBar(response.message);
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
    setState(() {

    });

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        offstageLoader = false;
        setState(() {

        });
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
        if (widget.voidcallback != null) {
          widget.voidcallback(1);
          Navigator.pop(context);
        }
        showInSnackBar(response.message);
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


  hitApplyFavApi() async {
    offstageLoader = true;
    setState(() {

    });

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        offstageLoader = false;
        setState(() {

        });
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }
    var reportrequest = new ReportPostRequest(
        favour_id: favoriteResponse?.data?.id?.toString());


    var response = await provider.applyFav(reportrequest, context);

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        showBottomSuccessPayment(
            "Apply Successful!", "You have applied to the favor Successfully",
            "Done", 0);

        //  showInSnackBar(response.status.message);
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
    hitApplyFavApi();
    /* await Future.delayed(Duration(milliseconds: 200));
    showInSnackBar("Favour applied successfully");
    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context); //back to previous screen*/

  }

  void callbackPromote() async {
    if (propmoteDataResponse != null && propmoteDataResponse.data != null) {
      showBottomSheet();
    }
    else {
      hitApiPromotion(1);
    }
  }

  void callbackPaymentSuccess() async {
    Navigator.pop(context); //back to previous screen

  }


  void callbackPaymentSuccessBack() async {
    Navigator.pop(context);
    Navigator.pop(context); //back to previous screen

  }

  Widget buildItem() {
    return Container(
      color: Colors.white,
      padding:
      new EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: new Text(
                    favoriteResponse?.data.title ?? "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      new Image.asset(
                        AssetStrings.locationHome,
                        width: 11,
                        height: 14,
                      ),
                      new SizedBox(
                        width: 6,
                      ),
                      Container(
                          child: new Text(
                            favoriteResponse?.data.location ?? "",
                            style: TextThemes.greyDarkTextHomeLocation,
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: new Text(
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
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: new PostFavour(
          favourDetailsResponse: favoriteResponse, isEdit: true,));
      }),
    );
  }

  Widget getBottomText(String icon, String text, double size) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (text == "Report Post") {
          _showConfirmDialog(1, 'Are you sure want to report this post?');
        }
        else if (text == "Share Post") {
          _share();
        }
        else if (text == "Edit Post") {
          redirect();
        }
        else if (text == "Delete Post") {
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
                child: new SvgPicture.asset(
                  icon,
                  width: size,
                  height: size,
                ),
              ),
            ),
            new SizedBox(
              width: 20.0,
            ),
            Container(
              child: new Text(
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
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      margin: new EdgeInsets.only(top: 43, left: 27),
                      child:
                          getBottomText(AssetStrings.share, "Share Post", 22)),
                  !isCurrentUser
                      ? Container(
                          margin: new EdgeInsets.only(top: 35, left: 27),
                          child: getBottomText(
                              AssetStrings.slash, "Report Post", 22))
                      : Container(),
                  isCurrentUser
                      ? Container(
                          margin: new EdgeInsets.only(top: 35, left: 27),
                          child:
                              getBottomText(AssetStrings.edit, "Edit Post", 22))
                      : Container(),
                  isCurrentUser
                      ? Container(
                          margin: new EdgeInsets.only(top: 35, left: 27),
                      child:
                      getBottomText(AssetStrings.delete, "Delete Post", 22))
                      : Container(),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(top: 35, left: 27, right: 27),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                      margin: new EdgeInsets.only(top: 35, left: 24),
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
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0)),
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 1.4,
              decoration: new BoxDecoration(
                  color: Colors.black,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
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
        return new PopupMenuItem<String>(
          child: new Text(popupRoute),
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
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return Material(child: new ReviewPost());
            }),
          );
        } else {
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return Material(
                  child: new SearchHomeByName(
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
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
        color: Colors.white,
        margin: new EdgeInsets.only(top: 4),
        child: Row(
          children: <Widget>[
            new Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 107, 102, 0.17),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: new SvgPicture.asset(
                type == 1 ? AssetStrings.shape : AssetStrings.referIcon,
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
                    child: type == 1
                        ? Row(
                            children: [
                              new SvgPicture.asset(
                                AssetStrings.star,
                              ),
                              new SizedBox(
                                width: 3,
                              ),
                              Container(
                                  child: new Text(
                                    favoriteResponse?.data?.ratingAvg.toString() ?? "",
                                    style: TextThemes.greyTextFieldNormalNw,
                              )),
                              Container(
                                width: 3,
                                height: 3,
                                margin: new EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.darkgrey,
                                ),
                              ),
                              Container(
                                  child: new Text(
                                    "${favoriteResponse?.data?.ratingCount
                                        .toString() ?? "0"} Reviews",
                                    style: TextThemes.greyTextFieldNormalNw,
                              )),
                            ],
                          )
                        : Container(
                            child: new Text(
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
                  url: favoriteResponse.data.user.profilePic ?? "",
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
                    favoriteResponse?.data?.user?.name??""
                        ,
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 3),
                  child: Row(
                    children: [
                      Container(
                          child: new Text(
                            "Favor Post Owner",
                            style: TextThemes.greyTextFieldNormalNw,
                          )),
                      favoriteResponse?.data.isActive == 1 ? Container(
                        width: 3,
                        height: 3,
                        margin: new EdgeInsets.only(left: 4, right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkgrey,
                        ),
                      ) : Container(),
                      favoriteResponse?.data.isActive == 1 ? Container(
                          child: new Text(
                            "VERIFIED",
                            style: TextThemes.blueMediumSmallNew,
                          )) : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Container(
                child: Image.asset(AssetStrings.verify),
                width: 21,
                height: 21,
              )),
        ],
      ),
    );
  }


  Future<ValueSetter> voidCallBacks(int type) async {
    if (type == 1) {
      showPaymentDialog();
    }
    else {
      showBottomSuccessPayment("Successful!",
          "Payment is Successful! It will take some time to be appeared higher up in the feed.",
          "I Understand", 1);
    }
  }


  void showPaymentDialog() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0),
              topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return ClipRRect(
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0)),
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 1.4,
              decoration: new BoxDecoration(
                  color: Colors.black,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: PaymentDialog(voidcallback: voidCallBacks)),
            ),
          );
        });
  }

  void showBottomSuccessPayment(String title, String description,
      String buttonText, int type) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
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
                          color: Color.fromRGBO(37, 26, 101, 1),
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                            onTapDown: (TapDownDetails details) {
                              /* //_showPopupMenu(details.globalPosition);
                               showBottomSheet();*/
                            },
                            child: new SvgPicture.asset(
                              AssetStrings.check,
                              width: 42.0,
                              height: 42.0,
                              color: Colors.white,
                            )),
                      ),

                      new Container(
                        margin: new EdgeInsets.only(top: 40),
                        child: new Text(title, style: new TextStyle(
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 20,
                            color: Colors.black),),
                      ),

                      new Container(
                        margin: new EdgeInsets.only(
                            top: 10, left: 35, right: 35),
                        alignment: Alignment.center,
                        child: new Text(
                          description,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 16,
                            height: 1.5,
                            color: Color.fromRGBO(114, 117, 112, 1),),),


                      ),

                      Container(
                        margin: new EdgeInsets.only(
                            top: 60, left: 16, right: 16),
                        child: getSetupButtonNew(
                            type == 1
                                ? callbackPaymentSuccess
                                : callbackPaymentSuccessBack, buttonText, 0,
                            newColor: AppColors.colorDarkCyan),
                      ),


                      Container(
                        height: 56,
                      )
                    ],
                  )));
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
                }
                else {
                  hitDeletePostApi();
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

  void _share()async
  {
    Share.share('check out this post https://google.com');

  }


  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: favoriteResponse != null && favoriteResponse.data != null
                ? SingleChildScrollView(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          height: 214,
                          width: double.infinity,
                          child: ClipRRect(
                            // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                            borderRadius: new BorderRadius.circular(0.0),

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
                          child: new Container(
                            height: 1.0,
                            margin:
                                new EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        Container(
                            color: Colors.white,
                            padding: new EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 16.0),
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              ResString().get('description'),
                              style: TextThemes.blackCirculerMediumHeight,
                            )),
                        Container(
                          padding: new EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 10.0, bottom: 18),
                          color: Colors.white,
                          width: double.infinity,
                          child: ReadMoreText(
                            favoriteResponse?.data?.description ?? "",
                            trimLines: 4,
                            colorClickableText: AppColors.colorDarkCyan,
                            trimMode: TrimMode.Line,
                            style: new TextStyle(
                              color: AppColors.moreText,
                              fontFamily: AssetStrings.circulerNormal,
                              fontSize: 14.0,
                            ),
                            trimCollapsedText: '...more',
                            trimExpandedText: ' less',
                          ),
                        ),
                        buildItemUser(),
                        buildItemRating(1, "User Ratings"),
                        buildItemRating(2, "Refer Others"),
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
                        getRowsPayment(ResString().get('job_payment'),
                            "€${favoriteResponse?.data?.price}", 23.0),
                        getRowsPayment(
                            ResString().get('payvor_service_fee') + "(20%)",
                            "€${favoriteResponse?.data?.service_fee}",
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
                                    fontFamily:
                                        AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              new Text(
                                "€${favoriteResponse?.data?.receiving}",
                                style: new TextStyle(
                                    fontFamily:
                                        AssetStrings.circulerBoldStyle,
                                    color: AppColors.bluePrimary,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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
                margin: new EdgeInsets.only(top: 30, left: 16, right: 5,),
                child: new Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(

                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          padding: new EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.greyProfile.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  blurRadius: .5,
                                ),
                              ]),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: new SvgPicture.asset(
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
                                color: Colors.grey.withOpacity(0.4),
                                blurRadius: .5,
                              ),
                            ]),
                        child: GestureDetector(
                            onTapDown: (TapDownDetails details) {
                              //_showPopupMenu(details.globalPosition);
                              showBottomSheets();

                              //    showBottomSheetSuccesss();
                              //  showBottomSheet();
                            },
                            child: new Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
              )),
          favoriteResponse != null && favoriteResponse.data != null
              ? !isCurrentUser ? Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Material(
              elevation: 18.0,
              child: Container(
                  color: Colors.white,
                  padding: new EdgeInsets.only(top: 9, bottom: 28),
                  child: getSetupButtonNew(
                      callback, ResString().get('apply_for_fav'), 16,
                      newColor: AppColors.colorDarkCyan)),
            ),
          ) : Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Material(
              elevation: 18.0,
              child: Container(
                  color: Colors.white,
                  padding: new EdgeInsets.only(top: 9, bottom: 28),
                  child: getSetupButtonNew(
                      callbackPromote, "Promote your Favor", 16)),
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
