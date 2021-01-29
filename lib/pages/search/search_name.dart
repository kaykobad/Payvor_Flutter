import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/filter/refer_request.dart';
import 'package:payvor/filter/refer_response.dart';
import 'package:payvor/filter/refer_user.dart';
import 'package:payvor/filter/refer_user_response.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/shimmers/refer_shimmer_loader.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class SearchHomeByName extends StatefulWidget {
  final String lat;
  final String long;
  final String id;
  final String description;

  SearchHomeByName({this.lat, this.long, this.id, this.description});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchHomeByName>
    with AutomaticKeepAliveClientMixin<SearchHomeByName> {
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

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery
        .of(context)
        .size;
    provider = Provider.of<AuthProvider>(context);

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
                (provider.getLoading()) ? Expanded(
                  child: Container(
                    height: double.infinity,
                    child: HomeShimmerRefer(),
                  ),
                ) : _buildContestList(),
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

    ReferUserRequest loginRequest = new ReferUserRequest(user_id: id,
        favour_id: widget?.id,
        description: widget?.description ?? "");
    var response = await provider.referUser(loginRequest, context);
    loader = false;
    if (response is ReferUserResponse) {
      refer?.isSelect = true;

      setState(() {});
    }
    else {
      loader = false;
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.messag);
    }
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
                      onSubmitted: (String value) {
                        _loadMore = false;
                        isPullToRefresh = false;
                        currentPage = 1;
                        title = value;

                        hitSearchApi(title);
                      },
                      onChanged: (String value) {
                        _loadMore = false;
                        isPullToRefresh = false;
                        currentPage = 1;
                        title = value;
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
                  ),
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
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            isPullToRefresh = true;
            _loadMore = false;
            currentPage = 1;

            await hitSearchApi(title);
          },

          child: Container(
            color: Colors.white,
            child: new ListView.builder(
              padding: new EdgeInsets.all(0.0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return buildItemMain(listResult[index]);
              },
              itemCount: listResult.length,
            ),
          ),
        ));
  }


  Widget buildItem(DataRefer dataTile) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
                child: new ChatMessageDetails(
              id: "",
              name: dataTile?.name ?? "",
              image: dataTile?.profilePic ?? "",
              hireduserId: dataTile?.id?.toString(),
            ));
          }),
        );
      },
      child: Container(
        margin: new EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          children: <Widget>[
            new Container(
              width: 40.0,
              height: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

                child: getCachedNetworkImageWithurl(
                    url: dataTile?.profilePic ?? "",
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
                    child: new Text(
                      dataTile?.name ?? "",
                      style: TextThemes.greyTextFielMedium,
                    ),
                  ),
                  Container(
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                    child: Row(
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
                            child: new Text(
                          dataTile?.rating_avg?.toString() ?? "",
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
                          "${dataTile?.rating_avg?.toString() ?? ""} Reviews",
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
                child: dataTile?.isSelect == null || dataTile?.isSelect == false
                    ? InkWell(
                        onTap: () {
                          hitApi(dataTile?.id?.toString(), dataTile);
                        },
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
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          // loader = true;
                          // setState(() {});

                          Future.delayed(const Duration(milliseconds: 300), () {
                            dataTile?.isSelect = false;
                            setState(() {});
                          });
                        },
                        child: Container(
                          width: 65,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: new BorderRadius.circular(12.0),
                              color: AppColors.lightReferred),
                          child: new Text(
                            "Referred",
                            style: new TextStyle(
                              color: AppColors.colorCyanPrimary,
                              fontFamily: AssetStrings.circulerNormal,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
          ],
        ),
      ),
    );
  }


  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(DataRefer data) {
    return Container(
      child: Column(
        children: <Widget>[
          new SizedBox(
            height: 12.0,
          ),
          buildItem(data),
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
