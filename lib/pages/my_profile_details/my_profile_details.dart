import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/common_response/favour_end_job_response.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class MyProfileDetails extends StatefulWidget {
  final String postId;
  final int type;
  final ValueSetter<int> voidcallback;

  MyProfileDetails({this.postId,
      this.type,
      this.voidcallback});

/*  final String id;

  PostFavorDetails({this.id});*/

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyProfileDetails>
    with AutomaticKeepAliveClientMixin<MyProfileDetails> {
  var screenSize;

  FirebaseProvider firebaseProvider;

  ScrollController scrollController = new ScrollController();

  AuthProvider provider;

  var ids = "";

  var isCurrentUser = false;

  bool offstageLoader = false;
  int type = 1;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _DescriptionField = new FocusNode();

  EndedJobFavourResponse hiredUserDetailsResponse;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {

    Future.delayed(const Duration(milliseconds: 300), () {
      hitApi();
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    super.initState();
  }

  ValueSetter<int> callbackApi(int type) {
    widget.voidcallback(1);
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

    var response = await provider.getFavorPostDetailsProfile(
        context, widget?.postId?.toString());

    if (response is EndedJobFavourResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        hiredUserDetailsResponse = response;
      }
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  void callback() async {
    if (widget.type == 0 && type == 0) {
      showInSnackBar("Please select payment type");

      return;
    }

    /*  await Future.delayed(Duration(milliseconds: 200));
    showInSnackBar("Favour applied successfully");
    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context); //back to previous screen
   // showBottomSheet();*/
  }

  redirect() async {
    /*  Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
            child: new PostFavour(
          favourDetailsResponse: favoriteResponse,
          isEdit: true,
        ));
      }),
    );*/
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

  Widget buildItemRating(int type, String first) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
        color: Colors.white,
        margin: new EdgeInsets.only(top: 4, bottom: 4),
        child: Row(
          children: <Widget>[
            new Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                  color: type == 1
                      ? Color.fromRGBO(222, 248, 236, 1)
                      : Color.fromRGBO(255, 107, 102, 0.17),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: new Image.asset(
                type == 1 ? AssetStrings.checkTick : AssetStrings.combine_shape,
                height: 18,
                width: 18,
              ),
            ),
            Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Text(
                      first,
                      style: TextThemes.blackCirculerMedium,
                    ),
                  ),
                  Container(
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                    child: Container(
                        child: new Text(
                      type == 1 ? "Owner has ended the favor" : "Hiring Date",
                      style: TextThemes.greyTextFieldNormalNw,
                    )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(int type, Rating data) {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 32.0,
            height: 32.0,
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: new ClipOval(
              child: getCachedNetworkImageWithurl(
                  url: type == 1
                      ? hiredUserDetailsResponse?.data?.user?.profilePic ?? ""
                      : hiredUserDetailsResponse?.data?.hiredUser?.profilePic ??
                          "",
                  fit: BoxFit.cover,
                  size: 32),
            ),
          ),
          Expanded(
            child: Container(
              margin: new EdgeInsets.only(left: 8.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Text(
                    type == 1
                        ? hiredUserDetailsResponse?.data?.user?.name ?? ""
                        : hiredUserDetailsResponse?.data?.hiredUser?.name ?? "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                  Container(
                      child: new Text(
                        type == 1 ? "Post Owner" : "Favor Helper",
                    style: TextThemes.lightGrey,
                  )),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                    margin: new EdgeInsets.only(top: 1.2),
                    child: new Text(
                      data?.rating?.toString() ?? "0",
                      style: TextThemes.blackPreview,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget buildItemMain(int type, Rating data) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildItem(type, data),
          Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
            child: ReadMoreText(
              data?.description ?? "",
              trimLines: 8,
              colorClickableText: AppColors.colorDarkCyan,
              trimMode: TrimMode.Line,
              style: new TextStyle(
                color: AppColors.moreText,
                fontFamily: AssetStrings.circulerNormal,
                height: 1.6,
                fontSize: 14.0,
              ),
              trimCollapsedText: '...more',
              trimExpandedText: ' less',
            ),
          ),
          Opacity(
            opacity: 0.12,
            child: new Container(
              height: 1.0,
              margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 11.0),
              color: AppColors.dividerColor,
            ),
          ),
          /* new SizedBox(
            height: 16.0,
          ),*/
        ],
      ),
    );
  }

/*
  _buildContestList() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        */
/*  isPullToRefresh = true;
        _loadMore = false;
        currentPage = 1;

        await hitSearchApi(title);*/ /*

      },
      child: Container(
        color: Colors.white,
        padding: new EdgeInsets.only(top: 10),
        child: new ListView.builder(
          padding: new EdgeInsets.all(0.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return buildItemMain(index);
          },
          itemCount: 8,
        ),
      ),
    );
  }
*/

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: hiredUserDetailsResponse != null
                ? SingleChildScrollView(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          height: 40,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Container(
                                    height: 96.0,
                                    width: 96.0,
                                    child: ClipOval(
                                      child: getCachedNetworkImageWithurl(
                                        url: hiredUserDetailsResponse
                                                ?.data?.user?.profilePic ??
                                            "",
                                        size: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  new Container(
                                    height: 96.0,
                                    width: 96.0,
                                    child: ClipOval(
                                      child: getCachedNetworkImageWithurl(
                                        url: hiredUserDetailsResponse
                                                ?.data?.hiredUser?.profilePic ??
                                            "",
                                        size: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: new Container(
                                    margin: new EdgeInsets.only(top: 31),
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: InkWell(
                                            onTap: () {},
                                            child: new Padding(
                                              padding:
                                                  const EdgeInsets.all(1.5),
                                              child: new Image.asset(
                                                AssetStrings.chatSend,
                                                width: 32,
                                                height: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0.0,
                                          right: 0.0,
                                          child: InkWell(
                                            onTap: () {},
                                            child: new Container(
                                              margin:
                                                  new EdgeInsets.only(top: 7.3),
                                              child: new Image.asset(
                                                AssetStrings.combineUser,
                                                width: 16,
                                                height: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    width: 32,
                                    height: 32),
                              )
                            ],
                          ),
                        ),
                        new Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: new EdgeInsets.only(top: 16.0),
                          color: Colors.white,
                          child: new Text(
                            hiredUserDetailsResponse?.data?.title ??
                                "Test Project",
                            style: TextThemes.blackCirculerLarge,
                          ),
                        ),
                        new Container(
                          height: 22,
                          color: Colors.white,
                        ),
                        Opacity(
                          opacity: 0.12,
                          child: new Container(
                            height: 1.0,
                            margin:
                                new EdgeInsets.only(left: 17.0, right: 17.0),
                            color: AppColors.dividerColor,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              new CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                return Material(
                                    child: new PostFavorDetails(
                                  id: widget?.postId,
                                  isButtonDesabled: true,
                                ));
                              }),
                            );
                          },
                          child: new Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: new EdgeInsets.only(top: 14.0, bottom: 14),
                            color: Colors.white,
                            child: new Text(
                              "View Original Post",
                              style: TextThemes.blueTextFieldMedium,
                            ),
                          ),
                        ),
                        buildItemRating(
                            2,
                            formatDateString(hiredUserDetailsResponse
                                ?.data?.hireDate
                                ?.toString())),
                        hiredUserDetailsResponse?.data?.postUserRat != null
                            ? buildItemMain(
                                1, hiredUserDetailsResponse?.data?.postUserRat)
                            : Container(),
                        hiredUserDetailsResponse?.data?.jobUserRat != null
                            ? buildItemMain(
                                2, hiredUserDetailsResponse?.data?.jobUserRat)
                            : Container(),
                        new SizedBox(
                          height: 50.0,
                        ),
                      ],
                    ),
                  )
                : Container(),
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
          Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                margin: new EdgeInsets.only(
                  top: 30,
                  left: 16,
                  right: 5,
                ),
                child: new Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          padding: new EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: new SvgPicture.asset(
                              AssetStrings.back,
                              width: 18.0,
                              height: 18.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Container()
                    ],
                  ),
                ),
              )),
          new Center(
            child: getHalfScreenLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
          /* new Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
