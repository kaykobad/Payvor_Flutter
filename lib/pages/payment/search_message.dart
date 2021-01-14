import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/filter/refer_request.dart';
import 'package:payvor/filter/refer_response.dart';
import 'package:payvor/filter/refer_user.dart';
import 'package:payvor/filter/refer_user_response.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/shimmers/refer_shimmer_loader.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SearchMessage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchMessage>
    with AutomaticKeepAliveClientMixin<SearchMessage> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

  List<DataRefer> listResult = List();

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
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
      hitSearchApi("");
    });
    _setScrollListener();
    super.initState();
  }

  hitSearchApi(String data) async {
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

    var request;
    var newRequest;

/*

    var type = 1;
    if (data.isNotEmpty && data
        .trim()
        .length > 0) {
      request = ReferRequest(
          lat: widget?.lat ?? "", long: widget?.long ?? "", name: data);
    }
    else {
      type = 2;
      newRequest =
          ReferRequestNew(lat: widget?.lat ?? "", long: widget?.long ?? "");
    }
*/

/*

    var response = await provider.getReferList(
        request, context, currentPage, newRequest, type);
*/

    var response;

    if (response is ReferListResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          listResult.clear();
        }

        listResult.addAll(response?.data?.data);

        if (response.data != null &&
            response.data.data != null &&
            response.data.data?.length < Constants.PAGINATION_SIZE) {
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
          hitSearchApi(title);
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
      body: Stack(
        children: <Widget>[
          new Container(
            color: Colors.white,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getTextField(),
                _buildContestList(),
              ],
            ),
          ),
          Offstage(
            offstage: true,
            child: Container(
              height: screenSize.height,
              child: new Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: new SvgPicture.asset(
                        AssetStrings.chat_empty,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 61),
                      child: new Text(
                        "No Messages",
                        style: new TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 9),
                      child: new Text(
                        "You don’t have any conversation yet",
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

  Widget getTextField() {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      padding: new EdgeInsets.all(1),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(3.0),
          border: new Border.all(color: Color.fromRGBO(224, 224, 244, 1)),
          color: AppColors.kWhite),
      child: Container(
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(3.0),
            color: AppColors.lightWhite),
        child: Container(
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
                  onSubmitted: (String value) {
                    /*  _loadMore = false;
                    isPullToRefresh = false;
                    currentPage = 1;
                    title = value;

                    hitSearchApi(title);*/
                  },
                  onChanged: (String value) {
                    /*   _loadMore = false;
                    isPullToRefresh = false;
                    currentPage = 1;
                    title = value;
                    hitSearchApi(title);*/
                  },
                  decoration: new InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: new EdgeInsets.only(bottom: 3.0),
                    hintText: "Search for message here",
                    hintStyle: TextThemes.greyTextNormal,
                  ),
                ),
              ),
              new SizedBox(
                width: 4.0,
              ),
              InkWell(
                onTap: () {
                  /*   _loadMore = false;
                  isPullToRefresh = false;
                  _controller.text = "";
                  currentPage = 1;
                  hitSearchApi("");
                  setState(() {});*/
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
    );
  }

  _buildContestList() {
    return Expanded(
        child: RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        /* isPullToRefresh = true;
            _loadMore = false;
            currentPage = 1;

            await hitSearchApi(title);*/
      },
      child: Container(
        color: Colors.white,
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemMain();
          },
          itemCount: 5,
        ),
      ),
    ));
  }

  Widget buildItem() {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
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
                  url: "", fit: BoxFit.fill, size: 49),
            ),
          ),
          Expanded(
            child: Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: new EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: new Text(
                          "xgdsgdsg",
                          style: TextThemes.greyTextFielBold,
                        ),
                      ),
                      Container(
                        margin: new EdgeInsets.only(left: 6),
                        child: new Text(
                          "now",
                          style: TextThemes.lightGrey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 10.0, top: 6),
                    child: Container(
                        child: new Text(
                      "Great! Let’s do it together in susta…",
                      style: TextThemes.greyDarkTextHomeLocation,
                    )),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding:
                  new EdgeInsets.only(top: 2, bottom: 2, left: 5, right: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(12.0),
                  color: AppColors.colorDarkCyan),
              child: new Text(
                "03",
                style: new TextStyle(
                  color: Colors.white,
                  fontFamily: AssetStrings.circulerMedium,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain() {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.3,
      child: Container(
        child: Column(
          children: <Widget>[
            new SizedBox(
              height: 14.0,
            ),
            buildItem(),
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
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Color.fromRGBO(255, 107, 102, 1),
          icon: Icons.delete,
        ),
      ],
    );
  }
}
