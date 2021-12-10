import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:payvor/current_user_hired_by_favor/current_user_favor_hire.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/favour_posted_by_user.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/original_post/original_post_data.dart';
import 'package:payvor/pages/pay_feedback/pay_feedback_common.dart';
import 'package:payvor/pages/pay_feedback/pay_give_feedback.dart';
import 'package:payvor/pages/post/recent_posted_favor.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class MyPosts extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;

  MyPosts({@required this.lauchCallBack});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyPosts> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  FirebaseProvider providerFirebase;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";
  int myFavorCount = 0;

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

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitPostedApi();
    });

    /* listResult.add("Hired Favors");
    listResult.add(1.0);
    listResult.add(1.0);
    listResult.add("Posted Favors");
    listResult.add(1);
    listResult.add(1);
    listResult.add(1);*/

    _setScrollListener();
    super.initState();
  }

  hitPostedApi() async {
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

    var response = await provider.hiredFavourPost(context, currentPage);
    provider.hideLoader();

    if (response is CurrentUserHiredFavorResponse) {
      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          myFavorCount = response?.myfavour ?? 0;
          listResult.clear();

          if (response?.data?.length > 0) {
            listResult.add("Hired Favors");
          }
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

        //  hitHireJobApi();

        setState(() {});
      }


    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  hitHireJobApi() async {
    var response = await provider.favourpostedbyuser(context, currentPage);

    provider.hideLoader();

    if (response is FavourPostedByUserResponse) {
      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          if (response?.data?.length > 0) {
            listResult.add("Posted Favors");
          }
        }

        listResult.addAll(response?.data);

        if (!_loadMore) {
          if (response != null &&
              response.data != null &&
              response.data?.length < Constants.PAGINATION_SIZE) {
            _loadMore = false;
          } else {
            _loadMore = true;
          }
        }

        if (!offstagenodata) {
          if (listResult.length > 0) {
            offstagenodata = true;
          } else {
            offstagenodata = false;
          }
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
          hitPostedApi();
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.whiteGray,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: getScreenSize(context: context).height,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /* new Container(
                  child: ,
                )*/
                myFavorCount != null && myFavorCount > 0
                    ? buildItemNew()
                    : Container(),
                _buildContestList(),
              ],
            ),
          ),
          Offstage(
            offstage:
                listResult != null && listResult.length > 1 ? true : false,
            child: Container(
              height: screenSize.height,
              padding: new EdgeInsets.only(bottom: 40),
              child: new Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: new Image.asset(
                        AssetStrings.noPosts,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 20),
                      child: new Text(
                        "No Favors",
                        style: new TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 9, left: 20, right: 20),
                      child: new Text(
                        "You haven’t asked for any favors yet.\nOnce you create a favor it will show up here.",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            height: 1.5,
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
                status: provider?.getLoading(),
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

        await hitPostedApi();
      },
      child: Container(
        margin: new EdgeInsets.only(left: 18, right: 18),
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (listResult[index] is String) {
              widgets = buildItemHeader(listResult[index]);
            } else if (listResult[index] is DataNextPost) {
              widgets = buildItemMainNew(listResult[index], index);
            } else if (listResult[index] is DataFavour) {
              widgets = buildItem(listResult[index]);
            }

            return widgets;
          },
          itemCount: listResult.length,
        ),
      ),
    ));
  }

  ValueSetter<int> callback(int type) {
    currentPage = 1;
    isPullToRefresh = true;
    _loadMore = false;
    hitPostedApi();
  }

  Widget buildItem(DataFavour data) {
    return InkWell(
      onTap: () {
        widget.lauchCallBack(Material(
            child: Material(
                child: new OriginalPostData(
          id: data.id.toString(),
          lauchCallBack: widget.lauchCallBack,
          voidcallback: callback,
        ))));
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        margin: new EdgeInsets.only(top: 8.0),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              child: new Text(
                data?.title,
                style: TextThemes.blackCirculerMedium,
              ),
            ),
            Opacity(
              opacity: 0.12,
              child: new Container(
                margin: new EdgeInsets.only(top: 16.0),
                height: 1.0,
                color: AppColors.dividerColor,
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      child: new Text(
                        "${data?.applied_count.toString() ?? "0"} People applied",
                        style: TextThemes.grayNormalSmall,
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

  Widget buildItemNew() {
    return InkWell(
      onTap: () {
        /*  widget.lauchCallBack(Material(
            child: Material(
                child: new OriginalPostData(
                  id: data.id.toString(),
                  lauchCallBack: widget.lauchCallBack,
                  voidcallback: callback,
                ))));*/
      },
      child: InkWell(
        onTap: () {
          widget.lauchCallBack(Material(
              child: Material(
                  child: new RecentPostedFavor(
            lauchCallBack: widget?.lauchCallBack,
          ))));
        },
        child: Container(
          padding:
              new EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
          margin: new EdgeInsets.only(top: 18.0, left: 18, right: 18),
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(5.0),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      child: new Text(
                        "Recent Posted Favors ($myFavorCount)",
                        style: TextThemes.blackCirculerMedium,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 7.0),
                      child: Container(
                        child: new Text(
                          "The favors you haven’t hired people yet",
                          style: TextThemes.grayNormalSmall,
                        ),
                      ),
                    ),
                  ],
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
      ),
    );
  }

  Widget buildItemHeader(String text) {
    return Container(
      padding: new EdgeInsets.only(top: 16, bottom: 2),
      child: Text(text, style: TextThemes.darkBlackMedium),
    );
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

  hitEndedFavours(DataNextPost data) {
    print("clicked_data_status ${data.status}");
    if (data?.status != 3) {
      if (data?.status == 1) {
        providerFirebase.changeScreen(new PayFeebackDetails(
          userId: data?.hiredUserId?.toString(),
          postId: data?.id?.toString(),
          type: 0,
          voidcallback: callback,
          userType: Constants.HELPER,
        ));
      } else {
        providerFirebase.changeScreen(Material(
            child: Material(
                child: new PayFeebackDetailsCommon(
          lauchCallBack: widget?.lauchCallBack,
          userId: data?.hiredUserId?.toString(),
          postId: data?.id?.toString(),
          giveFeedback: false,
          voidcallback: callback,
          userType: Constants.HELPER,
        ))));
      }
    } else {
      providerFirebase.changeScreen(new PayFeebackDetails(
        userId: data?.hiredUserId?.toString(),
        postId: data?.id?.toString(),
        type: 1,
        voidcallback: callback,
        userType: 1,
      ));
    }
    // provider.setLoading();
    //
    // bool gotInternetConnection = await hasInternetConnection(
    //   context: context,
    //   mounted: mounted,
    //   canShowAlert: true,
    //   onFail: () {
    //     provider.hideLoader();
    //   },
    //   onSuccess: () {},
    // );
    //
    // if (!gotInternetConnection) {
    //   return;
    // }
    //
    // var responses = await provider.endedFavours(context, data?.id?.toString());
    //
    // if (responses is GetStripeResponse) {
    //   provider.hideLoader();
    //
    //   //listResult?.remove(data);
    //
    //   widget.lauchCallBack(Material(
    //       child: Material(
    //           child: new PayFeebackDetails(
    //     lauchCallBack: widget?.lauchCallBack,
    //     userId: data?.hiredUserId?.toString(),
    //     postId: data?.id?.toString(),
    //     type: 1,
    //     voidcallback: callback,
    //   ))));
    //
    //   setState(() {});
    // } else {
    //   provider.hideLoader();
    //   APIError apiError = responses;
    //   showInSnackBar(apiError.error);
    // }
  }

  Widget buildItemMainNew(DataNextPost data, int index) {
    print(index);
    return InkWell(
      onTap: () {
        print("data status ${data?.status}");
        if (data?.status != 3) {
          if (data?.status == 1) {
            widget.lauchCallBack(Material(
                child: Material(
                    child: new PayFeebackDetailsCommon(
              lauchCallBack: widget?.lauchCallBack,
              userId: data?.hiredUserId?.toString(),
              postId: data?.id?.toString(),
              giveFeedback: false,
              voidcallback: callback,
              userType: Constants.HELPER,
            ))));
          } else {
            // status=3 favour is ended give feedback now
            widget.lauchCallBack(Material(
                child: Material(
                    child: new PayFeebackDetailsCommon(
              lauchCallBack: widget?.lauchCallBack,
              userId: data?.hiredUserId?.toString(),
              postId: data?.id?.toString(),
              giveFeedback: true,
              voidcallback: callback,
              userType: Constants.HELPER,
            ))));
          }
        } else {
          widget.lauchCallBack(new PayFeebackDetailsCommon(
            lauchCallBack: widget?.lauchCallBack,
            userId: data?.hiredUserId?.toString(),
            postId: data?.id?.toString(),
            giveFeedback: true,
            voidcallback: callback,
            userType: Constants.HELPER,
          ));
        }
      },
      child: Column(
        children: [
          Container(
            padding:
                new EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 0),
            margin: new EdgeInsets.only(top: 8.0),
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(5.0),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    new Container(
                        width: 49.0,
                        height: 49.0,
                        decoration: new BoxDecoration(
                          color: Colors.grey,
                          border:
                              new Border.all(color: Colors.white, width: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: getCachedNetworkImageWithurl(
                              url: data?.image ?? "", size: 49),
                        )),
                    Expanded(
                      child: Container(
                        margin: new EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              child: new Text(
                                data?.title ?? "",
                                style: TextThemes.blackCirculerMedium,
                              ),
                            ),
                            Container(
                              margin: new EdgeInsets.only(top: 10.0),
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: new Text(
                                      data?.status == 3
                                          ? "You’ve ended job of "
                                          : "You have hired ",
                                      style: TextThemes.grayNormalSmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: new EdgeInsets.only(left: 1.0),
                                      child: InkWell(
                                        onTap: () {
                                          widget.lauchCallBack(Material(
                                              child: Material(
                                                  child: new ChatMessageDetails(
                                            id: data.userId.toString(),
                                            name: data.hired.name,
                                            hireduserId:
                                                data?.hiredUserId?.toString(),
                                            image: data?.image,
                                            userButtonMsg: true,
                                          ))));
                                        },
                                        child: new Text(
                                          data?.hired?.name ?? "",
                                          style: TextThemes.cyanTextSmallMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*   Container(
                                    margin: new EdgeInsets.only(left: 7.0),
                                    child: new Icon(
                                      Icons.arrow_forward_ios,
                                      size: 13,
                                      color: Color.fromRGBO(183, 183, 183, 1),
                                    ),
                                  )*/
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Opacity(
                  opacity: 0.12,
                  child: new Container(
                    margin: new EdgeInsets.only(top: 16.0),
                    height: 1.0,
                    color: AppColors.dividerColor,
                  ),
                ),
                data?.status == 1
                    ? Container(
                        height: 40,
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            hitEndedFavours(data);
                          },
                          child: Center(
                            child: new Text(
                              "END FAVOR",
                              style: new TextStyle(
                                  color: AppColors.redLight,
                                  fontSize: 14,
                                  fontFamily: AssetStrings.circulerNormal),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          index == (listResult?.length ?? 0) - 1
              ? SizedBox(
                  height: 30,
                )
              : Container()
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
