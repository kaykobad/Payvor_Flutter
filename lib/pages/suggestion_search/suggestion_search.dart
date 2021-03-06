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
      StreamController<bool>();
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollControllerSuggest = ScrollController();
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
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
            var now = DateTime.now();
            var date = DateFormat("yyyy-MM-dd HH:mm:ss");

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
          child: ListView.builder(
            padding: EdgeInsets.all(0.0),
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
    print("image_url ${data.user.profilePic}");
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
              child: PostFavorDetails(
              id: data.id.toString(),
              distance: data?.distance ?? "",
            ));
          }),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: 8.0,
              color: AppColors.whiteGray,
            ),
            SizedBox(
              height: 16.0,
            ),
            buildItemSearchNew(data),
            Opacity(
              opacity: 0.12,
              child: Container(
                height: 1.0,
                margin: EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),
            data?.image != null && data.image.isNotEmpty ? Container(
              height: 147,
              width: double.infinity,
              margin:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
              child: ClipRRect(
                // margin: EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                borderRadius: BorderRadius.circular(10.0),

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
                margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  data?.title ?? "",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              width: double.infinity,
              color: Colors.white,
              child: ReadMoreText(
                data?.description ?? "",
                trimLines: 4,
                colorClickableText: AppColors.colorDarkCyan,
                trimMode: TrimMode.Line,
                style: TextStyle(
                  color: AppColors.moreText,
                  fontFamily: AssetStrings.circulerNormal,
                  fontSize: 14.0,
                ),
                trimCollapsedText: '...more',
                textAlign: TextAlign.start,
                trimExpandedText: ' less',
              ),
            ),
            SizedBox(
              height: 15.0,
            )
          ],
        ),
      ),
    );
  }

  Widget buildItemSearchNew(Datas data) {
    String distance = "";
    if (data?.distance != null) {
      distance = data?.distance;
    }

    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(shape: BoxShape.circle),
            alignment: Alignment.center,
            child: ClipOval(
              // margin: EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

              child: getCachedNetworkImageWithurl(
                  url: data.user?.profilePic ?? "", fit: BoxFit.fill, size: 40),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      children: [
                        Text(
                          data?.user?.name ?? "",
                          style: TextThemes.blackCirculerMedium,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        data?.user?.perc == 100
                            ? Image.asset(
                          AssetStrings.verify,
                          width: 16,
                          height: 16,
                        )
                            : Container(),
                      ],
                    )),
                Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                  child: Row(
                    children: [
                      Image.asset(
                        AssetStrings.locationHome,
                        width: 11,
                        height: 14,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Container(
                          child: Container(
                            child: Text(
                              data?.location + " - " + distance,
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
              child: Text(
                "???${data.price ?? "0"}",
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

    _scrollController = ScrollController();
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
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
       // backgroundColor: AppColors.bluePrimary,
        body: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 50.0,
                  ),
                  getTextField(),
                  Opacity(
                    opacity: 0.7,
                    child: Container(
                      height: 0.5,
                      margin: EdgeInsets.only(top: 16.0),
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
              color: AppColors.whiteGray,
              margin: EdgeInsets.only(top: 120),
              child: Center(
                child: Text(
                  "No Favors Found",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            )
                : Container(color: AppColors.whiteGray),


            Center(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                child: getHalfScreenLoader(
                  status: provider.getLoading(),
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTextField() {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: SvgPicture.asset(
                  AssetStrings.back,
                ),
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
                  Flexible(
                    child: TextField(
                      controller: _controller,
                      style: TextThemes.blackTextFieldNormal,
                      keyboardType: TextInputType.text,
                      keyboardAppearance: Brightness.light,
                      onSubmitted: (String value) {
                        if (value.trim().length > 0) {
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
                        if (value.trim().isEmpty) {
                          listResult.clear();
                          list.clear();
                          if (listRecent != null && listRecent.length > 0) {
                            list.addAll(listRecent);
                          }
                          setState(() {});
                        }
                        else {
                          hitSearchSuggestApi(value.trim());
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
                      _controller.text = "";
                      text = "";
                      currentPageSuggest = 1;
                      _loadMore = false;
                      isPullToRefresh = false;
                      list.clear();
                      listResult.clear();

                      if (listRecent != null && listRecent.length > 0) {
                        list.addAll(listRecent);
                      }
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
                  SizedBox(
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
            color: AppColors.whiteGray,
            child: ListView.builder(
              padding: EdgeInsets.all(0.0),
              controller: _scrollControllerSuggest,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (list[index] is String) {
                  widgets = buildItemRecent(list[index],index);
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


  Widget buildItemRecent(String keyword,int pos) {
    return Container(
      child: Column(
        children: [
          keyword == "Recent Searches" ? Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 30),
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent Searches",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: AssetStrings.circulerMedium,
                  fontSize: 18.0),
            ),
          ) : buildItemRecentSearch(keyword,pos),
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
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              "Suggested Searches",
              style: TextStyle(
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
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              AssetStrings.searchSuggest,
            ),
            SizedBox(
              width: 14,
            ),
            Expanded(
              child: Container(

                child: Text(
                  datas?.title,
                  style: TextStyle(
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

            SizedBox(
              width: 8,
            ),

            SvgPicture.asset(
              AssetStrings.pathSuggest,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemRecentSearch(String keyword,int pos) {
    return InkWell(
      onTap: () {
        _controller.text = keyword;
        isPullToRefresh = false;
        _loadMore = false;
        currentPage = 1;
        hitSearchApi(keyword);

      },
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[


              SvgPicture.asset(
                AssetStrings.recentSuggest,
              ),

              SizedBox(
                width: 14,
              ),
              Expanded(
                child: Container(

                  child: Text(
                    keyword ?? "",
                    style: TextStyle(
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

              SizedBox(
                width: 8,
              ),

              InkWell(
                onTap: ()async{
                   await DatabaseHelper.instance
                      .delete(keyword);
                   list.removeAt(pos);
                   setState(() {

                   });
                },
                child: Center(
                  child: SvgPicture.asset(
                    AssetStrings.cancelSuggest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

