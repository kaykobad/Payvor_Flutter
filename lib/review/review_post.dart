import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/rating_list/rating_list.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class ReviewPost extends StatefulWidget {
  final String id;

  ReviewPost({this.id});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ReviewPost>
    with AutomaticKeepAliveClientMixin<ReviewPost> {
  var screenSize;

  String searchkey = null;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();
  bool _loadMore = false;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  int currentPage = 1;
  AuthProvider provider;

  List<DataRating> list = List<DataRating>();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    print("search");
    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi();
    });
    _setScrollListener();

    super.initState();
  }

  void _setScrollListener() {
    scrollController = new ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (list.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitApi();
          showInSnackBar("Loading data...");
        }
      }
    });
  }


  hitApi() async {
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

    var response = await provider.reviewList(context, currentPage, widget.id);

    if (response is RatingReviewResponse) {
      isPullToRefresh = false;

      print("res $response");

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          list.clear();
        }

        list.addAll(response.data);

        if (response.data != null &&
            response.data.length < Constants.PAGINATION_SIZE) {
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

      print(apiError.error);

      showInSnackBar(apiError.error);
    }
    provider.hideLoader();
  }


  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    screenSize = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          new Container(
            color: Colors.white,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new SizedBox(
                  height: 13.0,
                ),
                Container(
                  margin: new EdgeInsets.only(left: 17.0, top: 35.0, right: 16),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: new Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: new SvgPicture.asset(
                              AssetStrings.cross,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: new EdgeInsets.only(right: 20),
                          alignment: Alignment.center,
                          child: new Text(
                            "Reviews (${list.length})",
                            style: TextThemes.darkBlackMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new SizedBox(
                  height: 16.0,
                ),
                Opacity(
                  opacity: 0.12,
                  child: new Container(
                    height: 1.0,
                    color: AppColors.dividerColor,
                  ),
                ),
                /*  new SizedBox(
                  height: 16.0,

                ),*/
                _buildContestList(),
              ],
            ),
          ),
          new Center(
            child: getHalfScreenLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
          Visibility(
            visible: !offstagenodata,
            child: Container(
              margin: new EdgeInsets.only(top: 170),
              child: new Center(
                child: new Text(
                  "No reviews Found",
                  style: new TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
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

  void callback() {}


  _buildContestList() {
    return Expanded(
      child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              isPullToRefresh = true;
              _loadMore = false;
              currentPage = 1;

              await hitApi();
            },
            child: Container(
              color: AppColors.kAppScreenBackGround,
              child: new ListView.builder(
                padding: new EdgeInsets.all(0.0),
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return buildItemMain(index, list[index]);
                },
                itemCount: list.length,
              ),
            ),
          )),
    );
  }


  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(int pos, DataRating rating) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildItem(rating),
          Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
            child: ReadMoreText(
              rating?.description ?? "",
              trimLines: 8,
              colorClickableText: AppColors.colorDarkCyan,
              trimMode: TrimMode.Line,
              style: new TextStyle(
                color: AppColors.moreText,
                fontFamily: AssetStrings.circulerNormal,
                height: 1.6,
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
              margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 11.0),
              color: AppColors.dividerColor,
            ),
          ),
         /* new SizedBox(
            height: 16.0,
          ),*/
        ],
      ),
    );
  }
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

Widget buildItem(DataRating rating) {
  return Container(
    margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 12),
    child: Row(
      children: <Widget>[
        new Container(
          width: 32.0,
          height: 32.0,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: new ClipOval(
            child: getCachedNetworkImageWithurl(
                url: rating?.profilePic ?? "", fit: BoxFit.cover, size: 32),
          ),
        ),
        Expanded(
          child: Container(
            margin: new EdgeInsets.only(left: 8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(
                  rating?.name ?? "",
                  style: TextThemes.blackCirculerMedium,
                ),
                Container(
                    child: new Text(
                      formatDateString(rating?.createdAt),
                      style: TextThemes.lightGrey,
                )),
              ],
            ),
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  margin: new EdgeInsets.only(top: 1.2),
                  child: new Text(
                    rating?.rating?.toString(),
                    style: TextThemes.blackPreview,
                  ),
                ),
              ],
            )),
      ],
    ),
  );
}
