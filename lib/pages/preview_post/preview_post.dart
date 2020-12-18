import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';

class PreviewPost extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PreviewPost>
    with AutomaticKeepAliveClientMixin<PreviewPost> {
  var screenSize;

  String searchkey = null;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();
  bool _loadMore = false;
  bool isPullToRefresh = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    _setScrollListener();
    super.initState();
  }

  void _setScrollListener() {
    //scrollController.position.isScrollingNotifier.addListener(() { print("called");});
/*
    scrollController = new ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (_listGame.length >= (PAGINATION_SIZE * _currentPageNumber)) {
          isPullToRefresh=true;
          _loadHomeData();
          showInSnackBar("Loading data...");
        }
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
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
                  height: 36.0,
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
                            padding: const EdgeInsets.all(3.0),
                            child: new SvgPicture.asset(
                              AssetStrings.back,
                              width: 21.0,
                              height: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: new EdgeInsets.only(right: 20),
                          alignment: Alignment.center,
                          child: new Text(
                            "Preview Post",
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
                _buildContestList(),
              ],
            ),
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
          /* new Center(
            child: _getLoader,
          ),*/

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
                color: Colors.white,
                padding: new EdgeInsets.only(top: 9, bottom: 28),
                child: getSetupButtonNew(
                    callback, ResString().get('post_flavor'), 16,
                    newColor: AppColors.colorDarkCyan)),
          ),
        ],
      ),
    );
  }

  void callback() {}

  _buildContestList() {
    return Expanded(
      child: Container(
        color: AppColors.whiteGray,
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemMain(index);
          },
          itemCount: 1,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(int pos) {
    var index = pos % 2 == 0 ? true : false;

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          new Container(
            height: 8.0,
            color: AppColors.whiteGray,
          ),
          index
              ? new Container(
                  height: 147,
                  width: double.infinity,
                  margin:
                      new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
                  child: ClipRRect(
                    // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                    borderRadius: new BorderRadius.circular(10.0),

                    child: getCachedNetworkImageWithurl(
                      url:
                          "https://cdn.pixabay.com/photo/2013/07/21/13/00/rose-165819__340.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(),
          new SizedBox(
            height: 16.0,
          ),
          buildItem(),
          Opacity(
            opacity: 0.12,
            child: new Container(
              height: 1.0,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
              color: AppColors.dividerColor,
            ),
          ),
          Container(
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              alignment: Alignment.centerLeft,
              child: new Text(
                "Help me move out of my flat",
                style: TextThemes.blackCirculerMediumHeight,
              )),
          Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
            child: ReadMoreText(
              "I need help moving out of my flat as there are many things to carry. Can someone help me out? It should not take more than 2 hours since I don’t have that many belongings,I need help moving out of my flat as there are many things to carry.",
              trimLines: 4,
              colorClickableText: AppColors.colorDarkCyan,
              trimMode: TrimMode.Line,
              style: new TextStyle(
                color: AppColors.moreText,
                fontFamily: AssetStrings.circulerNormal,
                fontSize: 14.0,
              ),
              trimCollapsedText: '...more',
              trimExpandedText: ' less',
            ),
          ),
          new SizedBox(
            height: 16.0,
          ),
        ],
      ),
    );
  }
}

Widget buildItem() {
  return Container(
    margin: new EdgeInsets.only(left: 16.0, right: 16.0),
    child: Row(
      children: <Widget>[
        new Container(
          width: 40.0,
          height: 40.0,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [const Color(0xFF177FBE), const Color(0xFF00BBA6)],
              end: Alignment.centerRight,
              begin: Alignment.centerLeft,
            ),
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
                        "Jonathan Dore",
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
                    Container(
                        child: new Text(
                      "Grand Cnal Duke, Dublin",
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
              "€50",
              style: TextThemes.blackDarkHeaderSub,
            )),
      ],
    ),
  );
}
