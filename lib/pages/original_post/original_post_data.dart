import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/hiew/hire_list.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_details/report_request.dart';
import 'package:payvor/pages/chat/private_chat.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/shimmers/shimmer_details.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class OriginalPostData extends StatefulWidget {
  final String id;
  final ValueChanged<Widget> lauchCallBack;
  ValueSetter<int> voidcallback;

  OriginalPostData({this.id, this.lauchCallBack, this.voidcallback});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<OriginalPostData>
    with AutomaticKeepAliveClientMixin<OriginalPostData> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  List<String> listOption = ["Report", "Share"];

  var list = List<DatasUser>();

  AuthProvider provider;

  var ids = "";

  bool offstageApplicant = false;

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
        .showSnackBar(new SnackBar(content: new Text(value??"Favour deleted")));
  }

  String hireUserid = "";
  int pos;

  @override
  void initState() {
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    ids = userinfo?.user?.id.toString() ?? "";

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

    var response = await provider.getFavorPostDetails(context, widget.id);

    if (response is FavourDetailsResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        favoriteResponse = response;

        hitUserHireList();

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

  hitUserHireList() async {
    offstageLoader = false;
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

    var response = await provider.userHireList(
        favoriteResponse?.data?.id?.toString(), context);

    offstageLoader = false;

    if (response is UserHireListResponse) {


      if (response?.data != null && response?.data?.data?.length > 0) {
        list.addAll(response?.data?.data);
      } else {
        offstageApplicant = true;
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

  hitUserHire(String id, int pos) async {
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

    var response = await provider.userHire(
        favoriteResponse?.data?.id?.toString(), id, context);

    offstageLoader = false;

    if (response is UserHireListResponse) {
      if (response != null && response.status.code == 200) {
        widget?.voidcallback(1);
        showBottomSheet();

        //    list.removeAt(pos);

      }

      if (response?.data != null && response?.data?.data?.length > 0) {
        list.addAll(response?.data?.data);
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

  @override
  bool get wantKeepAlive => true;

  void callback() async {
    Navigator.pop(context);

    print("cc");
/*
    await Future.delayed(Duration(milliseconds: 200));
    showInSnackBar("Favour applied successfully");
    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context); //back to previous screen
    // showBottomSheet();*/
  }

  void callbackAllow() async {
    Navigator.pop(context);

    hitUserHire(hireUserid, pos);
  }

  void callbackFavourPage() async {
    Navigator.pop(context);
    Navigator.pop(context);
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
                    favoriteResponse?.data?.title ?? "",
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
                        favoriteResponse?.data?.location ?? "",
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
                "€${favoriteResponse?.data?.price ?? ""}",
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
        return Material(
            child: new PostFavour(
          favourDetailsResponse: favoriteResponse,
          isEdit: true,
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
                  Container(
                      margin: new EdgeInsets.only(top: 35, left: 27),
                      child:
                          getBottomText(AssetStrings.slash, "Report Post", 22)),
                  isCurrentUser
                      ? Container(
                          margin: new EdgeInsets.only(top: 35, left: 27),
                          child:
                              getBottomText(AssetStrings.edit, "Edit Post", 22))
                      : Container(),
                  isCurrentUser
                      ? Container(
                          margin: new EdgeInsets.only(top: 35, left: 27),
                          child: getBottomText(
                              AssetStrings.delete, "Delete Post", 22))
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
        isDismissible: false,
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
                          //_showPopupMenu(details.globalPosition);
                          //showBottomSheet();
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
                    child: new Text(
                      "Successful!",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 10),
                    child: new Text(
                      "Your Hiring Process is successfully completed!",
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
                        callbackFavourPage, "Go to Contract Page", 0,
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
                } else {
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

  void _share() async {
    Share.share('check out this post https://google.com');
  }

  void showBottomSheetHire(String id, int posi) {
    hireUserid = id;
    pos = posi;
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
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
              child: Container(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                children: [
                  new Container(
                    margin: new EdgeInsets.only(top: 50),
                    child: new Text(
                      "Are you sure to Hire?",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 7, left: 35, right: 35),
                    child: new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        text:
                            "Once you have allocated the favor you are agreeing to pay the person on completion of the task respecting our",
                        style: new TextStyle(
                          fontFamily: AssetStrings.circulerNormal,
                          fontSize: 16,
                          height: 1.5,
                          color: Color.fromRGBO(114, 117, 112, 1),
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: "Terms of Use.",
                              style: new TextStyle(
                                  fontFamily: AssetStrings.circulerNormal,
                                  color: Color.fromRGBO(9, 165, 255, 1))),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: getSetupButtonNew(callbackAllow, "Confirm", 0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 15, left: 16, right: 16),
                    child: getSetupButtonBorderNew(callback, "Cancel", 0,
                        border: Color.fromRGBO(103, 99, 99, 0.25),
                        newColor: Colors.transparent,
                        textColor: Colors.black),
                  ),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }

  void goToUser(String name, String userid, String image) {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
            child: Material(
                child: new ChatMessageDetails(
          id: "",
          name: name,
          image: image,
          hireduserId: userid,
        )));
      }),
    );
  }

  Widget buildItemNew(DatasUser user, int pos) {
    var type = false;
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () {
              goToUser(user?.user?.profilePic, user?.user?.id?.toString(),
                  user?.user?.name);
            },
            child: new Container(
              width: 40.0,
              height: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

                child: getCachedNetworkImageWithurl(
                    url: user?.user?.profilePic ?? "",
                    fit: BoxFit.fill,
                    size: 40),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                goToUser(user?.user?.profilePic, user?.user?.id?.toString(),
                    user?.user?.name);
              },
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Text(
                      user?.user?.name ?? "",
                      style: TextThemes.greyTextFielMedium,
                    ),
                  ),
                  Container(
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                    child: Row(
                      children: [
                        new Image.asset(
                          AssetStrings.rating,
                          width: 13,
                          height: 13,
                        ),
                        new SizedBox(
                          width: 3,
                        ),
                        Container(
                            child: new Text(
                          user?.user?.ratingAvg.toString() ?? "",
                          style: TextThemes.greyTextFieldNormal,
                        )),
                        Container(
                          width: 5,
                          height: 5,
                          margin: new EdgeInsets.only(left: 4, right: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkgrey,
                          ),
                        ),
                        Container(
                            child: new Text(
                          "${user?.user?.ratingCount.toString() ?? "0"} Reviews",
                          style: TextThemes.greyTextFieldNormal,
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  var currentUserId;
                  var _userName;
                  var _userProfilePic;
                  var userData = MemoryManagement.getUserInfo();
                  if (userData != null) {
                    Map<String, dynamic> data = jsonDecode(userData);
                    LoginSignupResponse userResponse =
                        LoginSignupResponse.fromJson(data);
                    _userName = userResponse.user.name ?? "";
                    _userProfilePic = userResponse.user.profilePic ?? "";
                    currentUserId = userResponse.user.id.toString();
                  }
                  var screen = PrivateChat(
                    peerId: user?.userId?.toString() ?? "",
                    peerAvatar: user?.user?.profilePic?.toString() ?? "",
                    userName: user?.user?.name?.toString() ?? "",
                    isGroup: false,
                    currentUserId: currentUserId,
                    currentUserName: _userName,
                    currentUserProfilePic: _userProfilePic,
                  );
                  //move to private chat screen
                  //widget.fullScreenWidget(screen);

                  Navigator.push(
                    context,
                    new CupertinoPageRoute(builder: (BuildContext context) {
                      return Material(child: screen);
                    }),
                  );
                },
                child: Container(
                  width: 65,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(12.0),
                      border: new Border.all(
                          color: Color.fromRGBO(103, 99, 99, 0.19)),
                      color: Color.fromRGBO(248, 248, 250, 1.0)),
                  child: new Text(
                    "Chat",
                    style: new TextStyle(
                      color: Colors.black,
                      fontFamily: AssetStrings.circulerNormal,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
          new SizedBox(
            width: 4,
          ),
          Align(
              alignment: Alignment.center,
              child: type == false
                  ? InkWell(
                      onTap: () {
                        showBottomSheetHire(user?.userId?.toString(), pos);
                      },
                      child: Container(
                        width: 65,
                        height: 25,
                        alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(12.0),
                            color: AppColors.colorDarkCyan),
                        child: new Text(
                          "Hire",
                          style: new TextStyle(
                            color: Colors.white,
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {

                      },
                      child: Container(
                        width: 65,
                        height: 25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: new BorderRadius.circular(12.0),
                            color: AppColors.lightReferred),
                        child: new Text(
                          "Hired",
                          style: new TextStyle(
                            color: AppColors.colorCyanPrimary,
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
        ],
      ),
    );
  }

  _buildContestList() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        /*  isPullToRefresh = true;
        _loadMore = false;
        currentPage = 1;

        await hitSearchApi(title);*/
      },
      child: Container(
        color: Colors.white,
        padding: new EdgeInsets.only(top: 10),
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemMain(list[index], index);
          },
          itemCount: list?.length,
        ),
      ),
    );
  }

  Widget buildItemMain(DatasUser user, int pos) {
    return Container(
      child: Column(
        children: <Widget>[
          new SizedBox(
            height: 12.0,
          ),
          buildItemNew(user, pos),
          Opacity(
            opacity: 0.3,
            child: new Container(
              height: 0.5,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
              color: AppColors.dividerColor,
            ),
          ),
        ],
      ),
    );
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
                              url: favoriteResponse?.data?.image,
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
                        Opacity(
                          opacity: 0.12,
                          child: new Container(
                            height: 1.0,
                            padding: new EdgeInsets.only(top: 14),
                            margin:
                                new EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            widget.lauchCallBack(Material(
                                child: Material(
                                    child: new PostFavorDetails(
                              id: widget.id,
                            ))));
                          },
                          child: new Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: new EdgeInsets.only(top: 18.0, bottom: 17),
                            color: Colors.white,
                            child: new Text(
                              "View Original Post",
                              style: TextThemes.blueTextFieldMedium,
                            ),
                          ),
                        ),
                        Container(
                            color: Colors.white,
                            margin: new EdgeInsets.only(top: 6),
                            padding: new EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 16.0),
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              "All Applicants",
                              style: TextThemes.blackCirculerMediumHeight,
                            )),
                        _buildContestList(),
                        new SizedBox(
                          height: 10,
                        ),
                        Offstage(
                          offstage: !offstageApplicant,
                          child: new Container(
                            alignment: Alignment.center,
                            margin: new EdgeInsets.only(top: 80),
                            child: new Text(
                              "No Applicant Found",
                              style: new TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
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
                          padding: new EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.greyProfile.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.45),
                                  blurRadius: .4,
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
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: .4,
                              ),
                            ]),
                        child: GestureDetector(
                            onTapDown: (TapDownDetails details) {
                              showBottomSheets();
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
