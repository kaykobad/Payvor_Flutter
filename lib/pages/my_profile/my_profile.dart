import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/chat/decorator_view.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_details/report_request.dart';
import 'package:payvor/model/update_profile/user_hired_favor_response.dart';
import 'package:payvor/pages/add_payment_method_first/add_payment.dart';
import 'package:payvor/pages/my_profile/ended_favor.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/pages/settings/settings.dart';
import 'package:payvor/pages/verify_profile.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  final String id;
  String name;
  final String hireduserId;
  String image;
  final bool userButtonMsg;

  MyProfile(
      {this.id, this.name, this.hireduserId, this.image, this.userButtonMsg});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyProfile>
    with AutomaticKeepAliveClientMixin<MyProfile>, TickerProviderStateMixin {
  var screenSize;
  TabController tabBarController;
  int _tabIndex = 0;
  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  List<String> listOption = ["Report", "Share"];

  AuthProvider provider;
  FirebaseProvider providerFirebase;

  var ids = "";
  int currentPage = 1;
  bool _loadMore = false;

  ScrollController _scrollController = new ScrollController();
  var isCurrentUser = false;

  bool offstageLoader = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _DescriptionField = new FocusNode();

  FavourDetailsResponse favoriteResponse;
  bool isPullToRefresh = false;
  bool offstagenodata = true;

  UserProfileFavorResponse userResponse = null;
  List<DataUserFavour> list = List<DataUserFavour>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    tabBarController =
        new TabController(initialIndex: _tabIndex, length: 2, vsync: this);

    Future.delayed(const Duration(milliseconds: 300), () {
      //   hitUserApi();
    });
    //  _setScrollListener();
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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

    var response =
        await provider.getFavorPostDetails(context, widget.hireduserId);

    if (response is FavourDetailsResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        favoriteResponse = response;

        var userid = favoriteResponse?.data?.userId.toString();

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

  hitUserApi() async {
    if (!isPullToRefresh) {
      provider.setLoading();
    }
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

    if (_loadMore) {
      currentPage++;
    } else {
      currentPage = 1;
    }

    var response = await provider.userProfileDetails(
        context, currentPage, widget?.hireduserId);

    if (response is UserProfileFavorResponse) {
      isPullToRefresh = false;
      if (response != null && response.data != null) {
        if (currentPage == 1) {
          list.clear();
        }

        userResponse = response;
        print("user_data ${userResponse.user.toJson()}");
        widget.image = response.user.profilePic;
        widget.name = response.user.name;

        list.addAll(response.data.data);

        if (response.data != null &&
            response.data.data.length < Constants.PAGINATION_SIZE) {
          _loadMore = false;
        } else {
          _loadMore = true;
        }

        if (list.length > 0) {
          offstagenodata = true;
        } else {
          offstagenodata = false;
        }
        setState(() {});
      }
    } else {
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
    provider.hideLoader();
  }

  void _setScrollListener() {
    //crollController.position.isScrollingNotifier.addListener(() { print("called");});

    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        print("size ${list.length}");

        if (list.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitUserApi();
          showInSnackBar("Loading data...");
        } else {
          print("not called");
        }
      }
    });
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
    /*   var currentUserId ;
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
        peerId: widget.hireduserId,
        peerAvatar: widget.image,
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
      );*/
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
    return
        /* key: _refreshIndicatorKey,
      onRefresh: () async {
          isPullToRefresh = true;
        _loadMore = false;
        currentPage = 1;

        await hitUserApi();*/

        Container(
      color: Colors.white,
      child: new ListView.builder(
        padding: new EdgeInsets.all(0.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildItemNew(list[index]);
        },
        itemCount: list?.length,
      ),
    );
  }

  Widget buildItemSecondNew(DataUserFavour datas) {
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
                  url: userResponse?.user?.profilePic ?? "",
                  fit: BoxFit.fill,
                  size: 40),
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
                          "[po[o[o[",
                          style: TextThemes.blackCirculerMedium,
                        ),
                        new SizedBox(
                          width: 8,
                        ),
                        datas?.isActive == 1
                            ? new Image.asset(
                                AssetStrings.verify,
                                width: 16,
                                height: 16,
                              )
                            : Container(),
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
                        userResponse?.user?.location ?? "",
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
                "€${datas?.price ?? "0"}",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }

  Widget buildItemNew(DataUserFavour datas) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
                child: new PostFavorDetails(
              id: datas?.id?.toString(),
              isButtonDesabled: true,
            ));
          }),
        );
      },
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
            buildItemSecondNew(datas),
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),
            datas?.image != null
                ? new Container(
                    height: 147,
                    width: double.infinity,
                    margin:
                        new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
                    child: ClipRRect(
                      // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                      borderRadius: new BorderRadius.circular(10.0),

                      child: getCachedNetworkImageRect(
                        url: "kk[pkp[kp[kp",
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(),
            Container(
                width: double.infinity,
                color: Colors.white,
                margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
                alignment: Alignment.centerLeft,
                child: new Text(
                  "pjpojpojpojpojpojpojop",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              width: double.infinity,
              color: Colors.white,
              child: ReadMoreText(
                "iuuiiooioiuoiuio",
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

  Widget buildItem(int index, String data) {
    return InkWell(
      onTap: () {
        if (index == 1) {
          providerFirebase?.changeScreen(Material(child: new VerifyProfile()));
        } else if (index == 2) {
          providerFirebase
              ?.changeScreen(Material(child: new AddPaymentMethodFirst()));
        } else {
          providerFirebase?.changeScreen(Material(
              child: new ReviewPost(
            id: widget?.hireduserId?.toString() ?? "",
          )));
        }
        /*Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
                child: new PostFavorDetails(
                  id: data?.favourId?.toString(),
                  isButtonDesabled: true,
                ));
          }),
        );*/
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16, right: 16),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(top: 16),
                color: AppColors.dividerColor,
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 16.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: new Text(
                        data,
                        style: TextThemes.blackCirculerMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(left: 7.0),
                    child: new Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Color.fromRGBO(183, 183, 183, 1),
                    ),
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
    providerFirebase = Provider.of<FirebaseProvider>(context);
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: userResponse == null
                ? SingleChildScrollView(
                    controller: _scrollController,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
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
                              width: getScreenSize(context: context).width,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: new Border.all(
                                        width: 2, color: Colors.white)),
                                child: ClipOval(
                                  // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

                                  child: getCachedNetworkImageWithurl(
                                    url: "pujpjpojojj",
                                    size: 89,
                                    fit: BoxFit.cover,
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
                                "aviiiiiii",
                                style: TextThemes.darkBlackMedium,
                              )),
                              new SizedBox(
                                width: 2,
                              ),
                              userResponse?.user?.isActive == 1
                                  ? Container(
                                      child: Image.asset(AssetStrings.verify),
                                      width: 20,
                                      height: 20,
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: new EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new Image.asset(
                                AssetStrings.rating,
                                width: 13,
                                height: 13,
                              ),
                              new SizedBox(
                                width: 4,
                              ),
                              Container(
                                  child: new Text(
                                "4",
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
                              InkWell(
                                onTap: () {
                                  providerFirebase?.changeScreen(Material(
                                      child: new ReviewPost(
                                    id: widget?.hireduserId?.toString() ?? "",
                                  )));
                                },
                                child: Container(
                                    child: new Text(
                                  "${userResponse?.user?.ratingCount?.toString() ?? "4"} Reviews",
                                  style: TextThemes.blueMediumSmall,
                                )),
                              ),
                            ],
                          ),
                        ),
                        buildItem(1, "Verify Profile and Get badge"),
                        buildItem(2, "Payment Methods"),
                        buildItem(3, "Verify Profile and Get badge"),
                        new Container(
                          height: 20,
                          color: Colors.white,
                        ),
                        Material(
                          child: Container(
                            decoration: new BoxDecoration(color: Colors.white),
                            padding: new EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: screenSize.width,
                                    height: 40.0,
                                    child: DecoratedTabBar(
                                      decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                width: 0.0,
                                                color: Color.fromRGBO(
                                                    151, 151, 151, 0.2)),
                                          ),
                                          color: Colors.transparent),
                                      tabBar: new TabBar(
                                          indicatorColor:
                                              Color.fromRGBO(37, 26, 101, 1),
                                          labelStyle: new TextStyle(
                                              fontSize: 18,
                                              fontFamily:
                                                  AssetStrings.circulerMedium),
                                          indicatorWeight: 3,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          isScrollable: false,
                                          unselectedLabelStyle: new TextStyle(
                                              fontSize: 18,
                                              fontFamily:
                                                  AssetStrings.circulerMedium),
                                          unselectedLabelColor:
                                              Color.fromRGBO(103, 99, 99, 1),
                                          labelColor:
                                              Color.fromRGBO(37, 26, 101, 1),
                                          labelPadding:
                                              new EdgeInsets.only(left: 15.0),
                                          indicatorPadding:
                                              new EdgeInsets.only(left: 15.0),
                                          controller: tabBarController,
                                          tabs: <Widget>[
                                            new Tab(text: "Ended Favors"),
                                            new Tab(
                                              text: "Ended Jobs",
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: screenSize.height / 2.1,
                          child: new TabBarView(
                            controller: tabBarController,
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              new MyEndedFavor(),
                              new MyEndedFavor()
                            ],
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
                  top: 35,
                  left: 16,
                  right: 16,
                ),
                child: new Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Container(
                          padding: new EdgeInsets.only(
                              top: 9, bottom: 9, left: 14, right: 14),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(49, 34, 139, 1.0),
                              borderRadius: new BorderRadius.circular(17)),
                          child: InkWell(
                              onTap: () {
                                //  Navigator.pop(context);
                              },
                              child: new Text(
                                "50% Verified",
                                style: new TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontFamily: AssetStrings.circulerMedium),
                              )),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          providerFirebase
                              ?.changeScreen(Material(child: new Settings()));
                        },
                        child: Container(
                            child: new Image.asset(AssetStrings.appSettings,
                                width: 26, height: 26)),
                      )
                    ],
                  ),
                ),
              )),
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
