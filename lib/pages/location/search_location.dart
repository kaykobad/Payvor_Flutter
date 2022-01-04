import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/location/search_map.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/location_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class SearchLocation extends StatefulWidget {
  final LocationProvider provider;

  SearchLocation({this.provider});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchLocation> with AutomaticKeepAliveClientMixin<SearchLocation> {
  var screenSize;
  AuthProvider provider;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

  List<LocationSuggestion> listResult = [];
  final StreamController<bool> _streamControllerShowLoader = StreamController<bool>();
  TextEditingController _controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final StreamController<bool> _loaderStreamController = StreamController<bool>();
  // bool _loadMore = false;
  //  String searchkey;
  TextEditingController _locationController = TextEditingController();
  TextEditingController _latLongController = TextEditingController();
  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void dispose() {
    _streamControllerShowLoader.close();
    super.dispose();
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  void initState() {
    // Future.delayed(const Duration(milliseconds: 300), () => hitSearchApi(""));
    //  _setScrollListener();
    super.initState();
  }

  // hitSearchApi(String data) async {
  //   bool gotInternetConnection = await hasInternetConnection(
  //     context: context,
  //     mounted: mounted,
  //     canShowAlert: true,
  //     onFail: () {
  //       provider.hideLoader();
  //     },
  //     onSuccess: () {},
  //   );
  //
  //   if (!gotInternetConnection) {
  //     return;
  //   }
  //
  //   if (!isPullToRefresh) {
  //     provider.setLoading();
  //   }
  //
  //   if (_loadMore) {
  //     currentPage++;
  //   } else {
  //     currentPage = 1;
  //   }
  //
  //   var request;
  //   var newRequest;
  //
  //   var type = 1;
  //   if (data.isNotEmpty && data.trim().length >= 0) {
  //     request = ReferRequest(lat: "", long: "", name: data);
  //   } else {
  //     type = 2;
  //     newRequest = ReferRequestNew(lat: "", long:  "");
  //   }
  //
  //   var response = await provider.getReferList(request, context, currentPage, newRequest, type);
  //
  //   if (response is ReferListResponse) {
  //     provider.hideLoader();
  //
  //     print("res $response");
  //     isPullToRefresh = false;
  //
  //     if (response != null && response.data != null) {
  //       if (currentPage == 1) {
  //         listResult.clear();
  //       }
  //
  //       listResult.addAll(response?.data?.data);
  //
  //       if (response.data != null &&
  //           response.data.data != null &&
  //           response.data.data?.length < Constants.PAGINATION_SIZE) {
  //         _loadMore = false;
  //       } else {
  //         _loadMore = true;
  //       }
  //
  //       if (listResult.length > 0) {
  //         offstagenodata = true;
  //       } else {
  //         offstagenodata = false;
  //       }
  //
  //       setState(() {});
  //     }
  //
  //     print(response);
  //     try {} catch (ex) {}
  //   } else {
  //     provider.hideLoader();
  //     APIError apiError = response;
  //     print(apiError.error);
  //
  //     showInSnackBar(apiError.error);
  //   }
  // }

  // void _setScrollListener() {
  //   //scrollController.position.isScrollingNotifier.addListener(() { print("called");});
  //
  //   scrollController = ScrollController();
  //   scrollController.addListener(() {
  //     if (scrollController.position.maxScrollExtent ==
  //         scrollController.offset) {
  //       if (listResult.length >= (Constants.PAGINATION_SIZE * currentPage)) {
  //         isPullToRefresh = true;
  //         hitSearchApi(title);
  //         showInSnackBar("Loading data...");
  //       }
  //     }
  //   });
  // }

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

    return Center(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.bluePrimary,
        body: Stack(
          children: <Widget>[
            Container(
              color: AppColors.backgroundGray,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 50.0, color: Colors.white,),
                  getTextField(),
                  Container(
                    color: Colors.white,
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        height: 0.5,
                        margin: EdgeInsets.only(top: 16.0),
                        color: AppColors.dividerColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      hitLocation();
                    },
                    child: Container(
                      child: getTopItem("Use my current location", 1, AssetStrings.sendMsg, 21.0, 20.0),
                    ),
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: Container(
                      height: 0.5,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (BuildContext context) {
                          return SearchMapView(
                            provider: widget?.provider,
                          );
                        }),
                      );
                    },
                    child: Container(
                      child: getTopItem("Set location on map", 2, AssetStrings.map, 25.0, 20.0),
                    ),
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: Container(
                      height: 0.5,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  if (listResult.length > 0) Container(
                    margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
                    child: Text(
                      "Suggestions",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: AssetStrings.circulerMedium,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  (listResult.length > 0) ? _buildContestList() : Container(),
                ],
              ),
            ),
            Offstage(
              offstage: offstagenodata,
              child: Container(
                margin: EdgeInsets.only(top: 130),
                child: Center(
                  child: Text(
                    "No Location Found",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 130),
              child: Center(
                child: getHalfScreenLoader(status: loader, context: context),
              ),
            ),
            /* Center(
              child: _getLoader,
            ),*/
          ],
        ),
      ),
    );
  }

  // hitApi(String id, DataRefer refer) async {
  //   setState(() {
  //     loader = true;
  //   });
  //
  //   bool gotInternetConnection = await hasInternetConnection(
  //     context: context,
  //     mounted: mounted,
  //     canShowAlert: true,
  //     onFail: () {
  //       loader = false;
  //     },
  //     onSuccess: () {},
  //   );
  //
  //   if (!gotInternetConnection) {
  //     return;
  //   }
  //
  //   /* ReferUserRequest loginRequest = ReferUserRequest(
  //       user_id: id,
  //       favour_id: widget?.id,
  //       description: widget?.description ?? "");
  //   var response = await provider.referUser(loginRequest, context);
  //   loader = false;
  //   if (response is ReferUserResponse) {
  //     refer?.isSelect = true;
  //
  //     setState(() {});
  //   } else {
  //     loader = false;
  //     APIError apiError = response;
  //     print(apiError.error);
  //
  //     showInSnackBar(apiError.messag);
  //   }*/
  // }

  Widget getTopItem(String text, int type, String image, double size, double margin) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 15.0),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            margin: EdgeInsets.only(left: 10),
            padding: EdgeInsets.all(10.0),
            child: Image.asset(
              image,
              width: size,
              height: size,
            ),
          ),
          SizedBox(width: margin),
          Container(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.kBlack,
                fontSize: 16,
                fontFamily: AssetStrings.circulerMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTextField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: SvgPicture.asset(AssetStrings.back),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: AppColors.lightWhite,
            ),
            child: Container(
              width: getScreenSize(context: context).width - 65,
              height: 46.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10.0),
                  Image.asset(AssetStrings.searches, width: 18.0, height: 18.0),
                  SizedBox(width: 10.0),
                  // Expanded(
                  //   child: Container(
                  //     padding: EdgeInsets.only(left: 12, right: 5.0),
                  //     child: getLocationNew(
                  //       _LocationController,
                  //       context,
                  //       _streamControllerShowLoader,
                  //       true,
                  //       _LatLongController,
                  //       iconData: AssetStrings.location,
                  //       onTap: () {
                  //         if (_LatLongController?.text != null && _LatLongController.text.contains(",")) {
                  //           MemoryManagement.setLocationName(geo: _LocationController?.text);
                  //           MemoryManagement.setGeo(geo: _LatLongController?.text);
                  //           widget?.provider?.locationProvider?.add(_LatLongController?.text);
                  //           Navigator.pop(context);
                  //         }
                  //       },
                  //     ),
                  //   ),
                  // ),

                  Flexible(
                    child: TextField(
                      controller: _controller,
                      style: TextThemes.blackTextFieldNormal,
                      keyboardType: TextInputType.text,
                      onSubmitted: (String value) async {
                        // hitSearchApi(title);
                        try {
                          Dio dio = Dio();
                          if (value.isNotEmpty) {
                            var response = await dio.get(
                              "https://maps.googleapis.com/maps/api/geocode/json?address=$value&key=${Constants.GOOGLE_PLACES_API}",
                              cancelToken: CancelToken(),
                            ).timeout(timeoutDuration);

                            Map<String, dynamic> _predictions = response.data;
                            listResult.clear();
                            for (var data in _predictions['results']) {
                              listResult.add(LocationSuggestion(
                                data['formatted_address'] ?? '',
                                data['geometry']['location']['lat']?.toString() ?? '',
                                data['geometry']['location']['lng']?.toString() ?? '',
                                data['place_id'] ?? '',
                              ));
                            }
                            setState(() {});
                          }
                        } catch (e, st) {
                          print(e.toString());
                          print(st);
                        }
                      },
                      onChanged: (String value) async {
                        // hitSearchApi(title);
                        try {
                          Dio dio = Dio();
                          if (value.isNotEmpty) {
                            var response = await dio.get(
                              "https://maps.googleapis.com/maps/api/place/textsearch/json"
                                  "?query=$value"
                                  "&key=${Constants.GOOGLE_PLACES_API}",
                              cancelToken: CancelToken(),
                            ).timeout(timeoutDuration);

                            Map<String, dynamic> _predictions = response.data;
                            listResult.clear();
                            for (var data in _predictions['results']) {
                              listResult.add(LocationSuggestion(
                                data['formatted_address'] ?? '',
                                data['geometry']['location']['lat']?.toString() ?? '',
                                data['geometry']['location']['lng']?.toString() ?? '',
                                data['place_id'] ?? '',
                              ));
                            }
                            setState(() {});
                          }
                        } catch (e, st) {
                          print(e.toString());
                          print(st);
                        }
                      },
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 3.0),
                        hintText: "Search here by name",
                        hintStyle: TextThemes.greyTextNormal,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.0),
                  InkWell(
                    onTap: () {
                      // _loadMore = false;
                      isPullToRefresh = false;
                      _controller.text = "";
                      currentPage = 1;
                      listResult.clear();
                      setState(() {});
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Image.asset(
                        AssetStrings.clean,
                        width: 18.0,
                        height: 18.0,
                        color: Color(0xFF5A5959),
                        colorBlendMode: BlendMode.dstATop,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
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
        child: ListView.builder(
          padding: EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemMain(listResult[index]);
          },
          itemCount: listResult.length,
        ),
      ),
    );
  }

  // void callback() {}

  Widget buildItem(LocationSuggestion data) {
    return InkWell(
      onTap: () {
        MemoryManagement.setLocationName(geo: data.description);
        MemoryManagement.setGeo(geo: data.position);
        widget?.provider?.locationProvider?.add(data.position);
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(left: 17.0, right: 17.0),
        child: Row(
          children: [
            Image.asset(
              AssetStrings.location,
              width: 18.0,
              height: 18.0,
              color: Colors.grey,
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Text(
                  data.description,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontFamily: AssetStrings.circulerNormal,
                  ),
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

  Widget buildItemMain(LocationSuggestion data) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 15.0),
          buildItem(data),
          Opacity(
            opacity: 0.7,
            child: Container(
              height: 0.5,
              margin: EdgeInsets.only(left: 17.0, right: 17.0, top: 15.0),
              color: AppColors.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}

class LocationSuggestion {
  final String description;
  final String lat;
  final String long;
  final String placeId;

  LocationSuggestion(this.description, this.lat, this.long, this.placeId);

  String get position => lat + ',' + long;
}
