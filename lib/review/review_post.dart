import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/themes_styles.dart';

class ReviewPost extends StatefulWidget {
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
                            "Reviews (19)",
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
        ],
      ),
    );
  }

  void callback() {}

  _buildContestList() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemMain(index);
          },
          itemCount: 5,
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
          buildItem(),
          Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
            child: ReadMoreText(
              "I need help moving out of my flat as there are many things to carry. Can someone help me out? It should not take more than 2 hours since I don’t have that many belongings,I need help moving out of my flat as there are many things to carry.",
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
          width: 32.0,
          height: 32.0,
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
          child: Container(
            margin: new EdgeInsets.only(left: 8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(
                  "Jonathan Dore",
                  style: TextThemes.blackCirculerMedium,
                ),
                Container(
                    child: new Text(
                  "29 May 2020",
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
                new Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: new SvgPicture.asset(
                    AssetStrings.star,
                  ),
                ),
                new SizedBox(
                  width: 3,
                ),
                Container(
                  margin: new EdgeInsets.only(top: 1.2),
                  child: new Text(
                    "5",
                    style: TextThemes.blackPreview,
                  ),
                ),
              ],
            )),
      ],
    ),
  );
}
