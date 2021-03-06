import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/my_profile_job_hire/my_profile_response.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

import 'chat/private_chat.dart';

class ChatMessageDetails extends StatefulWidget {
  final String id;
  String name;
  final String hireduserId;
  String image;
  final bool userButtonMsg;

  ChatMessageDetails(
      {this.id, this.name, this.hireduserId, this.image, this.userButtonMsg});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ChatMessageDetails>
    with AutomaticKeepAliveClientMixin<ChatMessageDetails> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      StreamController<bool>();
  ScrollController scrollController = ScrollController();

  List<String> listOption = ["Report", "Share"];

  AuthProvider provider;

  var ids = "";
  int currentPage = 1;
  bool _loadMore = false;

  ScrollController _scrollController = ScrollController();
  var isCurrentUser = false;

  bool offstageLoader = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  FocusNode _DescriptionField = FocusNode();

  //FavourDetailsResponse favoriteResponse;
  bool isPullToRefresh = false;
  bool offstagenodata = true;

  MyProfileResponse userResponse = null;
  List<Data> list = List();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  void initState() {

    Future.delayed(const Duration(milliseconds: 300), () {
      hitUserApi();
    });
    _setScrollListener();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    super.initState();
  }


  hitUserApi() async {
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

    var response = await provider.userProfileDetails(
        context, currentPage, widget?.hireduserId);

    if (response is MyProfileResponse) {
      isPullToRefresh = false;
      if (response != null && response.data != null) {
        if (currentPage == 1) {
          list.clear();
        }

        userResponse = response;
        print("user_data ${userResponse.user.toJson()}");
        widget.image = response.user.profilePic;
        widget.name = response.user.name;

        list.addAll(response.data.data);

        if (response.data != null &&
            response.data.data.length < Constants.PAGINATION_SIZE) {
          _loadMore = false;
        } else {
          _loadMore = true;
        }

        if (list.length > 0) {
          offstagenodata = true;
        } else {
          offstagenodata = false;
        }
        setState(() {

        });
      }
    } else {
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
    provider.hideLoader();
  }

  void _setScrollListener() {
    //crollController.position.isScrollingNotifier.addListener(() { print("called");});

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        print("size ${list.length}");

        if (list.length >= (Constants.PAGINATION_SIZE * currentPage)) {
          isPullToRefresh = true;
          hitUserApi();
          showInSnackBar("Loading data...");
        }
        else {
          print("not called");
        }
      }
    });
  }

  /* hitReportApi() async {
    offstageLoader = true;
    setState(() {});

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        offstageLoader = false;
        setState(() {});
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }
    var reportrequest = ReportPostRequest(
        favour_id: favoriteResponse?.data?.id?.toString());

    var response = await provider.reportUser(reportrequest, context);

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        showInSnackBar(response.status.message);
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }

    setState(() {});
  }*/
