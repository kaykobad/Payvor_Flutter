import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/create_payvor/payvorcreate.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';

class PreviewPost extends StatefulWidget {
  final PayvorCreateRequest request;
  final int type;
  final File file;
  ValueSetter<int> voidcallback;

  PreviewPost({this.request, this.type, this.file, this.voidcallback});

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

  var userName = "";
  var active = 0;
  var profile = "";
  var location = "";

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
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    userName = userinfo.user.name ?? "";
    active = userinfo.user.isActive ?? 0;
    profile = userinfo.user.profilePic ?? "";
    location = userinfo.user.location ?? "";

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
                  height: 16.0,
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
                Opacity(
                  opacity: 0.12,
                  child: new Container(
                    height: 1.0,
                    color: AppColors.dividerColor,
                  ),
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
                    callback, ResString().get('post_favor'), 16,
                    newColor: AppColors.colorDarkCyan)),
          ),
        ],
      ),
    );
  }

  void callback() {
    widget.voidcallback(1);
    Navigator.pop(context);
  }

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
          widget.file != null
              ? new Container(
            height: 147,
            width: double.infinity,
            margin:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
            child: ClipRRect(
              // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
              borderRadius: new BorderRadius.circular(10.0),
              child: widget.file != null ? new Image.file(
                widget.file,
                fit: BoxFit.cover,
                width: 147,
              ) : Container(
                color: Colors.grey,
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
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: new Text(
                widget?.request?.title ?? "",
                style: TextThemes.blackCirculerMediumHeight,
              )),
          Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
            width: double.infinity,
            child: ReadMoreText(
              widget?.request?.description ?? "",
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


  Widget buildItem() {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          new Container(
            width: 40.0,
            height: 40.0,
            alignment: Alignment.center,
            child: new ClipOval(
              child: getCachedNetworkImageWithurl(
                  url: profile,
                  fit: BoxFit.fill,
                  size: 40),
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
                          userName,
                          style: TextThemes.blackCirculerMedium,
                        ),
                        new SizedBox(
                          width: 8,
                        ),
                        active == 1 ? new Image.asset(
                          AssetStrings.verify,
                          width: 16,
                          height: 16,
                        ) : Container(),
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
                            location,
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
                "€ ${widget.request.price}",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }
}