import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import 'package:payvor/filter/refer_user.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/favour_posted_by_user.dart';
import 'package:payvor/pages/original_post/original_post_data.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/shimmers/refer_shimmer_loader.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyPosts extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;

  MyPosts({@required this.lauchCallBack});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyPosts>
    with AutomaticKeepAliveClientMixin<MyPosts> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

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

    var response = await provider.favourpostedbyuser(context, currentPage);

    if (response is FavourPostedByUserResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          listResult.clear();
          listResult.add("Posted Favors");
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
                _buildContestList(),
                new SizedBox(height: 30),
              ],
            ),
          ),
          Offstage(
            offstage: offstagenodata,
            child: Container(
              height: screenSize.height,
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
                      margin: new EdgeInsets.only(top: 61),
                      child: new Text(
                        "No Favors",
                        style: new TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 9),
                      child: new Text(
                        "You haven’t asked for any favors yet.Once you create a favor it will show up here.",
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
            margin: new EdgeInsets.only(top: 130),
            child: new Center(
              child: getHalfScreenLoader(
                status: loader,
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
        margin: new EdgeInsets.only(left: 16, right: 16),
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (listResult[index] is String) {
              widgets = buildItemHeader(listResult[index]);
            } else if (listResult[index] is int) {
              widgets = buildItemMain();
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

  Widget buildItem(DataFavour data) {
    return InkWell(
      onTap: () {
        widget.lauchCallBack(Material(
            child: Material(
                child: new OriginalPostData(
          id: data.id.toString(),
          lauchCallBack: widget.lauchCallBack,
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
              margin: new EdgeInsets.only(top: 10.0),
              child: new Text(
                data?.title,
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
            ),
            Container(
              margin: new EdgeInsets.only(top: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      child: new Text(
                        "${data?.applied_count.toString() ?? "0"} Peoples applied",
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

  Widget buildItemHeader(String text) {
    return Container(
      padding: new EdgeInsets.only(top: 16, bottom: 2),
      child: Text(text, style: TextThemes.darkBlackMedium),
    );
  }

  Widget buildItemMain() {
    return Container(
      padding: new EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
      margin: new EdgeInsets.only(top: 8.0),
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(5.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                new SvgPicture.asset(
                  AssetStrings.referIcon,
                  height: 18,
                  width: 18,
                ),
                Expanded(
                  child: Container(
                    margin: new EdgeInsets.only(left: 7.0),
                    child: new Text(
                      "02 jan 2020",
                      style: TextThemes.greyDarkTextHomeLocation,
                    ),
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 3.0),
                  child: new Text(
                    "€50",
                    style: TextThemes.darkRedMediumNew,
                  ),
                )
              ],
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(top: 10.0),
            child: new Text(
              "Help me carry some books",
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
          ),
          Container(
            margin: new EdgeInsets.only(top: 10.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: new Text(
                    "You have hired ",
                    style: TextThemes.grayNormalSmall,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: new EdgeInsets.only(left: 1.0),
                    child: new Text(
                      "You have hired ",
                      style: TextThemes.cyanTextSmallMedium,
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
