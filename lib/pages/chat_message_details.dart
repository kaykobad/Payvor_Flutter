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
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/shimmers/shimmer_details.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

import 'chat/payvor_firebase_user.dart';
import 'chat/private_chat.dart';

class ChatMessageDetails extends StatefulWidget {
  final String id;
  final String name;

  ChatMessageDetails({this.id, this.name});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ChatMessageDetails>
    with AutomaticKeepAliveClientMixin<ChatMessageDetails> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  List<String> listOption = ["Report", "Share"];

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

      var currentUserId ;
      var _userName;
      var _userProfilePic;
      var userData = MemoryManagement.getUserInfo();
      if (userData != null) {
        Map<String, dynamic> data = jsonDecode(userData);
        LoginSignupResponse userResponse = LoginSignupResponse.fromJson(data);
        _userName = userResponse.user.name ?? "";
        _userProfilePic = userResponse.user.profilePic ?? "";
        currentUserId=userResponse.user.id.toString();
      }
      var screen = PrivateChat(
        peerId: widget.id,
        peerAvatar: "",
        userName: widget.name,
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
          return Material(child:screen);
        }),
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
        child: Expanded(
          child: new ListView.builder(
            padding: new EdgeInsets.all(0.0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return buildItemMain();
            },
            itemCount: 8,
          ),
        ),
      ),
    );
  }

  Widget buildItemMain() {
    return Container(
      child: Column(
        children: <Widget>[
          buildItemNew(),
        ],
      ),
    );
  }

  Widget buildItemSecondNew() {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          new Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(shape: BoxShape.circle),
            alignment: Alignment.center,
            child: ClipOval(
              // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

              child: getCachedNetworkImageWithurl(
                  url: "", fit: BoxFit.fill, size: 40),
            ),
          ),
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      children: [
                        new Text(
                          "User Name",
                          style: TextThemes.blackCirculerMedium,
                        ),
                        new SizedBox(
                          width: 8,
                        ),
                        new Image.asset(
                          AssetStrings.verify,
                          width: 16,
                          height: 16,
                        ),
                      ],
                    )),
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
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
                      Expanded(
                          child: new Text(
                        "Mohali",
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
                "€5",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }

  Widget buildItemNew() {
    return InkWell(
      onTap: () {},
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            new Container(
              height: 8.0,
              color: AppColors.whiteGray,
            ),
            new SizedBox(
              height: 16.0,
            ),
            buildItemSecondNew(),
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),
            new Container(
              height: 147,
              width: double.infinity,
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
              child: ClipRRect(
                // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                borderRadius: new BorderRadius.circular(10.0),

                child: getCachedNetworkImageRect(
                  url: "",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
                width: double.infinity,
                color: Colors.white,
                margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
                alignment: Alignment.centerLeft,
                child: new Text(
                  "This is your title",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              width: double.infinity,
              color: Colors.white,
              child: ReadMoreText(
                "pkpkaskfpkasp[fkaskfp[ksafpkaf'psksahiuhhkihihihoihiohgioghiogiuguiguiguiguiguiguiguiguiguiguighiohiohiohiohohiohoihiohiohiohoihiohiohiohiohohihihhkhhbjbhvvvkfkaspfk;sakf;ksaf'ksa'fk'saksak;fm;slamc;malcmxzlml;zmcl;mxz;kugiugukgukjhvhhgfyfjgjgjgjbjhgjgjbkjbjkgjgjgjgjmc;xzlmc;zxlmc;lmzx;cm;m",
                trimLines: 4,
                colorClickableText: AppColors.colorDarkCyan,
                trimMode: TrimMode.Line,
                style: new TextStyle(
                  color: AppColors.moreText,
                  fontFamily: AssetStrings.circulerNormal,
                  fontSize: 14.0,
                ),
                trimCollapsedText: '...more',
                textAlign: TextAlign.start,
                trimExpandedText: ' less',
              ),
            ),
            new SizedBox(
              height: 15.0,
            )
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
                        Stack(
                          children: [
                            new Container(
                              height: 165,
                              color: Colors.white,
                            ),
                            new Container(
                              height: 120,
                              color: AppColors.kPrimaryBlue,
                            ),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: new Border.all(
                                        width: 2, color: Colors.white)),
                                child: new Container(
                                  height: 89,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                                    borderRadius:
                                        new BorderRadius.circular(0.0),

                                    child: getCachedNetworkImageWithurl(
                                      url: "",
                                      size: 89,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: new EdgeInsets.only(top: 6),
                          margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  child: new Text(
                                "Jonathan Doree",
                                style: TextThemes.darkBlackMedium,
                              )),
                              new SizedBox(
                                width: 2,
                              ),
                              Container(
                                child: Image.asset(AssetStrings.verify),
                                width: 20,
                                height: 20,
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: new EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new SvgPicture.asset(
                                AssetStrings.star,
                              ),
                              new SizedBox(
                                width: 4,
                              ),
                              Container(
                                  child: new Text(
                                "5.0",
                                style: TextThemes.blackTextSmallMedium,
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
                                "12 Reviews",
                                style: TextThemes.blueMediumSmall,
                              )),
                            ],
                          ),
                        ),
                        Material(
                          elevation: 0.0,
                          child: Container(
                              color: Colors.white,
                              padding: new EdgeInsets.only(top: 20, bottom: 10),
                              child: getSetupButtonNewRow(
                                  callback, "Message", 16,
                                  newColor: AppColors.colorDarkCyan)),
                        ),
                        Container(
                            margin: new EdgeInsets.only(
                                left: 16, right: 16, top: 22, bottom: 10),
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              "All Posts",
                              style: TextThemes.blackCirculerMediumHeight,
                            )),
                        _buildContestList(),
                        new SizedBox(
                          height: 10,
                        )
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
                          padding: new EdgeInsets.all(8),
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
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                            onTapDown: (TapDownDetails details) {},
                            child: new Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
              )),
          /*favoriteResponse ==null
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
                      callback, ResString().get('apply_for_fav'), 16,
                      newColor: AppColors.colorDarkCyan)),
            ),
          )
              : Container(),*/

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
