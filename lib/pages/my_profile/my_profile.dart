import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/chat/decorator_view.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/update_profile/user_hired_favor_response.dart';
import 'package:payvor/pages/add_payment_method_first/add_payment.dart';
import 'package:payvor/pages/my_profile/ended_favor.dart';
import 'package:payvor/pages/my_profile/ended_jobs.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/settings/settings.dart';
import 'package:payvor/pages/verify_profile.dart';
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
      hitUserApi();
    });
    //  _setScrollListener();
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    super.initState();
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
      var infoData = jsonDecode(MemoryManagement.getUserInfo());
      var userinfo = LoginSignupResponse.fromJson(infoData);
      MemoryManagement.setPushStatus(
          token: userinfo?.user?.disable_push?.toString() ?? "0");

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


  @override
  bool get wantKeepAlive => true;

  void callback() async {

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
                                  userResponse?.user?.ratingAvg?.toString() ??
                                      "",
                                  style: TextThemes.blackTextSmallMedium,
                                )),
                                Container(
                                  width: 3,
                                  height: 3,
                                  margin:
                                      new EdgeInsets.only(left: 5, right: 5),
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
                                    "${userResponse?.user?.ratingCount?.toString() ?? "0"} Reviews",
                                    style: TextThemes.blueMediumSmall,
                                  )),
                                ),
                              ],
                            ),
                          ),

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
                          InkWell(
                            onTap: () {
                              providerFirebase?.changeScreen(
                                  Material(child: new VerificationProfiles()));
                            },
                            child: Container(
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: new Text(
                                "VERIFY YOUR PROFILE",
                                style: new TextStyle(
                                    color: AppColors.redLight,
                                    fontSize: 14,
                                    fontFamily: AssetStrings.circulerNormal),
                              ),
                            ),
                          ),

                          //  buildItem(1, "Verify Profile and Get badge"),
                          //  buildItem(2, "Payment Methods"),
                          //  buildItem(3, "Verify Profile and Get badge"),
                          new Container(
                            height: 16,
                            color: Colors.white,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: new EdgeInsets.only(
                                left: 16, right: 16, top: 16, bottom: 16),
                            child: new Text(
                              "History",
                              style: new TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: AssetStrings.circulerNormal),
                            ),
                          ),
                          Material(
                            child: Container(
                              decoration:
                                  new BoxDecoration(color: Colors.white),
                              padding: new EdgeInsets.only(top: 6.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      width: screenSize.width,
                                      padding: new EdgeInsets.only(right: 16),
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
                                                fontFamily: AssetStrings
                                                    .circulerMedium),
                                            indicatorWeight: 3,
                                            indicatorSize:
                                                TabBarIndicatorSize.tab,
                                            isScrollable: false,
                                            unselectedLabelStyle: new TextStyle(
                                                fontSize: 18,
                                                fontFamily: AssetStrings
                                                    .circulerMedium),
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
                                new MyEndedFavor(
                                  hireduserId: widget.hireduserId,
                                  name: widget.name,
                                ),
                                new MyEndedJobs(
                                  hireduserId: widget.hireduserId,
                                  name: widget.name,
                                )
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
                            child: InkWell(
                                onTap: () {
                                  //  Navigator.pop(context);
                                },
                                child: new Text(
                                  /*    "${userResponse?.user?.perc?.toString() ?? "0"}% Verified"*/
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
                )),

            /* new Center(
              child: _getLoader,
            ),*/
          ],
        ),
      ),
    );
  }
}
