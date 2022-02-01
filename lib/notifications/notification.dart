import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/rich_text_parser.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/notifications/notification_response.dart';
import 'package:payvor/pages/original_post/original_post_data.dart';
import 'package:payvor/pages/pay_feedback/pay_feedback_common.dart';
import 'package:payvor/pages/pay_feedback/pay_give_feedback.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Notifications>
    with AutomaticKeepAliveClientMixin<Notifications> {
  var screenSize;

  String searchkey;
  AuthProvider provider;
  FirebaseProvider providerFirebase;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

  List<Data> listResult = [];

  // TextEditingController _controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool _loadMore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitSearchApi();
    });
    _setScrollListener();
    super.initState();
  }

  hitSearchApi() async {
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

    var response = await provider.getNotificationList(context, currentPage);

    if (response is NotificationResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          listResult.clear();
        }

        listResult.addAll(response?.data);

        if (response != null &&
            response.data != null &&
            response.data?.length < Constants.PAGINATION_SIZE) {
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

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (listResult.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitSearchApi();
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
    providerFirebase = Provider.of<FirebaseProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
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
                        AssetStrings.empty_notification_new,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    Container(
                      child: Text(
                        "No Notifications",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 9, left: 20, right: 20),
                      child: Text(
                        "You didn't receive any notifications yet",
                        textAlign: TextAlign.center,
                        style: TextStyle(
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

            await hitSearchApi();
          },
          child: Container(
            color: AppColors.whiteGray,
            child: ListView.builder(
              padding: EdgeInsets.all(0.0),
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return buildItemMain(listResult[index]);
              },
              itemCount: listResult.length,
            ),
          ),
        ));
  }

  Color _getIconColor(int type) {
    if (type == 1) {
      return Color(0xFF32C5FF);
    } else if (type == 2) {
      return Color(0xFFFFAB00);
    } else if (type == 3) {
      return Color(0xFF18CD6A);
    } else if (type == 4) {
      return Color(0xFF7057FE);
    } else {
      return Color(0xFF637FB9);
    }
  }

  Widget buildItem(Data data) {
    String image = AssetStrings.card;

    if (data?.type == 1) {
      //hire user
      image = AssetStrings.bag;
    } else if (data?.type == 2) {
      //paid user
    } else if (data?.type == 3) {
      //rated user
      image = AssetStrings.thumbRight;
    } else if (data?.type == 4) {
      image = AssetStrings.person;
    } else {
      image = AssetStrings.thumbLeft;
    }

    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 14),
      child: Row(
        children: <Widget>[
          /* Container(
            width: 49.0,
            height: 49.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              // margin: EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

              child: getCachedNetworkImageWithurl(
                  url: data?.user?.profilePic ?? "",
                  fit: BoxFit.fill,
                  size: 49),
            ),
          ),*/

          Container(
            width: 49.0,
            height: 49.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getIconColor(data.type),
            ),
            child: Container(
              // margin: EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

              child: Image.asset(
                image,
                width: 22,
                height: 22,
                color: AppColors.whiteGray,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                data?.type != 4
                    ? Container(
                  margin: EdgeInsets.only(left: 14.0),
                  child: RichText(
                    text: TextSpan(
                      text: data?.user?.name ?? "",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: AssetStrings.circulerBoldStyle,
                          color: Color.fromRGBO(23, 23, 23, 1)),
                      children: <TextSpan>[
                        TextSpan(
                            text: " ${data?.description ?? ""}",
                            style: TextStyle(
                                fontFamily: AssetStrings.circulerNormal,
                                color: Color.fromRGBO(103, 99, 99, 1))),
                      ],
                    ),
                  ),
                )
                    : Container(
                        margin: const EdgeInsets.only(left: 14),
                        alignment: Alignment.centerLeft,
                        child: Html(
                          shrinkToFit: true,
                          data: "${data?.description}",
                          defaultTextStyle: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 16,
                            fontFamily: AssetStrings.circulerNormal,
                            color: Color(0xFF676363),
                          ),
                          customTextStyle: (dom.Node node, children) {
                            if(node is dom.Element) {
                              if(node.localName == "b") {
                                return DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 16,
                                  fontFamily: AssetStrings.circulerBoldStyle,
                                  color: Color(0xFF171717),
                                );
                              }
                            }
                            return DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 16,
                              fontFamily: AssetStrings.circulerNormal,
                              color: Color(0xFF676363),
                            );
                          },
                        ),
                      ),
                Container(
                  margin: EdgeInsets.only(left: 14.0),
                  child: Text("\"${data?.favour?.title ?? ""}\" ",
                      style: TextStyle(
                          fontFamily: AssetStrings.circulerNormal,
                          color: Color.fromRGBO(255, 107, 102, 1))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(Data data) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          InkWell(
              onTap: () {
                print("called ${data.type}");

                if (data?.type == 1) {
                  //"hire to u
                  providerFirebase?.changeScreen(PayFeebackDetailsCommon(
                    postId: data?.favourId.toString(),
                    userId: data?.userId.toString(),
                    giveFeedback: false,
                    voidcallback: null,
                    lauchCallBack: null,
                  ));
                } else if (data?.type == 2) {
                  // hire and paid favor

                  providerFirebase?.changeScreen(PayFeebackDetails(
                    postId: data?.favourId.toString(),
                    userId: data?.userId.toString(),
                    type: 1,
                    voidcallback: null,
                  ));
                } else if (data?.type == 3) {
                  print("review_post from notification screen");
                  // for rated user
                  providerFirebase?.changeScreen(Material(
                      child: ReviewPost(
                        id: data.favourId.toString() ?? "",
                      )));
                } else if (data?.type == 4) {
                  // for applied user

                  providerFirebase?.changeScreen(Material(
                      child: OriginalPostData(
                        id: data.favourId.toString(),
                      )));
                } else {
                  _redirectToFavourDetailScreen(data.favourId);
                }
              },
              child: buildItem(data)),
          Opacity(
            opacity: 1,
            child: Container(
              height: 1,
              margin: EdgeInsets.only(left: 17.0, right: 17.0, top: 14.0),
              color: Color.fromRGBO(151, 151, 151, 0.2),
            ),
          ),
        ],
      ),
    );
  }

  void _redirectToFavourDetailScreen(int favourId) {
    providerFirebase?.changeScreen(PostFavorDetails(id: favourId.toString()), rootNavigator: true);
  }
}
