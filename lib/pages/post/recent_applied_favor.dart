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
  ScrollController scrollController = new ScrollController();
  bool _loadMore = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Widget widgets;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitPostedApi();
    });
    _setScrollListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    providerFirebase = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 1,
        title: new Text(
          "Recent Applied Favors",
          style: new TextStyle(color: Colors.black, fontSize: 18),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppColors.whiteGray,
      body: Stack(
        children: <Widget>[listWidget, noJobs, loaderWidget],
      ),
    );
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

  void _setScrollListener() {
    scrollController = new ScrollController();
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

  get loaderWidget => Container(
        child: new Center(
          child: getHalfScreenLoader(
            status: provider.getLoading(),
            context: context,
          ),
        ),
      );

  get listWidget => new Container(
        color: AppColors.whiteGray,
        height: getScreenSize(context: context).height,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildContestList(),
          ],
        ),
      );

  get noJobs => Offstage(
        offstage: offstagenodata,
        child: Container(
          height: screenSize.height,
          padding: new EdgeInsets.only(bottom: 40),
          child: new Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {},
                  child: new Image.asset(
                    AssetStrings.noPosts,
                    width: 150,
                    height: 150,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(top: 10),
                  child: new Text(
                    "No Jobs",
                    style: new TextStyle(
                        color: Colors.black,
                        fontFamily: AssetStrings.circulerMedium,
                        fontSize: 17.0),
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(top: 9, left: 20, right: 20),
                  child: new Text(
                    "You don’t have any job yet.\nOnce you’re hired it will show up here.",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
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
      );

  Widget buildItem(int index, Datas data) {
    return InkWell(
      onTap: () {
        providerFirebase?.changeScreen(new PostFavorDetails(
          id: data?.favourId?.toString(),
          isButtonDesabled: true,
        ));
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        margin: new EdgeInsets.only(top: 8.0),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: new Text(
                        data?.favour?.title ?? "",
                        style: TextThemes.blackCirculerMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(left: 7.0),
                    child: new Icon(
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
        margin: new EdgeInsets.only(left: 16, right: 16),
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
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
