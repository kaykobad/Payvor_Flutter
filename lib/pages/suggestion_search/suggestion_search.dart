import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';

class SearchHomeByName extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchHomeByName>
    with AutomaticKeepAliveClientMixin<SearchHomeByName> {
  var screenSize;

  String searchkey = null;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  TextEditingController _controller = new TextEditingController();
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
      backgroundColor: AppColors.bluePrimary,
      body: Stack(
        children: <Widget>[
          new Container(
            color: Colors.white,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 80.0,
                ),
                getTextField(),
                Opacity(
                  opacity: 0.7,
                  child: new Container(
                    height: 0.5,
                    margin: new EdgeInsets.only(top: 16.0),
                    color: AppColors.dividerColor,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
                  child: new Text(
                    "Suggested Users",
                    style: new TextStyle(
                        color: Colors.black,
                        fontFamily: AssetStrings.circulerMedium,
                        fontSize: 18.0),
                  ),
                ),
                new SizedBox(
                  height: 10,
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

  Widget getTextField() {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
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
                  AssetStrings.back,
                ),
              ),
            ),
          ),
          new SizedBox(
            width: 10.0,
          ),
          Container(
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(3.0),
                color: AppColors.lightWhite),
            child: Container(
              width: getScreenSize(context: context).width - 65,
              height: 46.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Image.asset(
                    AssetStrings.searches,
                    width: 18.0,
                    height: 18.0,
                  ),
                  new SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                    child: new TextField(
                      controller: _controller,
                      style: TextThemes.blackTextFieldNormal,
                      keyboardType: TextInputType.text,
                      onSubmitted: (String value) {},
                      decoration: new InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: new EdgeInsets.only(bottom: 3.0),
                        hintText: "Search here by name",
                        hintStyle: TextThemes.greyTextNormal,
                      ),
                    ),
                  ),
                  new SizedBox(
                    width: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      _controller.text = "";
                      setState(() {});
                    },
                    child: new Image.asset(
                      AssetStrings.clean,
                      width: 18.0,
                      height: 18.0,
                    ),
                  ),
                  new SizedBox(
                    width: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          itemCount: 30,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(int pos) {
    var index = pos % 2 == 0 ? true : false;

    return Container(
      child: Column(
        children: <Widget>[
          new SizedBox(
            height: 12.0,
          ),
          buildItem(),
          Opacity(
            opacity: 0.7,
            child: new Container(
              height: 0.5,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
              color: AppColors.dividerColor,
            ),
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
                child: new Text(
                  "Jonathan Dore",
                  style: TextThemes.greyTextFielMedium,
                ),
              ),
              Container(
                margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                child: Row(
                  children: [
                    new SvgPicture.asset(
                      AssetStrings.star,
                    ),
                    new SizedBox(
                      width: 3,
                    ),
                    Container(
                        child: new Text(
                      "5",
                      style: TextThemes.greyTextFieldNormal,
                    )),
                    Container(
                      width: 5,
                      height: 5,
                      margin: new EdgeInsets.only(left: 4, right: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkgrey,
                      ),
                    ),
                    Container(
                        child: new Text(
                      "3 Reviews",
                      style: TextThemes.greyTextFieldNormal,
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Container(
              width: 65,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(12.0),
                  color: AppColors.colorDarkCyan),
              child: new Text(
                "Refer",
                style: new TextStyle(
                  color: Colors.white,
                  fontFamily: AssetStrings.circulerNormal,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            )),
      ],
    ),
  );
}