/*

  hitDeletePostApi() async {
    offstageLoader = true;
    setState(() {});

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        offstageLoader = false;
        setState(() {});
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }
    //  var reportrequest=ReportPostRequest(favour_id: favoriteResponse?.data?.id?.toString());

    var response = await provider.deletePost(
        favoriteResponse?.data?.id?.toString(), context);

    offstageLoader = false;

    if (response is ReportResponse) {
      if (response != null && response.status.code == 200) {
        showInSnackBar(response.status.message);
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }

    setState(() {});
  }
*/

  @override
  bool get wantKeepAlive => true;

  void callback() async {
    if (widget?.userButtonMsg != null && widget?.userButtonMsg) {
      var currentUserId;
      var _userName;
      var _userProfilePic;
      var userData = MemoryManagement.getUserInfo();
      if (userData != null) {
        Map<String, dynamic> data = jsonDecode(userData);
        LoginSignupResponse userResponse = LoginSignupResponse.fromJson(data);
        _userName = userResponse.user.name ?? "";
        _userProfilePic = userResponse.user.profilePic ?? "";
        currentUserId = userResponse.user.id.toString();
      }
      var screen = PrivateChat(
        peerId: widget.hireduserId,
        peerAvatar: widget.image,
        userName: widget.name,
        isGroup: false,
        currentUserId: currentUserId,
        currentUserName: _userName,
        currentUserProfilePic: _userProfilePic,
      );
      //move to private chat screen
      //widget.fullScreenWidget(screen);

      Navigator.push(
        context,
        CupertinoPageRoute(builder: (BuildContext context) {
          return Material(child: screen);
        }),
      );
    } else {
      showInSnackBar("You can't chat now");
    }
  }

  /*redirect() async {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
            child: PostFavour(
          favourDetailsResponse: favoriteResponse,
          isEdit: true,
        ));
      }),
    );
  }*/

  _buildContestList() {
    return
      /* key: _refreshIndicatorKey,
      onRefresh: () async {
          isPullToRefresh = true;
        _loadMore = false;
        currentPage = 1;

        await hitUserApi();*/

      Container(
        color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(0.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildItemNew(list[index]);
        },
        itemCount: list?.length,
      ),
    );
  }


  Widget buildItemSecondNew(Data datas) {
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
                  url: userResponse?.user?.profilePic ?? "",
                  fit: BoxFit.fill,
                  size: 40),
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
                          userResponse?.user?.name ?? "",
                          style: TextThemes.blackCirculerMedium,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        userResponse?.user?.perc == 100
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
                          child: Text(
                            userResponse?.user?.location ?? "",
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
              child: Text(
                "???${datas?.price ?? "0"}",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }

  Widget buildItemNew(Data datas) {
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(builder: (BuildContext context) {
            return Material(
                child: PostFavorDetails(
              id: datas?.id?.toString(),
              isButtonDesabled: true,
            ));
          }),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(height: 8.0, color: AppColors.whiteGray),
            SizedBox(height: 16.0),
            buildItemSecondNew(datas),
            Opacity(
              opacity: 0.12,
              child: Container(
                height: 1.0,
                margin: EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),
            datas?.image != null ? Container(
              height: 147,
              width: double.infinity,
              margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
              child: ClipRRect(
                // margin: EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                borderRadius: BorderRadius.circular(10.0),

                child: getCachedNetworkImageRect(
                  url: datas?.image ?? "",
                  fit: BoxFit.cover,
                ),
              ),
            ) : Container(),
            Container(
                width: double.infinity,
                color: Colors.white,
                margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  datas?.title ?? "",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              width: double.infinity,
              color: Colors.white,
              child: ReadMoreText(
                datas?.description ?? "",
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

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: userResponse != null
                ? SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      Container(
                        height: 165,
                        color: Colors.white,
                      ),
                      Container(
                        height: 120,
                        color: AppColors.kPrimaryBlue,
                      ),
                      Positioned(
                        bottom: 0.0,
                              width: getScreenSize(context: context).width,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color: Colors.white)),
                                child: ClipOval(
                                  // margin: EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

                                  child: getCachedNetworkImageWithurl(
                                    url: userResponse?.user?.profilePic ?? "",
                                    size: 89,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 6),
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            child: Text(
                              userResponse?.user?.name ?? "",
                              style: TextThemes.darkBlackMedium,
                            )),
                        SizedBox(
                          width: 2,
                        ),
                        userResponse?.user?.perc == 100
                                  ? Container(
                                      child: Image.asset(AssetStrings.verify),
                                      width: 20,
                                      height: 20,
                                    )
                                  : Container()
                            ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                              Image.asset(
                                AssetStrings.rating,
                                width: 13,
                                height: 13,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Container(
                                  child: Text(
                                userResponse?.user?.ratingAvg?.toString() ?? "",
                                style: TextThemes.blackTextSmallMedium,
                              )),
                              Container(
                                width: 3,
                                height: 3,
                                margin: EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.darkgrey,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  print("review_post from chat screen");
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) {
                                      return Material(
                                          child: ReviewPost(
                                        id: widget?.hireduserId?.toString() ??
                                            "",
                                      ));
                                    }),
                                  );
                                },
                                child: Container(
                                    child: Text(
                                  "${userResponse?.user?.ratingCount?.toString() ?? "0"} Reviews",
                                  style: TextThemes.blueMediumSmall,
                                )),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          elevation: 0.0,
                          child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(top: 20, bottom: 10),
                              child: getSetupButtonNewRow(
                                  callback, "Message", 16,
                                  newColor: AppColors.colorDarkCyan)),
                        ),
                        list.length > 0
                            ? Container(
                                margin: EdgeInsets.only(
                                    left: 16, right: 16, top: 22, bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "All Posts",
                                  style: TextThemes.blackCirculerMediumHeight,
                                ))
                            : Container(
                                margin: EdgeInsets.only(top: 100),
                                child: Center(

                      child: Text(
                        "No Favors Found",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),

                  ),
                  _buildContestList(),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
                  )
                : Container(),
          ),
          Offstage(
            offstage: true,
            child: Center(
              child: Text(
                "No Favors Found",
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          ),
          Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                margin: EdgeInsets.only(
                  top: 30,
                  left: 16,
                  right: 5,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*  Container(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              AssetStrings.back,
                              width: 21.0,
                              height: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
*/
                      Container(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.greyProfile.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.45),
                                  blurRadius: .4,
                                ),
                              ]),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              AssetStrings.back,
                              width: 21.0,
                              height: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Offstage(
                        offstage: true,
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                              onTapDown: (TapDownDetails details) {},
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              )),
          /*favoriteResponse ==null
              ? Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Material(
              elevation: 18.0,
              child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 9, bottom: 28),
                  child: getSetupButtonNew(
                      callback, ResString().get('apply_for_fav'), 16,
                      newColor: AppColors.colorDarkCyan)),
            ),
          )
              : Container(),*/

          Center(
            child: getHalfScreenLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
          /* Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
