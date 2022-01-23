import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/my_profile_job_hire/my_profile_response.dart';
import 'package:payvor/pages/my_profile_details/my_profile_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/pages/settings/settings.dart';
import 'package:payvor/pages/verify_profile_new/verify_profiles_new.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MyProfile extends StatefulWidget {
  final String id;
  String name;
  final String hireduserId;
  String image;
  final bool userButtonMsg;

  MyProfile(
      {Key key,
      this.id,
      this.name,
      this.hireduserId,
      this.image,
      this.userButtonMsg})
      : super(key: key);

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfile>
    with AutomaticKeepAliveClientMixin<MyProfile>, TickerProviderStateMixin {
  var screenSize;
  TabController tabBarController;
  int _tabIndex = 0;

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

  bool isPullToRefresh = false;
  bool offstagenodata = true;

  MyProfileResponse userResponse = null;
  List<Data> list = List<Data>();

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
      hitUserApi();
    });
    _setScrollListener();
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    super.initState();
  }

  tapCallApi()
  {
    _loadMore=false;
    currentPage=1;
    hitUserApi();
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

    if (response is MyProfileResponse) {
      isPullToRefresh = false;
      if (response != null && response.data != null) {
        if (currentPage == 1) {
          list.clear();
          userResponse = response;
          print("user_data ${userResponse.user.toJson()}");
          print("length ${userResponse.data.data.length}");
          widget.image = response.user.profilePic;
          widget.name = response.user.name;
          if (response?.user != null) {
            var infoData = jsonDecode(MemoryManagement.getUserInfo());
            var userinfo = LoginSignupResponse.fromJson(infoData);

            userinfo.user = response?.user;

            MemoryManagement.setPushStatus(
                token: userinfo?.user?.disable_push?.toString() ?? "0");

            if (userinfo.user?.payment_method > 0) {
              MemoryManagement.setPaymentStatus(status: true);
            } else {
              MemoryManagement.setPaymentStatus(status: false);
            }

            MemoryManagement.setUserInfo(userInfo: json.encode(userinfo));
          }
        }


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

      }
    } else {
      APIError apiError = response;
      var infoData = jsonDecode(MemoryManagement.getUserInfo());
      var userinfo = LoginSignupResponse.fromJson(infoData);
      MemoryManagement.setPushStatus(
          token: userinfo?.user?.disable_push?.toString() ?? "0");

      showInSnackBar(apiError.error);
    }

  }



  @override
  bool get wantKeepAlive => true;


  void _setScrollListener() {
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        print("list ${list.length}");
        print("listPage ${Constants.PAGINATION_SIZE * currentPage}");
        if (list.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitUserApi();
          showInSnackBar("Loading data...");
        }
      }
    });
  }

  _buildContestList() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        isPullToRefresh = true;
        _loadMore = false;
        currentPage = 1;

        await hitUserApi();
      },
      child: Container(
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemNew(list[index]);
            ;
          },
          itemCount: list.length,
        ),
      ),
    );
  }

  Widget buildItemSecondNew(Data data) {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          new Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            alignment: Alignment.center,
            child: ClipOval(
              // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

              child: getCachedNetworkImageWithurl(
                  url: userResponse?.user?.profilePic ?? "",
                  fit: BoxFit.cover,
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
                          userResponse?.user?.name ?? "",
                          style: TextThemes.blackCirculerMedium,
                        ),
                        new SizedBox(
                          width: 8,
                        ),
                        userResponse?.user?.perc == 100
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
                "€${data?.price ?? "0"}",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }

  Widget buildItemNew(Data data) {
    return InkWell(
      onTap: () {
        providerFirebase.changeScreen(Material(
            child: new MyProfileDetails(
          type: 2,
          postId: data?.id?.toString(),
        )));
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
            buildItemSecondNew(data),
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),
            data?.image != null
                ? new Container(
                    height: 147,
                    width: double.infinity,
                    margin:
                        new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
                    child: ClipRRect(
                      // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                      borderRadius: new BorderRadius.circular(10.0),

                      child: getCachedNetworkImageRect(
                        url: data?.image ?? "",
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
                  data?.title ?? "",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              width: double.infinity,
              color: Colors.white,
              child: ReadMoreText(
                data?.description ?? "",
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
    providerFirebase = Provider.of<FirebaseProvider>(context);
    screenSize = MediaQuery.of(context).size;

    return VisibilityDetector(
      key: Key('my-widget-key'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (visiblePercentage == 100) {
          var infoData = jsonDecode(MemoryManagement.getUserInfo());
          var userinfo = LoginSignupResponse.fromJson(infoData);

          userResponse?.user?.profilePic = userinfo?.user?.profilePic ?? "";
          userResponse?.user?.name = userinfo?.user?.name ?? "";
          userResponse?.user?.perc = userinfo?.user?.perc ?? 0;
          userResponse?.user?.is_email_verified = userinfo?.user?.perc ?? 1;

          print(userResponse?.user?.profilePic?.toString());

          setState(() {});

          isPullToRefresh = true;
          hitUserApi();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            new Container(
              color: AppColors.whiteGray,
              height: screenSize.height,
              child: userResponse != null
                  ? SingleChildScrollView(
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
                                    child: getCachedNetworkImageWithurl(
                                      url: userResponse?.user?.profilePic ?? "",
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
                            margin:
                                new EdgeInsets.only(left: 10.0, right: 10.0),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    child: new Text(
                                  userResponse?.user?.name ?? "",
                                  style: TextThemes.darkBlackMedium,
                                )),
                                new SizedBox(
                                  width: 2,
                                ),
                                userResponse?.user?.perc == 100
                                    ? Container(
                                        child: Image.asset(AssetStrings.verify),
                                        width: 20,
                                        height: 20,
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          reviewPost,
                          new Container(
                            height: 16,
                            color: Colors.white,
                          ),
                          Opacity(
                            opacity: 0.12,
                            child: new Container(
                              height: 1.0,
                              margin: new EdgeInsets.only(left: 16, right: 16),
                              color: AppColors.dividerColor,
                            ),
                          ),
                          new Container(
                            height: 16,
                            color: Colors.white,
                          ),
                          userResponse?.user?.is_email_verified == 0
                              ? InkWell(
                                  onTap: () {
                                    providerFirebase?.changeScreen(Material(
                                        child: new VerificationProfiles()));
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child: new Text(
                                      "VERIFY YOUR PROFILE",
                                      style: new TextStyle(
                                          color: AppColors.redLight,
                                          fontSize: 14,
                                          fontFamily:
                                              AssetStrings.circulerNormal),
                                    ),
                                  ),
                                )
                              : new Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Image.asset(AssetStrings.verify),
                                        width: 20,
                                        height: 20,
                                      ),
                                      Container(
                                        margin: new EdgeInsets.only(left: 5),
                                        child: new Text(
                                          "PROFILE VERIFIED",
                                          style: new TextStyle(
                                              color: AppColors.colorDarkCyan,
                                              fontSize: 14,
                                              fontFamily:
                                                  AssetStrings.circulerNormal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          new Container(
                            height: 16,
                            color: Colors.white,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: new EdgeInsets.only(
                                left: 16, right: 16, top: 24, bottom: 16),
                            child: new Text(
                              "History",
                              style: new TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: AssetStrings.circulerNormal),
                            ),
                          ),
                          Container(
                            height: screenSize.height / 2.1,
                            child: _buildContestList(),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ),
            profileView,
          ],
        ),
      ),
    );
  }

  get reviewPost => Container(
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
              userResponse?.user?.ratingAvg?.toString() ?? "",
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
                print("review_post from myprofile screen");
                providerFirebase?.changeScreen(Material(
                    child: new ReviewPost(
                  id: widget?.hireduserId?.toString() ?? "",
                )));
              },
              child: Container(
                  child: new Text(
                "${userResponse?.user?.ratingCount?.toString() ?? "0"} Reviews",
                style: TextThemes.blueMediumSmall,
              )),
            ),
          ],
        ),
      );

  get profileView => Positioned(
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
                  child: InkWell(
                      child: new Text(
                    "Profile",
                    style: new TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: AssetStrings.circulerMedium),
                  )),
                ),
              ),
              InkWell(
                onTap: () {
                  providerFirebase?.changeScreen(Material(
                      child: new Settings(
                    id: widget?.hireduserId,
                  )));
                },
                child: Container(
                    child: new Image.asset(AssetStrings.appSettings,
                        width: 26, height: 26)),
              )
            ],
          ),
        ),
      ));
}
