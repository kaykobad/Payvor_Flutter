import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/filter/refer_response.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/pages/location/search_map.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/location_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class SearchLocation extends StatefulWidget {
  LocationProvider provider;

  SearchLocation({this.provider});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchLocation>
    with AutomaticKeepAliveClientMixin<SearchLocation> {
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

  final StreamController<bool> _streamControllerShowLoader =
      StreamController<bool>();

  TextEditingController _controller = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  bool _loadMore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _LocationController = new TextEditingController();
  TextEditingController _LatLongController = new TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      //   hitSearchApi("");
    });
    //  _setScrollListener();
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

    var type = 1;
    /*if (data.isNotEmpty && data.trim().length > 0) {
      request = ReferRequest(
          lat: widget?.lat ?? "", long: widget?.long ?? "", name: data);
    } else {
      type = 2;
      newRequest =
          ReferRequestNew(lat: widget?.lat ?? "", long:  "");
    }*/

    var response = await provider.getReferList(
        request, context, currentPage, newRequest, type);

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

  void hitLocation() async {
    var data = await currentPosition(1, context, widget?.provider);
    if (data is int && data == 1) {
      print("back alled");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bluePrimary,
      body: Stack(
        children: <Widget>[
          new Container(
            color: Colors.white,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 50.0,
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
                InkWell(
                  onTap: () {
                    hitLocation();
                  },
                  child: Container(
                      child: getTopItem("Use my current location", 1)),
                ),
                Opacity(
                  opacity: 0.7,
                  child: new Container(
                    height: 0.5,
                    margin: new EdgeInsets.only(left: 20, right: 20),
                    color: AppColors.dividerColor,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      new CupertinoPageRoute(builder: (BuildContext context) {
                        return new SearchMapView(
                          provider: widget?.provider,
                        );
                      }),
                    );
                  },
                  child: Container(child: getTopItem("Set location on map", 2)),
                ),
                Opacity(
                  opacity: 0.7,
                  child: new Container(
                    height: 0.5,
                    margin: new EdgeInsets.only(left: 20, right: 20),
                    color: AppColors.dividerColor,
                  ),
                ),
                /*Container(
                  margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
                  child: new Text(
                    "Suggestions",
                    style: new TextStyle(
                        color: Colors.black,
                        fontFamily: AssetStrings.circulerMedium,
                        fontSize: 18.0),
                  ),
                ),*/
                new SizedBox(
                  height: 10,
                ),
                /* (provider.getLoading())
                    ? Expanded(
                        child: Container(
                          height: double.infinity,
                          child: HomeShimmerRefer(),
                        ),
                      )
                    : _buildContestList(),*/
              ],
            ),
          ),
          Offstage(
            offstage: offstagenodata,
            child: Container(
              margin: new EdgeInsets.only(top: 130),
              child: new Center(
                child: new Text(
                  "No User Found",
                  style: new TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
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

  hitApi(String id, DataRefer refer) async {
    setState(() {
      loader = true;
    });

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        loader = false;
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }

    /* ReferUserRequest loginRequest = new ReferUserRequest(
        user_id: id,
        favour_id: widget?.id,
        description: widget?.description ?? "");
    var response = await provider.referUser(loginRequest, context);
    loader = false;
    if (response is ReferUserResponse) {
      refer?.isSelect = true;

      setState(() {});
    } else {
      loader = false;
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.messag);
    }*/
  }

  Widget getTopItem(String text, int type) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new SizedBox(
            width: 15.0,
          ),
          new Image.asset(
            AssetStrings.searches,
            width: 18.0,
            height: 18.0,
          ),
          new SizedBox(
            width: 10.0,
          ),
          new Container(
            child: new Text(
              text,
              style: new TextStyle(color: AppColors.kBlack, fontSize: 18),
            ),
          )
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
                  Expanded(
                    child: Container(
                      padding: new EdgeInsets.only(left: 16, right: 5.0),
                      child: getLocationNew(
                        _LocationController,
                        context,
                        _streamControllerShowLoader,
                        true,
                        _LatLongController,
                        iconData: AssetStrings.location,
                        onTap: () {
                          if (_LatLongController?.text != null &&
                              _LatLongController.text.contains(",")) {
                            MemoryManagement.setLocationName(
                                geo: _LocationController?.text);
                            MemoryManagement.setGeo(
                                geo: _LatLongController?.text);
                            widget?.provider?.locationProvider
                                ?.add(_LatLongController?.text);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),

                  /*  Flexible(
                    child: new TextField(
                      controller: _controller,
                      style: TextThemes.blackTextFieldNormal,
                      keyboardType: TextInputType.text,
                      onSubmitted: (String value) {


                        hitSearchApi(title);
                      },
                      onChanged: (String value) {

                        hitSearchApi(title);
                      },
                      decoration: new InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: new EdgeInsets.only(bottom: 3.0),
                        hintText: "Search here by name",
                        hintStyle: TextThemes.greyTextNormal,
                      ),
                    ),
                  ),*/
                  new SizedBox(
                    width: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      _loadMore = false;
                      isPullToRefresh = false;
                      _controller.text = "";
                      currentPage = 1;
                      hitSearchApi("");
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
          return buildItemMain();
        },
        itemCount: 8,
      ),
    ));
  }

  void callback() {}

  Widget buildItem() {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: new EdgeInsets.only(left: 17.0, right: 17.0),
        child: Row(
          children: [
            new Image.asset(
              AssetStrings.location,
              width: 18.0,
              height: 18.0,
              color: Colors.black,
            ),
            Container(
              margin: new EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Text(
                "Avinash Tiwary",
                style: TextThemes.greyTextFielMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new SizedBox(
            height: 15.0,
          ),
          buildItem(),
          Opacity(
            opacity: 0.7,
            child: new Container(
              height: 0.5,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 15.0),
              color: AppColors.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}
