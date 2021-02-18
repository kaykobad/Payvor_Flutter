import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/notifications/notification_response.dart';
import 'package:payvor/pages/original_post/original_post_data.dart';
import 'package:payvor/pages/pay_feedback/pay_feedback_common.dart';
import 'package:payvor/pages/pay_feedback/pay_give_feedback.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:provider/provider.dart';
class Notifications extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Notifications>
    with AutomaticKeepAliveClientMixin<Notifications> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  FirebaseProvider providerFirebase;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

  List<Data> listResult = List();

  TextEditingController _controller = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  bool _loadMore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitSearchApi();
    });
    _setScrollListener();
    super.initState();
  }

  hitSearchApi() async {
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

    var response = await provider.getNotificationList(context, currentPage);

    if (response is NotificationResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          listResult.clear();
        }

        listResult.addAll(response?.data);

        if (response != null &&
            response.data != null &&
            response.data?.length < Constants.PAGINATION_SIZE) {
          _loadMore = false;
        } else {
          _loadMore = true;
        }

        if (listResult.length > 0) {
          offstagenodata = true;
        } else {
          offstagenodata = false;
        }

        setState(() {});
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

  void _setScrollListener() {
    //scrollController.position.isScrollingNotifier.addListener(() { print("called");});

    scrollController = new ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (listResult.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitSearchApi();
          showInSnackBar("Loading data...");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery
        .of(context)
        .size;
    provider = Provider.of<AuthProvider>(context);
    providerFirebase = Provider.of<FirebaseProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: Colors.white,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    InkWell(
                      onTap: () {},
                      child: new SvgPicture.asset(
                        AssetStrings.notification,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 42),
                      child: new Text(
                        "No Notifications",
                        style: new TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 9, left: 20, right: 20),
                      child: new Text(
                        "You didn’t recieve any notifications yet",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            color: Color.fromRGBO(103, 99, 99, 1.0),
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 15.0),
                      ),
                    ),
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

        await hitSearchApi();
      },
      child: Container(
        color: AppColors.whiteGray,
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemMain(listResult[index]);
          },
          itemCount: listResult.length,
        ),
      ),
    ));
  }

  Widget buildItem(Data data) {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 14),
      child: Row(
        children: <Widget>[
          new Container(
            width: 49.0,
            height: 49.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

              child: getCachedNetworkImageWithurl(
                  url: data?.user?.profilePic ?? "",
                  fit: BoxFit.fill,
                  size: 49),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                data?.type != 4
                    ? Container(
                        margin: new EdgeInsets.only(left: 14.0),
                        child: new RichText(
                          text: new TextSpan(
                            text: data?.user?.name ?? "",
                            style: new TextStyle(
                                fontSize: 16.0,
                                fontFamily: AssetStrings.circulerBoldStyle,
                                color: Color.fromRGBO(23, 23, 23, 1)),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: " ${data?.description ?? ""}",
                                  style: new TextStyle(
                                      fontFamily: AssetStrings.circulerNormal,
                                      color: Color.fromRGBO(103, 99, 99, 1))),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(left: 14),
                        alignment: Alignment.centerLeft,
                        child: Html(
                            shrinkToFit: true, data: "${data?.description}")),
                Container(
                  margin: new EdgeInsets.only(left: 14.0),
                  child: new Text("\"${data?.favour?.title ?? ""}\" ",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerNormal,
                          color: Color.fromRGBO(255, 107, 102, 1))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(Data data) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          InkWell(
              onTap: () {
                print("called ${data.type}");

                if (data?.type == 1) {
                  //"hire to u
                  providerFirebase?.changeScreen(new PayFeebackDetailsCommon(
                    postId: data?.favourId.toString(),
                    userId: data?.userId.toString(),
                    type: 1,
                    status: 1,
                    voidcallback: null,
                    lauchCallBack: null,
                  ));
                } else if (data?.type == 2) {
                  // hire and paid favor

                  providerFirebase?.changeScreen(new PayFeebackDetails(
                    postId: data?.favourId.toString(),
                    userId: data?.userId.toString(),
                    type: 1,
                    voidcallback: null,
                    lauchCallBack: null,
                  ));
                } else if (data?.type == 3) {
                  // for rated user
                  providerFirebase?.changeScreen(Material(
                      child: new ReviewPost(
                    id: data.favourId.toString() ?? "",
                  )));
                } else if (data?.type == 4) {
                  // for applied user

                  providerFirebase?.changeScreen(Material(
                      child: new OriginalPostData(
                    id: data.favourId.toString(),
                  )));
                } else {
                  _redirectToFavourDetailScreen(data.favourId);
                }
              },
              child: buildItem(data)),
          Opacity(
            opacity: 1,
            child: new Container(
              height: 1,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 14.0),
              color: Color.fromRGBO(151, 151, 151, 0.2),
            ),
          ),
        ],
      ),
    );
  }

  void _redirectToFavourDetailScreen(int favourId) {

    providerFirebase?.changeScreen(new PostFavorDetails(
      id: favourId.toString(),
    ));
  }
}
