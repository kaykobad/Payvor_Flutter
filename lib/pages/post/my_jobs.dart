import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:payvor/current_user_hired_by_favor/current_user_hire_favor.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/applied_user/favour_applied_user.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/pay_feedback/pay_feedback_common.dart';
import 'package:payvor/pages/pay_feedback/pay_give_feedback.dart';
import 'package:payvor/pages/post/recent_applied_favor.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class MyJobs extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;

  MyJobs({@required this.lauchCallBack});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyJobs> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  FirebaseProvider providerFirebase;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

  int favourapplied = 0;

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
      hitJobsPost();
    });

    /*  listResult.add("Hired Favors");
    listResult.add(1.0);
    listResult.add(1.0);
    listResult.add("Posted Favors");
    listResult.add(1);
    listResult.add(1);
    listResult.add(1);*/

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

    var response = await provider.currentuserhirefavor(context, currentPage);

    provider.hideLoader();

    if (response is CurrentUserHiredByFavorResponse) {
      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          favourapplied = response?.favourapplied ?? 0;
          listResult.clear();

          if (response?.data?.length > 0) {
            listResult.add("Next Jobs");
          }
        }

        listResult.addAll(response?.data);

        if (response != null && response.data != null &&
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

        //  hitCurrentUserHire();

        setState(() {});
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      //hitCurrentUserHire();

      //  showInSnackBar(apiError.error);
    }
  }

  hitCurrentUserHire() async {
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
/*
    if (!isPullToRefresh) {
      provider.setLoading();
    }

    if (_loadMore) {
      currentPage++;
    } else {
      currentPage = 1;
    }*/

    var response = await provider.favourjobapplieduser(context, currentPage);

    if (response is FavourAppliedByUserResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          if (response?.data?.data.length > 0) {
            listResult.add("Applied Jobs");
          }
        }

        listResult.addAll(response?.data?.data);


        if (!_loadMore) {
          if (response != null &&
              response?.data != null &&
              response?.data?.data.length < Constants.PAGINATION_SIZE) {
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
          hitJobsPost();
          showInSnackBar("Loading data...");
        }
      }
    });
  }

  Widget buildItemNewTop() {
    return InkWell(
      onTap: () {
        widget.lauchCallBack(Material(
            child: Material(
                child: new RecentAppliedFavor(
          lauchCallBack: widget?.lauchCallBack,
        ))));
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
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
                      "Recent Applied Favors ($favourapplied)",
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 7.0),
                    child: Container(
                      child: new Text(
                        "The favors you’ve applied recently but hired",
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
    );
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
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                favourapplied != null && favourapplied > 0
                    ? buildItemNewTop()
                    : Container(),
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
                      child: new Image.asset(
                        AssetStrings.noPosts,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 10),
                      child: new Text(
                        "No Jobs",
                        style: new TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 9, left: 20, right: 20),
                      child: new Text(
                        "You don’t have any job yet.\nOnce you’re hired it will show up here.",
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

        await hitJobsPost();
      },
      child: Container(
        margin: new EdgeInsets.only(left: 18, right: 18),
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (listResult[index] is String) {
              widgets = buildItemHeader(listResult[index]);
            } else if (listResult[index] is DataNextJob) {
              widgets = buildItemMain(index, listResult[index]);
            } else if (listResult[index] is Datas) {
              widgets = buildItem(index, listResult[index]);
            }

            return widgets;
          },
          itemCount: listResult.length,
        ),
      ),
    ));
  }

  String getStatus(int type) {
    String data = "";

    if (type == 1) {
      data = " has hired you";
    } else if (type == 2) {
      data = " has paid & Ended Favor";
    } else if (type == 3) {
      data = " has paid & Ended Favor";
    }
    return data;
  }

  Widget buildItem(int index, Datas data) {
    return InkWell(
      onTap: () {
        providerFirebase?.changeScreen(new PostFavorDetails(
          id: data?.favourId?.toString(),
          isButtonDesabled: true,
        ));
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
            /*  new Container(
              margin: new EdgeInsets.only(top: 10.0),
              child: new Text(
                data?.favour?.title ?? "",
                style: TextThemes.blackCirculerMedium,
              ),
            ),
            Opacity(
              opacity: 0.12,
              child: new Container(
                margin: new EdgeInsets.only(top: 30.0),
                height: 1.0,
                color: AppColors.dividerColor,
              ),
            ),*/
            Container(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: new Text(
                        data?.favour?.title ?? "",
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

  ValueSetter<int> callback(int type) {
    currentPage = 1;
    isPullToRefresh = true;
    _loadMore = false;
    hitJobsPost();
  }

  Widget buildItemMain(int index, DataNextJob data) {
    return InkWell(
      onTap: () {
        if (data?.status != 3) {
          widget.lauchCallBack(Material(
              child: Material(
                  child: new PayFeebackDetailsCommon(
            lauchCallBack: widget?.lauchCallBack,
            userId: data?.hiredUserId?.toString(),
            postId: data?.id?.toString(),
            status: 1,
            type: 1,
            voidcallback: callback,
          ))));
        } else {
          widget.lauchCallBack(Material(
              child: Material(
                  child: new PayFeebackDetails(
                    lauchCallBack: widget?.lauchCallBack,
                    userId: data?.hiredUserId?.toString(),
                    postId: data?.id?.toString(),
                    type: 1,
                    voidcallback: callback,
                  ))));

          /*
          widget.lauchCallBack(Material(
              child: Material(
                  child: new ChatMessageDetails(
                    id: data.userId.toString(),
                    name: data.title,
                    hireduserId: data?.hiredUserId?.toString(),
                    image: data?.image,
                    userButtonMsg: true,
                  ))));*/
        }
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        margin: new EdgeInsets.only(top: 18.0),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                new Container(
                    width: 49.0,
                    height: 49.0,
                    decoration: new BoxDecoration(
                      color: Colors.grey,
                      border: new Border.all(color: Colors.white, width: 0.3),
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
                              InkWell(
                                onTap: () {
                                  widget.lauchCallBack(Material(
                                      child: Material(
                                          child: new ChatMessageDetails(
                                    id: data.userId.toString(),
                                    name: data.hiredBy.name,
                                    hireduserId: data?.userId?.toString(),
                                    image: data?.image,
                                    userButtonMsg: true,
                                  ))));
                                },
                                child: Container(
                                  child: new Text(
                                    data?.hiredBy?.name ?? "someone",
                                    style: TextThemes.cyanTextSmallMedium,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: new EdgeInsets.only(left: 1.0),
                                  child: InkWell(
                                    onTap: () {},
                                    child: Container(
                                      margin: new EdgeInsets.only(left: 1.0),
                                      child: new Text(
                                        getStatus(data?.status),
                                        style: TextThemes.grayNormalSmall,
                                      ),
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
            Container(
              margin: new EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    new Text(
                      "€ ${data?.price ?? ""}",
                      style: new TextStyle(
                          color: AppColors.kBlack.withOpacity(0.7),
                          fontSize: 16,
                          fontFamily: AssetStrings.circulerNormal),
                    ),
                    Expanded(
                      child: new Container(),
                    ),
                    new Container(
                      width: 8,
                      height: 8,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          color: data?.status == 1
                              ? AppColors.statusYellow
                              : AppColors.statusGreen),
                    ),
                    Container(
                      margin: new EdgeInsets.only(left: 5),
                      child: new Text(
                        data?.status == 1 ? "Not Paid" : "Paid",
                        style: new TextStyle(
                            color: AppColors.kBlack.withOpacity(0.7),
                            fontSize: 16,
                            fontFamily: AssetStrings.circulerNormal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
