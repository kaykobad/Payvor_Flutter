import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/applied_user/favour_applied_user.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class RecentAppliedFavor extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;

  RecentAppliedFavor({@required this.lauchCallBack});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<RecentAppliedFavor>
    with AutomaticKeepAliveClientMixin<RecentAppliedFavor> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  FirebaseProvider providerFirebase;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

  List<Object> listResult = List();

  final StreamController<bool> _loaderStreamController =
      StreamController<bool>();
  TextEditingController _controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool _loadMore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Widget widgets;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitPostedApi();
    });

    /* listResult.add("Hired Favors");
    listResult.add(1.0);
    listResult.add(1.0);
    listResult.add("Posted Favors");
    listResult.add(1);
    listResult.add(1);
    listResult.add(1);*/

    _setScrollListener();
    super.initState();
  }

  hitPostedApi() async {
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

    var response = await provider.favourjobapplieduser(context, currentPage);

    provider.hideLoader();

    if (response is FavourAppliedByUserResponse) {
      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          listResult.clear();
        }

        listResult.addAll(response?.data?.data);

        if (response != null &&
            response.data != null &&
            response?.data?.data.length < Constants.PAGINATION_SIZE) {
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

  /* hitHireJobApi() async {
    var response = await provider.favourpostedbyuser(context, currentPage);

    provider.hideLoader();

    if (response is FavourPostedByUserResponse) {
      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          if (response?.data?.length > 0) {
            listResult.add("Posted Favors");
          }
        }

        listResult.addAll(response?.data);

        if (!_loadMore) {
          if (response != null &&
              response.data != null &&
              response.data?.length < Constants.PAGINATION_SIZE) {
            _loadMore = false;
          } else {
            _loadMore = true;
          }
        }

        if (!offstagenodata) {
          if (listResult.length > 0) {
            offstagenodata = true;
          } else {
            offstagenodata = false;
          }
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
  }*/

  void _setScrollListener() {
    //scrollController.position.isScrollingNotifier.addListener(() { print("called");});

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (listResult.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitPostedApi();
          showInSnackBar("Loading data...");
        }
      }
    });
  }

  Widget buildItem(int index, Datas data) {
    return InkWell(
      onTap: () {
        providerFirebase?.changeScreen(PostFavorDetails(
          id: data?.favourId?.toString(),
          isButtonDesabled: true,
        ), rootNavigator: true);
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        margin: EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*  Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Text(
                data?.favour?.title ?? "",
                style: TextThemes.blackCirculerMedium,
              ),
            ),
            Opacity(
              opacity: 0.12,
              child: Container(
                margin: EdgeInsets.only(top: 30.0),
                height: 1.0,
                color: AppColors.dividerColor,
              ),
            ),*/
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        data?.favour?.title ?? "",
                        style: TextThemes.blackCirculerMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 7.0),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Color.fromRGBO(183, 183, 183, 1),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    providerFirebase = Provider.of<FirebaseProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "Recent Applied Favors",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppColors.whiteGray,
      body: Stack(
        children: <Widget>[
          Container(
            color: AppColors.whiteGray,
            height: getScreenSize(context: context).height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildContestList(),
              ],
            ),
          ),
          Offstage(
            offstage: offstagenodata,
            child: Container(
              height: screenSize.height,
              padding: EdgeInsets.only(bottom: 40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Image.asset(
                        AssetStrings.noPosts,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        "No Jobs",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 9, left: 20, right: 20),
                      child: Text(
                        "You don’t have any job yet.\nOnce you’re hired it will show up here.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.5,
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
            child: Center(
              child: getHalfScreenLoader(
                status: provider.getLoading(),
                context: context,
              ),
            ),
          ),
          /* Center(
            child: _getLoader,
          ),*/
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

        await hitPostedApi();
      },
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: ListView.builder(
          padding: EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (listResult[index] is Datas) {
              widgets = buildItem(index, listResult[index]);
            } else {
              widgets = Container();
            }

            return widgets;
          },
          itemCount: listResult.length,
        ),
      ),
    ));
  }

  ValueSetter<int> callback(int type) {
    currentPage = 1;
    isPullToRefresh = true;
    _loadMore = false;
    hitPostedApi();
  }

  @override
  bool get wantKeepAlive => true;
}
