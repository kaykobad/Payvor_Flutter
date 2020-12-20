import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/filter/filter.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/pages/get_favor_list/favor_list_response.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class SearchCompany extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchCompany>
    with AutomaticKeepAliveClientMixin<SearchCompany> {
  var screenSize;

  String searchkey = null;

  List<Data> list = List<Data>();

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  TextEditingController _controller = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  bool _loadMore = false;
  AuthProvider provider;
  bool isPullToRefresh = false;

  int currentPage = 0;

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

    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi();
    });

    super.initState();
  }


  hitApi() async {
    provider.setLoading();

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

    var response = await provider.getFavorList(context);

    if (response is GetFavorListResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        list.addAll(response.data);
      }

      print(response);
      try {

      } catch (ex) {

      }
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
    /* scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (list.length >= (PAGINATION_SIZE * _currentPageNumber)) {
          isPullToRefresh=true;
          _loadHomeData();
          showInSnackBar("Loading data...");
        }
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    screenSize = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bluePrimary,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.bluePrimary,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new SizedBox(
                  height: 70.0,
                ),
                Container(
                    padding: new EdgeInsets.only(left: 16.0, right: 16.0),
                    child: new Text(
                      "Find your favors",
                      style: TextThemes.whiteMedium,
                    )),
                new SizedBox(
                  height: 16.0,
                ),
                getTextField(),
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
          new Center(
            child: getFullScreenProviderLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  Widget getTextField() {
    return Container(
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
                onSubmitted: (String value) {},
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
              Navigator.push(
                context,
                new CupertinoPageRoute(builder: (BuildContext context) {
                  return Material(child: new Filter());
                }),
              );
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

  _buildContestList() {
    return Expanded(
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          isPullToRefresh = true;
          _loadMore = false;
          await hitApi();
        },
        child: Container(
          color: AppColors.whiteGray,
          child: new ListView.builder(
            padding: new EdgeInsets.all(0.0),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return buildItemMain(index, list[index]);
            },
            itemCount: list.length,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(int pos, Data data) {
    var index = pos % 2 == 0 ? true : false;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return Material(child: new PostFavorDetails(
              id: data.id.toString(),
            ));
          }),
        );
      },
      child: Container(
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
            index
                ? new Container(
                    height: 147,
                    width: double.infinity,
                    margin:
                        new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
                    child: ClipRRect(
                      // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                      borderRadius: new BorderRadius.circular(10.0),

                      child: getCachedNetworkImageWithurl(
                        url:
                            "https://cdn.pixabay.com/photo/2013/07/21/13/00/rose-165819__340.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(),
            Container(
                margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
                alignment: Alignment.centerLeft,
                child: new Text(
                  "Help me move out of my flat",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              child: ReadMoreText(
                "I need help moving out of my flat as there are many things to carry. Can someone help me out? It should not take more than 2 hours since I don’t have that many belongings,I need help moving out of my flat as there are many things to carry.",
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

/*

         new SizedBox(
              height: 50.0,
            )
*/
          ],
        ),
      ),
    );
  }
}

Widget buildItem(Data data) {
  return Container(
    margin: new EdgeInsets.only(left: 16.0, right: 16.0),
    child: Row(
      children: <Widget>[
        new Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(

              shape: BoxShape.circle
          ),
          alignment: Alignment.center,
          child: ClipOval(
            // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

            child: getCachedNetworkImageWithurl(
                url:
                data.image,
                fit: BoxFit.fill,
                size: 40
            ),
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
                        data?.title,
                        style: TextThemes.blackCirculerMedium,
                      ),
                      new SizedBox(
                        width: 8,
                      ),
                      new Image.asset(
                        AssetStrings.verify,
                        width: 16,
                        height: 16,
                      ),
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
                          data?.location ?? "",
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
              "€${data.price ?? "0"}",
              style: TextThemes.blackDarkHeaderSub,
            )),
      ],
    ),
  );
}
