import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/my_profile_job_hire/my_profile_job_hire_response.dart';
import 'package:payvor/pages/my_profile_details/my_profile_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MyEndedFavor extends StatefulWidget {
  final String hireduserId;
  final String name;

  MyEndedFavor({this.hireduserId, this.name});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyEndedFavor>
    with AutomaticKeepAliveClientMixin<MyEndedFavor> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";
  FirebaseProvider providerFirebase;

  List<Object> listResult = List();

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  TextEditingController _controller = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  bool _loadMore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Widget widgets;

  String username = "";
  String profilepic = "";
  int percent = 0;
  String location = "";

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitJobsPost();
    });

    _setScrollListener();
    super.initState();
  }

  hitJobsPost() async {
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

    if (!isPullToRefresh) {
      provider.setLoading();
    }

    if (_loadMore) {
      currentPage++;
    } else {
      currentPage = 1;
    }

    var response = await provider.myprofileendedFavors(
        context, currentPage, widget.hireduserId);

    provider.hideLoader();

    if (response is EndedJobHireResponse) {
      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          listResult.clear();
        }

        listResult.addAll(response?.data);

        if (response != null &&
            response.data != null &&
            response?.data.length < Constants.PAGINATION_SIZE) {
          _loadMore = false;
        } else {
          _loadMore = true;
        }

        if (listResult?.length > 0) {
          offstagenodata = true;
        } else {
          offstagenodata = false;
        }

        setState(() {});
      }

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      //  showInSnackBar(apiError.error);
    }
  }

  void _setScrollListener() {
    //scrollController.position.isScrollingNotifier.addListener(() { print("called");});

    scrollController = new ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (listResult.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitJobsPost();
          showInSnackBar("Loading data...");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    providerFirebase = Provider.of<FirebaseProvider>(context);

    return VisibilityDetector(
      key: Key('my-widget-key_favor'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;

        var infoData = jsonDecode(MemoryManagement.getUserInfo());
        var userinfo = LoginSignupResponse.fromJson(infoData);

        username = userinfo?.user?.name ?? "";
        profilepic = userinfo?.user?.profilePic ?? "";
        location = userinfo?.user?.location ?? "";
        percent = userinfo?.user?.perc ?? 0;

        setState(() {});
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.whiteGray,
        body: Stack(
          children: <Widget>[
            new Container(
              color: AppColors.whiteGray,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    height: 2,
                    color: Colors.white,
                  ),
                  _buildContestList(),
                ],
              ),
            ),
            Offstage(
              offstage: offstagenodata,
              child: Container(
                height: screenSize.height,
                padding: new EdgeInsets.only(bottom: 40),
                child: new Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /* InkWell(
                        onTap: () {},
                        child: new SvgPicture.asset(
                          AssetStrings.nopostnojob,
                        ),
                      ),*/
                      Container(
                        child: new Text(
                          "No Favors Found",
                          style: new TextStyle(
                              color: Colors.black,
                              fontFamily: AssetStrings.circulerMedium,
                              fontSize: 17.0),
                        ),
                      ),
                      /* Container(
                        margin: new EdgeInsets.only(top: 9, left: 20, right: 20),
                        child: new Text(
                          "You don???t have any job yet.\nOnce you???re hired it will show up here.",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(103, 99, 99, 1.0),
                              fontFamily: AssetStrings.circulerNormal,
                              fontSize: 15.0),
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
            ),
            Container(
              child: new Center(
                child: getHalfScreenLoader(
                  status: provider.getLoading(),
                  context: context,
                ),
              ),
            ),
            /* new Center(
              child: _getLoader,
            ),*/
          ],
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
                  url: profilepic ?? "", fit: BoxFit.cover, size: 40),
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
                          username ?? "",
                          style: TextThemes.blackCirculerMedium,
                        ),
                        new SizedBox(
                          width: 8,
                        ),
                        percent == 100
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
                            location ?? "",
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
                "???${data?.price ?? "0"}",
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
          postId: data?.id?.toString(),
          type: 1,
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

  _buildContestList() {
    return Expanded(
        child: RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        isPullToRefresh = true;
        _loadMore = false;
        currentPage = 1;

        await hitJobsPost();
      },
      child: Container(
        child: new ListView.builder(
          padding: new EdgeInsets.only(bottom: 70),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemNew(listResult[index]);
            ;
          },
          itemCount: listResult.length,
        ),
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
