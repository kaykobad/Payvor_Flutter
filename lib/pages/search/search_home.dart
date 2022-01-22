import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/filter/filter.dart';
import 'package:payvor/filter/filter_request.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/get_favor_list/favor_list_response.dart';
import 'package:payvor/pages/location/search_location.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/pages/suggestion_search/suggestion_search.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/provider/location_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/shimmers/home_shimmer_loader.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class SearchCompany extends StatefulWidget {
  final ValueChanged<int> callbackmyid;
  final String userid;
  final ValueChanged<Widget> lauchCallBack;

  SearchCompany({Key key, this.callbackmyid, this.userid, this.lauchCallBack})
      : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<SearchCompany>
    with AutomaticKeepAliveClientMixin<SearchCompany> {
  var screenSize;

  String searchkey = null;

  List<Datas> list = List<Datas>();

  GlobalKey<HomeState> myKey = GlobalKey();

  TextEditingController _controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  AuthProvider provider;
  LocationProvider locationProvider;
  FirebaseProvider providerFirebase;
  bool isPullToRefresh = false;
  bool _loadMore = false;
  int currentPage = 1;
  FilterRequest filterRequest;
  bool _isFilterApplied = false;
  String location = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    filterRequest = FilterRequest();
    var latlong = MemoryManagement.getGeo();
    var locationMain = MemoryManagement.getLocationName() ?? "";
    location = locationMain;
    if (latlong?.isNotEmpty == true) {
      locationStreamGet();
      filterRequest?.latlongData = latlong;
    } else {
      locationStreamGet();
      Future.delayed(new Duration(microseconds: 5000), () {
        currentPosition(0, context, locationProvider);
      });
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi(filterRequest);
    });
    _setScrollListener();

    super.initState();
  }

  Widget buildItem(Datas data) {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () {
              if (widget.userid == data?.userId?.toString()) {
                print("true");

                widget.callbackmyid(4);
              } else {
                print("flase");
                providerFirebase.changeScreen(new ChatMessageDetails(
                  id: data?.id?.toString(),
                  name: data?.user?.name,
                  image: data?.user?.profilePic,
                  hireduserId: data?.userId?.toString(),
                ));
              }
            },
            child: new Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(shape: BoxShape.circle),
              alignment: Alignment.center,
              child: ClipOval(
                // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

                child: getCachedNetworkImageWithurl(
                    url: data.user?.profilePic ?? "",
                    fit: BoxFit.fill,
                    size: 40),
              ),
            ),
          ),
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (widget.userid == data?.userId?.toString()) {
                      print("true");

                      widget.callbackmyid(4);
                    } else {
                      print("flase");
                      providerFirebase.changeScreen(new ChatMessageDetails(
                        id: data?.id?.toString(),
                        name: data?.user?.name,
                        image: data?.user?.profilePic,
                        hireduserId: data?.userId?.toString(),
                      ));
                    }
                  },
                  child: Container(
                      margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        children: [
                          new Text(
                            data?.user?.name ?? "",
                            style: TextThemes.blackCirculerMedium,
                          ),
                          new SizedBox(
                            width: 8,
                          ),
                          data?.user?.perc == 100
                              ? new Image.asset(
                                  AssetStrings.verify,
                                  width: 16,
                                  height: 16,
                                )
                              : Container(),
                        ],
                      )),
                ),
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
                      Expanded(
                        child: Container(
                          child: Container(
                            child: new Text(
                              data?.location + " - " + data?.distance ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextThemes.greyDarkTextHomeLocation,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: new Text(
                "€${data.price ?? "0"}",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }

  hitApiDashboard() async {
    isPullToRefresh = false;
    _loadMore = false;
    currentPage = 1;
    hitApi(filterRequest);
  }

  hitApi(FilterRequest filterRequest) async {
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

    var response = await provider.getFavorList(
        context, currentPage, filterRequest, voidCallBackStaus);

    if (response is GetFavorListResponse) {
      isPullToRefresh = false;
        if (currentPage == 1) {
          list.clear();
        }
        list.addAll(response.data.data);
        if (response.data != null &&
            response.data.data.length < Constants.PAGINATION_SIZE) {
          _loadMore = false;
        } else {
          _loadMore = true;
        }
    } else {
      APIError apiError = response;
      if (currentPage == 1) {
        list.clear();
      }
      showInSnackBar(apiError.error);
    }
  }

  void _setScrollListener() {
    //crollController.position.isScrollingNotifier.addListener(() { print("called");});

    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (list.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitApi(filterRequest);
          showInSnackBar("Loading data...");
        }
      }
    });
  }

  void locationStreamGet() async {
    await Future.delayed(Duration(milliseconds: 300));
    locationProvider.initListener();
    locationProvider.locationProvider.stream.listen((value) {
      if (value != null) {
        location = MemoryManagement.getLocationName();
        filterRequest?.latlongData = value;
        Future.delayed(const Duration(milliseconds: 300), () {
          currentPage = 1;
          _loadMore=false;
          list.clear();
          hitApi(filterRequest);
        });
      }
    });
  }

  Widget _verticalSpace(double value) {
    return new SizedBox(
      height: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    providerFirebase = Provider.of<FirebaseProvider>(context);
    providerFirebase?.setHomeContextKey(myKey);
    screenSize = MediaQuery.of(context).size;
    locationProvider = Provider.of<LocationProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bluePrimary,
      body: new Container(
        color: AppColors.bluePrimary,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _verticalSpace(50.0),
            _topLocationWidget,
            _getSearchedField,
            _verticalSpace(16.0),
            Visibility(visible: list.isNotEmpty, child: _buildContestList()),
            (provider.getLoading())
                ? Expanded(
                    child: Container(
                      height: double.infinity,
                      child: HomeShimmer(),
                    ),
                  )
                : Container(),
            _emptyFavours
          ],
        ),
      ),
    );
  }

  get _topLocationWidget => InkWell(
        onTap: () {
          providerFirebase.changeScreen(new SearchLocation(
            provider: locationProvider,
          ));
        },
        child: Container(
          padding: new EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            children: [
              new Container(
                width: 38,
                height: 38,
                padding: new EdgeInsets.all(12),
                decoration: new BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    shape: BoxShape.circle),
                child: new Image.asset(
                  AssetStrings.locations,
                  width: 18,
                  height: 18,
                ),
              ),
              Container(
                margin: new EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child: new Text(
                      "Location",
                      style: new TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: AssetStrings.circulerNormal),
                    )),
                    Row(
                      children: [
                        Container(
                            constraints: new BoxConstraints(maxWidth: 280),
                            child: new Text(
                              location.isNotEmpty
                                  ? location
                                  : "Select Location",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: new TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontFamily: AssetStrings.circulerNormal),
                            )),
                        Container(
                            child: new Icon(Icons.arrow_drop_down,
                                color: AppColors.redLight)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  get _emptyFavours => Visibility(
        visible: list.isEmpty && (!provider.getLoading()),
        child: Container(
          margin: new EdgeInsets.only(top: 170),
          child: new Center(
            child: new Text(
              ResString().get("no_favours"),
              textAlign: TextAlign.center,
              style: new TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ),
      );

  get _getSearchedField => Stack(
        children: [
          getTextField(),
          new Positioned(
            right: 0.0,
            top: 0.0,
            child: Offstage(
              offstage: !_isFilterApplied,
              child: new Container(
                width: 13,
                height: 13,
                margin: new EdgeInsets.only(right: 14.0, top: 14),
                decoration: new BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: new Border.all(
                        color: AppColors.bluePrimary, width: 2.5)),
              ),
            ),
          )
        ],
      );

  Widget getTextField() {
    return Container(
      margin: new EdgeInsets.only(top: 16),
      padding: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              child: new TextField(
                controller: _controller,
                style: TextThemes.blackTextFieldNormal,
                keyboardType: TextInputType.text,
                showCursor: false,
                autofocus: false,
                readOnly: true,
                onTap: () {
                  providerFirebase.changeScreen(new SearchHomeByName());
                },
                decoration: new InputDecoration(
                  enabledBorder: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(3)),
                  fillColor: AppColors.whiteGray,
                  filled: true,
                  focusedBorder: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(3)),
                  contentPadding: new EdgeInsets.only(top: 10.0, left: 0),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: new Image.asset(
                      AssetStrings.searches,
                      width: 18.0,
                      height: 15.0,
                    ),
                  ),
                  hintText: "Search favors here",
                  hintStyle: TextThemes.greyTextNormal,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          InkWell(
            onTap: () {
              providerFirebase.changeScreen(new Filter(
                  voidcallback: voidCallBacks, filterRequest: filterRequest));
            },
            child: new Container(
              width: 55,
              padding: new EdgeInsets.only(top: 12.0, bottom: 12.0),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(3.0),
                color: AppColors.colorDarkCyan,
              ),
              child: new Container(
                width: 20,
                height: 20,
                child: new Image.asset(
                  AssetStrings.filters,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<ValueSetter> voidCallBackStaus(bool boolean) async {
    _isFilterApplied = boolean;

    setState(() {});
  }

  Future<ValueSetter> voidCallBacks(FilterRequest filter) async {
    currentPage = 1;
    filterRequest = filter;
    var latLong = MemoryManagement.getGeo();
    if (latLong?.isNotEmpty == true) {
      filterRequest?.latlongData = latLong;
    } else {
      filterRequest?.latlongData = "";
    }
    isPullToRefresh = false;
    _loadMore=false;
    list.clear();
    hitApi(filterRequest);
  }

  Widget _buildContestList() {
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

              await hitApi(filterRequest);
            },
            child: Container(
              color: AppColors.kAppScreenBackGround,
              child: new ListView.builder(
                padding: new EdgeInsets.all(0.0),
                controller: _scrollController,
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

  ValueSetter<int> callback(int type) {
    if (type == 1) {
      currentPage = 1;
      isPullToRefresh = true;
      _loadMore = false;
      hitApi(filterRequest);
    }
  }

  @override
  bool get wantKeepAlive => true;

  gotoPostDetails(int pos, Datas data) async {
    providerFirebase.changeScreen(new PostFavorDetails(
      id: data.id.toString(),
      voidcallback: callback,
      distance: data?.distance,
    ));
    print("callll");
  }

  Widget buildItemMain(int pos, Datas data) {
    return InkWell(
      onTap: () {
        gotoPostDetails(pos, data);
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            new Container(
              height: 8.0,
              color: AppColors.whiteGray,
            ),
            new SizedBox(
              height: 16.0,
            ),
            buildItem(data),
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),
            data?.image != null && data.image.isNotEmpty
                ? new Container(
                    height: 147,
                    width: double.infinity,
                    margin:
                        new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
                    child: ClipRRect(
                      // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                      borderRadius: new BorderRadius.circular(10.0),

                      child: getCachedNetworkImageRect(
                        url: data?.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(),
            Container(
                width: double.infinity,
                color: Colors.white,
                margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
                alignment: Alignment.centerLeft,
                child: new Text(
                  data?.title ?? "",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              width: double.infinity,
              color: Colors.white,
              child: ReadMoreText(
                data?.description ?? "",
                trimLines: 4,
                colorClickableText: AppColors.colorDarkCyan,
                trimMode: TrimMode.Line,
                style: new TextStyle(
                  color: AppColors.moreText,
                  fontFamily: AssetStrings.circulerNormal,
                  fontSize: 14.0,
                ),
                trimCollapsedText: '...more',
                textAlign: TextAlign.start,
                trimExpandedText: ' less',
              ),
            ),
            new SizedBox(
              height: 15.0,
            )
          ],
        ),
      ),
    );
  }
}
