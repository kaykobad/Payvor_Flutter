import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:payvor/localdb/DatabaseHelper.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/recentsearch.dart';
import 'package:payvor/model/suggest/suggest_response.dart';
import 'package:payvor/pages/get_favor_list/favor_list_response.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class SearchHomeByName extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchHomeByName>
    with AutomaticKeepAliveClientMixin<SearchHomeByName> {
  var screenSize;

  String searchkey = null;
  List<Object> list = List();
  List<String> listRecent = List();
  List<Datas> listResult = List();
  Widget widgets;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  TextEditingController _controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  ScrollController _scrollControllerSuggest = new ScrollController();
  int count = 0;

  bool _loadMore = false;
  bool _loadMoreSuggest = false;
  AuthProvider provider;
  bool isPullToRefresh = false;
  bool isPullToRefreshSuggest = false;

  bool offstagenodata = false;

  int currentPage = 1;
  int currentPageSuggest = 1;

  String text = "";
  String title = "";

  bool isSearchCalled = true;

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

    getDbResult();

    super.initState();
  }


  getDbResult() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .queryAllRows();
    if (data != null && data.length > 0) {
      listRecent.add("Recent Searches");
    }
    for (var item in data) {
      item.forEach((k, v) {
        if (k == "keyword") {
          if (!listRecent.contains(v)) {
            listRecent.add(v);
          }
        }
      });
    }
    list.addAll(listRecent);
    setState(() {

    });
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

    var response = await provider.getSearchList(data, context, currentPage);

    if (response is GetFavorListResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          try {
            var now = new DateTime.now();
            var date = new DateFormat("yyyy-MM-dd HH:mm:ss");

            var createAt = date.format(now);

            RecentSearch recentSearch = RecentSearch(
                createdAt: createAt, keyword: data);
            var datas = DatabaseHelper.instance.database;
            DatabaseHelper.instance.insert(recentSearch);
          } catch (e) {

          };

          listResult.clear();
        }

        listResult.addAll(response.data.data);

        if (response.data != null &&
            response.data.data != null &&
            response.data.data.length < Constants.PAGINATION_SIZE) {
          _loadMore = false;
        } else {
          _loadMore = true;
        }

        if (listResult.length > 0) {
          offstagenodata = true;
        } else {
          offstagenodata = false;
        }

        isSearchCalled = false;

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

  _buildContestListSearch() {
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
          color: AppColors.whiteGray,
          child: new ListView.builder(
            padding: new EdgeInsets.all(0.0),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return buildItemSearch(index, listResult[index]);
            },
            itemCount: listResult.length,
          ),
        ),
      ),
    );
  }

  Widget buildItemSearch(int pos, Datas data) {
    print("image_url ${data.image}");
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
                child: new PostFavorDetails(
              id: data.id.toString(),
            ));
          }),
        );
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
            buildItemSearchNew(data),
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),
            data?.image != null && data.image.isNotEmpty ? new Container(
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

  Widget buildItemSearchNew(Datas data) {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          new Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(shape: BoxShape.circle),
            alignment: Alignment.center,
            child: ClipOval(
              // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

              child: getCachedNetworkImageWithurl(
                  url: data.user?.profilePic ?? "", fit: BoxFit.fill, size: 40),
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
                          data?.user?.name ?? "",
                          style: TextThemes.blackCirculerMedium,
                        ),
                        new SizedBox(
                          width: 8,
                        ),
                        data?.user?.isActive == 1
                            ? new Image.asset(
                                AssetStrings.verify,
                                width: 16,
                                height: 16,
                              )
                            : Container(),
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
                      Expanded(
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

  hitSearchSuggestApi(String data) async {
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

    if (!isPullToRefreshSuggest) {
      provider.setLoading();
    }

    if (_loadMoreSuggest) {
      currentPageSuggest++;
    } else {
      currentPageSuggest = 1;
    }

    var response =
        await provider.getSearchSuggestList(data, context, currentPageSuggest);

    if (response is SuggestSearchResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefreshSuggest = false;

      if (response != null && response.data != null) {
        if (currentPageSuggest == 1) {
          list.clear();
        }

        list.addAll(response.data.data);

        if (listRecent != null && listRecent.length > 0) {
          listRecent.remove(list);
        }
        list.addAll(listRecent);

        if (response.data != null &&
            response.data.data != null &&
            response.data.data.length < Constants.PAGINATION_SIZE_NEW) {
          _loadMoreSuggest = false;
        } else {
          _loadMoreSuggest = true;
        }

        if (list.length > 0) {
          offstagenodata = true;
        } else {
          offstagenodata = false;
        }

        isSearchCalled = true;

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
    //crollController.position.isScrollingNotifier.addListener(() { print("called");});

    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        print("size ${listResult.length}");

        if (listResult.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitSearchApi(title);
          showInSnackBar("Loading data...");
        } else {
          print("not called");
        }
      }
    });

    _scrollControllerSuggest.addListener(() {
      if (_scrollControllerSuggest.position.maxScrollExtent ==
          _scrollControllerSuggest.offset) {
        print("size ${list.length}");

        if (list.length >=
            (Constants.PAGINATION_SIZE_NEW * currentPageSuggest)) {
          isPullToRefreshSuggest = true;
          hitSearchSuggestApi(text);
          showInSnackBar("Loading data...");
        } else {
          print("not called");
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
                isSearchCalled
                    ? _buildContestList()
                    : _buildContestListSearch(),
              ],
            ),
          ),


          listResult.length == 0 && list.length == 0 ? Container(
            margin: new EdgeInsets.only(top: 120),
            child: new Center(
              child: new Text(
                "No Favors Found",
                style: new TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          )
              : Container(),


          new Center(
            child: Container(
              margin: new EdgeInsets.only(top: 50),
              child: getHalfScreenLoader(
                status: provider.getLoading(),
                context: context,
              ),
            ),
          ),
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
                      onSubmitted: (String value) {
                        if (value
                            .trim()
                            .length > 0) {
                          isPullToRefresh = false;
                          _loadMore = false;
                          currentPage = 1;
                          text = value;
                          title = value;

                          hitSearchApi(title);
                        }
                      },
                      onChanged: (String value) {
                        currentPageSuggest = 1;
                        isPullToRefreshSuggest = false;
                        _loadMoreSuggest = false;

                        text = value;
                        if (value
                            .trim()
                            .isEmpty) {
                          listResult.clear();
                          list.clear();
                          if (listRecent != null && listRecent.length > 0) {
                            list.addAll(listRecent);
                          }
                          setState(() {

                          });
                        }
                        else {
                          hitSearchSuggestApi(value.trim());
                        }
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
                      _controller.text = "";
                      ;
                      text = "";
                      currentPageSuggest = 1;
                      _loadMore = false;
                      isPullToRefresh = false;
                      list.clear();
                      listResult.clear();

                      if (listRecent != null && listRecent.length > 0) {
                        list.addAll(listRecent);
                      }
                      setState(() {

                      });
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
            isPullToRefreshSuggest = true;
            _loadMoreSuggest = false;
            currentPageSuggest = 1;
            await hitSearchSuggestApi(text);
          },
          child: Container(
            color: Colors.white,
            child: new ListView.builder(
              padding: new EdgeInsets.all(0.0),
              controller: _scrollControllerSuggest,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (list[index] is String) {
                  widgets = buildItemRecent(list[index]);
                }
                else {
                  widgets = buildItemMain(index);
                }

                return widgets;
              },
              itemCount: list.length,
            ),
          ),
        )
    );
  }

  @override
  bool get wantKeepAlive => true;


  Widget buildItemRecent(String pos) {
    return Container(
      child: Column(
        children: [
          pos == "Recent Searches" ? Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 30),
            alignment: Alignment.centerLeft,
            child: new Text(
              "Recent Searches",
              style: new TextStyle(
                  color: Colors.black,
                  fontFamily: AssetStrings.circulerMedium,
                  fontSize: 18.0),
            ),
          ) : buildItemRecentSearch(pos),
        ],
      ),
    );
  }


  Widget buildItemMain(int pos) {
    print("data $count");

    count = count + 1;

    DataTile data = list[pos];

    return Container(
      child: Column(
        children: [
          pos == 0 ? Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            alignment: Alignment.centerLeft,
            child: new Text(
              "Suggested Searches",
              style: new TextStyle(
                  color: Colors.black,
                  fontFamily: AssetStrings.circulerMedium,
                  fontSize: 18.0),
            ),
          ) : Container(),
          buildItem(data),
        ],
      ),
    );
  }

  Widget buildItem(DataTile datas) {
    return InkWell(
      onTap: () {
        isPullToRefreshSuggest = false;
        _loadMore = false;


        title = datas.title;
        hitSearchApi(title);
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new SvgPicture.asset(
              AssetStrings.searchSuggest,
            ),
            new SizedBox(
              width: 14,
            ),
            Expanded(
              child: Container(

                child: new Text(
                  datas?.title,
                  style: new TextStyle(
                    color: Colors.black,
                    fontFamily: AssetStrings.circulerNormal,
                    fontSize: 15,

                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,

                ),
              ),
            ),

            new SizedBox(
              width: 8,
            ),

            new SvgPicture.asset(
              AssetStrings.pathSuggest,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemRecentSearch(String pos) {
    return InkWell(
      onTap: () {
        _controller.text = pos;
        isPullToRefresh = false;
        _loadMore = false;
        currentPage = 1;
        hitSearchApi(pos);
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 24),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[


              new SvgPicture.asset(
                AssetStrings.recentSuggest,
              ),

              new SizedBox(
                width: 14,
              ),
              Expanded(
                child: Container(

                  child: new Text(
                    pos ?? "",
                    style: new TextStyle(
                      color: Colors.black,
                      fontFamily: AssetStrings.circulerNormal,
                      fontSize: 15,

                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,

                  ),
                ),
              ),

              new SizedBox(
                width: 8,
              ),

              new SvgPicture.asset(
                AssetStrings.cancelSuggest,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

