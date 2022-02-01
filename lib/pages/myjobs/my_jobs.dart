import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:payvor/current_user_hired_by_favor/current_user_hire_favor.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/applied_user/favour_applied_user.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/pay_feedback/pay_feedback_common.dart';
import 'package:payvor/pages/pay_feedback/pay_give_feedback.dart';
import 'package:payvor/pages/post/recent_applied_favor.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class MyJobs extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;

  MyJobs({@required this.lauchCallBack});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyJobs> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  FirebaseProvider providerFirebase;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";

  int favourapplied = 0;

  List<Object> listResult = List();
  ScrollController scrollController =  ScrollController();
  bool _loadMore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
       GlobalKey<RefreshIndicatorState>();

  Widget widgets;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar( SnackBar(content:  Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      hitJobsPost();
    });

    _setScrollListener();
    super.initState();
  }

  hitJobsPost() async {
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

    var response = await provider.currentuserhirefavor(context, currentPage);

    provider.hideLoader();

    if (response is CurrentUserHiredByFavorResponse) {
      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          favourapplied = response?.favourapplied ?? 0;
          listResult.clear();

          if (response?.data?.length > 0) {
            listResult.add("Next Jobs");
          }
        }

        listResult.addAll(response?.data);

        if (response != null && response.data != null &&
            response?.data.length < Constants.PAGINATION_SIZE) {
          _loadMore = false;
        } else {
          _loadMore = true;
        }

        if (listResult?.length > 0) {
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
    }
  }

  hitCurrentUserHire() async {
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

    var response = await provider.favourjobapplieduser(context, currentPage);

    if (response is FavourAppliedByUserResponse) {
      provider.hideLoader();

      print("res $response");
      isPullToRefresh = false;

      if (response != null && response.data != null) {
        if (currentPage == 1) {
          if (response?.data?.data.length > 0) {
            listResult.add("Applied Jobs");
          }
        }

        listResult.addAll(response?.data?.data);


        if (!_loadMore) {
          if (response != null &&
              response?.data != null &&
              response?.data?.data.length < Constants.PAGINATION_SIZE) {
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
  }

  void _setScrollListener() {

    scrollController =  ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (listResult.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitJobsPost();
          showInSnackBar("Loading data...");
        }
      }
    });
  }

  Widget buildItemNewTop() {
    return InkWell(
      onTap: () {
        widget.lauchCallBack(Material(
            child: Material(
                child:  RecentAppliedFavor(
          lauchCallBack: widget?.lauchCallBack,
        ))));
      },
      child: Container(
        padding:  EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        margin:  EdgeInsets.only(top: 18.0, left: 18, right: 18),
        decoration:  BoxDecoration(
          borderRadius:  BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                   Container(
                    child:  Text(
                      "Recent Applied Favors ($favourapplied)",
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:  EdgeInsets.only(top: 7.0),
                    child: Container(
                      child:  Text(
                        "The favors you’ve applied recently but not hired",
                        style: TextThemes.grayNormalSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin:  EdgeInsets.only(left: 7.0),
              child:  Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: Color.fromRGBO(183, 183, 183, 1),
              ),
            )
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
      backgroundColor: AppColors.whiteGray,
      body: Stack(
        children: <Widget>[
           Container(
            color: AppColors.whiteGray,
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                favourapplied != null && favourapplied > 0
                    ? buildItemNewTop()
                    : Container(),
                _buildContestList(),
              ],
            ),
          ),
          Offstage(
            offstage: offstagenodata,
            child: Container(
              height: screenSize.height,
              padding:  EdgeInsets.only(bottom: 40),
              child:  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child:  Image.asset(
                        AssetStrings.noPosts,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    Container(
                      margin:  EdgeInsets.only(top: 10),
                      child:  Text(
                        "No Jobs",
                        style:  TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin:  EdgeInsets.only(top: 9, left: 20, right: 20),
                      child:  Text(
                        "You don’t have any job yet.\nOnce you’re hired it will show up here.",
                        textAlign: TextAlign.center,
                        style:  TextStyle(
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
            child:  Center(
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

  _buildContestList() {
    return Expanded(
        child: RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        isPullToRefresh = true;
        _loadMore = false;
        currentPage = 1;

        await hitJobsPost();
      },
      child: Container(
        margin:  EdgeInsets.only(left: 18, right: 18),
        child:  ListView.builder(
          padding:  EdgeInsets.all(0.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (listResult[index] is String) {
              widgets = buildItemHeader(listResult[index]);
            } else if (listResult[index] is DataNextJob) {
              widgets = buildItemMain(index, listResult[index]);
            } else if (listResult[index] is Datas) {
              widgets = buildItem(index, listResult[index]);
            }

            return widgets;
          },
          itemCount: listResult.length,
        ),
      ),
    ));
  }

  String getStatus(int type) {
    String data = "";

    if (type == 1) {
      data = " hired you";
    } else if (type == 2) {
      data = " ended favor";
    } else if (type == 3) {
      data = " ended favor";
    }
    return data;
  }

  Widget buildItem(int index, Datas data) {
    return InkWell(
      onTap: () {
        providerFirebase?.changeScreen( PostFavorDetails(
          id: data?.favourId?.toString(),
          isButtonDesabled: true,
        ));
      },
      child: Container(
        padding:  EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        margin:  EdgeInsets.only(top: 8.0),
        decoration:  BoxDecoration(
          borderRadius:  BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child:  Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child:  Text(
                        data?.favour?.title ?? "",
                        style: TextThemes.blackCirculerMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    margin:  EdgeInsets.only(left: 7.0),
                    child:  Icon(
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

  Widget buildItemHeader(String text) {
    return Container(
      padding:  EdgeInsets.only(top: 16, bottom: 2),
      child: Text(text, style: TextThemes.darkBlackMedium),
    );
  }

  String formatDateString(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      print("date error ${e.toString()}");
      return "";
    }
  }

  ValueSetter<int> callback(int type) {
    currentPage = 1;
    isPullToRefresh = true;
    _loadMore = false;
    hitJobsPost();
  }

  Widget buildItemMain(int index, DataNextJob data) {
    return InkWell(
      onTap: () {
        if (data?.status == 1) {
          widget.lauchCallBack(Material(
              child: Material(
                  child:  PayFeebackDetailsCommon(
            lauchCallBack: widget?.lauchCallBack,
            userId: data?.hiredUserId?.toString(),
            postId: data?.id?.toString(),
            giveFeedback: false,
            voidcallback: callback,
            userType: Constants.EMPLOYER,
            paidUnpaid: 1,
          ))));
        } else {
          widget.lauchCallBack( PayFeebackDetails(
            userId: data?.hiredUserId?.toString(),
            postId: data?.id?.toString(),
            type: 1,
            voidcallback: callback,
            userType: Constants.EMPLOYER,
            paidUnpaid: 1,
          ));
        }
      },
      child: Container(
        padding:  EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        margin:  EdgeInsets.only(top: 18.0),
        decoration:  BoxDecoration(
          borderRadius:  BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                 Container(
                    width: 49.0,
                    height: 49.0,
                    decoration:  BoxDecoration(
                      color: Colors.grey,
                      border:  Border.all(color: Colors.white, width: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: getCachedNetworkImageWithurl(
                          url: data?.hiredBy?.profile_pic ?? "", size: 49),
                    )),
                Expanded(
                  child: Container(
                    margin:  EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                         Container(
                          child:  Text(
                            data?.title ?? "",
                            style: TextThemes.blackCirculerMedium,
                          ),
                        ),
                        Container(
                          margin:  EdgeInsets.only(top: 6.0),
                          child: Container(
                            child:  Text(
                              data?.hiredBy?.name ?? "someone",
                              style: TextStyle(
                                fontFamily: AssetStrings.circulerNormal,
                                fontSize: 15,
                                color: Color(0xFF676363),
                              ),
                            ),
                          ),
                          // child:  Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     InkWell(
                          //       onTap: () {
                          //         widget.lauchCallBack(Material(
                          //             child: Material(
                          //                 child:  ChatMessageDetails(
                          //           id: data.userId.toString(),
                          //           name: data.hiredBy.name,
                          //           hireduserId: data?.userId?.toString(),
                          //           image: data?.image,
                          //           userButtonMsg: true,
                          //         ))));
                          //       },
                          //       child: Container(
                          //         child:  Text(
                          //           data?.hiredBy?.name ?? "someone",
                          //           style: TextThemes.cyanTextSmallMedium,
                          //         ),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       child: Container(
                          //         margin:  EdgeInsets.only(left: 1.0),
                          //         child: InkWell(
                          //           onTap: () {},
                          //           child: Container(
                          //             margin:  EdgeInsets.only(left: 1.0),
                          //             child:  Text(
                          //               getStatus(data?.status),
                          //               style: TextThemes.grayNormalSmall,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Opacity(
              opacity: 0.12,
              child:  Container(
                margin:  EdgeInsets.only(top: 16.0),
                height: 1.0,
                color: AppColors.dividerColor,
              ),
            ),
            Container(
              margin:  EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                     Text(
                      "€ ${data?.price ?? ""}",
                      style:  TextStyle(
                        color: AppColors.bluePrimary,
                        fontSize: 16,
                        fontFamily: AssetStrings.circulerBoldStyle,
                      ),
                    ),
                    Expanded(
                      child:  Container(),
                    ),
                    Container(
                      height: 24,
                      width: 74,
                      decoration: BoxDecoration(
                        color: data?.status == 1 ? Color(0x1AFFAB00) : Color(0x1A28D175),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:  Center(
                        child: Text(
                          data?.status == 1 ? "Not Paid" : "Paid",
                          style:  TextStyle(
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 14,
                            color: data?.status == 1 ? Color(0xFFFFAB00) : Color(0xFF28D175),
                          ),
                        ),
                      ),
                    ),
                  ],
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
}
