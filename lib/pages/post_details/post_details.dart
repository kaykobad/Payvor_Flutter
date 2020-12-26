import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/pages/search/read_more_text.dart';
import 'package:payvor/pages/search/search_name.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/shimmers/shimmer_details.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class PostFavorDetails extends StatefulWidget {
  final String id;

  PostFavorDetails({this.id});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PostFavorDetails>
    with AutomaticKeepAliveClientMixin<PostFavorDetails> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  List<String> listOption = ["Report", "Share"];

  AuthProvider provider;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _DescriptionField = new FocusNode();

  FavourDetailsResponse favoriteResponse;

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

    var response = await provider.getFavorPostDetails(context, widget.id);

    if (response is FavourDetailsResponse) {
      provider.hideLoader();

      if (response != null && response.data != null) {
        favoriteResponse = response;
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

  @override
  bool get wantKeepAlive => true;

  void callback() {
    showBottomSheet();
  }

  Widget buildItem() {
    return Container(
      color: Colors.white,
      padding:
          new EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: new Text(
                    favoriteResponse?.data.title ?? "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(top: 4),
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
                            favoriteResponse?.data.location ?? "",
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
                "€${favoriteResponse?.data.price ?? ""}",
                style: TextThemes.blackDarkHeaderSub,
              )),
        ],
      ),
    );
  }

  Widget getBottomText(String icon, String text, double size) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: new SvgPicture.asset(
                icon,
                width: size,
                height: size,
              ),
            ),
          ),
          new SizedBox(
            width: 20.0,
          ),
          Container(
            child: new Text(
              text,
              style: TextThemes.darkBlackMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      margin: new EdgeInsets.only(top: 43, left: 27),
                      child:
                          getBottomText(AssetStrings.share, "Share Post", 22)),
                  Container(
                      margin: new EdgeInsets.only(top: 35, left: 27),
                      child:
                          getBottomText(AssetStrings.slash, "Report Post", 22)),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(top: 35, left: 27, right: 27),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                      margin: new EdgeInsets.only(top: 35, left: 24),
                      child: getBottomText(AssetStrings.cross, " Cancel", 18)),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }

  void _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    String selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, 80, 30, 0),
      items: listOption.map((String popupRoute) {
        return new PopupMenuItem<String>(
          child: new Text(popupRoute),
          value: popupRoute,
        );
      }).toList(),
      elevation: 3.0,
    );

    if (selected == "Report") {
      print("Report");
    } else {
      print("Share");
    }
  }

  Widget buildItemRating(int type, String first) {
    return InkWell(
      onTap: () {
        if (type == 1) {
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return Material(child: new ReviewPost());
            }),
          );
        } else {
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return Material(
                  child: new SearchHomeByName(
                lat: favoriteResponse?.data?.lat,
                long: favoriteResponse?.data?.long,
                description: favoriteResponse?.data?.description,
                id: favoriteResponse?.data?.id.toString(),
              ));
            }),
          );
        }
      },
      child: Container(
        padding:
            new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
        color: Colors.white,
        margin: new EdgeInsets.only(top: 4),
        child: Row(
          children: <Widget>[
            new Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 107, 102, 0.17),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: new SvgPicture.asset(
                type == 1 ? AssetStrings.shape : AssetStrings.referIcon,
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
                    child: type == 1
                        ? Row(
                            children: [
                              new SvgPicture.asset(
                                AssetStrings.star,
                              ),
                              new SizedBox(
                                width: 3,
                              ),
                              Container(
                                  child: new Text(
                                    favoriteResponse.data.ratingAvg
                                        .toString() ?? "",
                                    style: TextThemes.greyTextFieldNormalNw,
                              )),
                              Container(
                                width: 3,
                                height: 3,
                                margin: new EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.darkgrey,
                                ),
                              ),
                              Container(
                                  child: new Text(
                                    "${favoriteResponse.data.ratingCount
                                        .toString() ?? "0"} Reviews",
                                    style: TextThemes.greyTextFieldNormalNw,
                              )),
                            ],
                          )
                        : Container(
                            child: new Text(
                            "Refer someone who is good fit for the job",
                            style: TextThemes.greyTextFieldNormalNw,
                          )),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color.fromRGBO(183, 183, 183, 1.0),
                  size: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getRowsPayment(String firstText, String amount, double tops) {
    return new Container(
      color: Colors.white,
      padding: new EdgeInsets.only(left: 16, right: 16, top: tops),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(
            firstText,
            style: new TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                color: AppColors.moreText,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
          new Text(
            amount,
            style: new TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                color: Colors.black,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildItemUser() {
    return Container(
      color: Colors.white,
      padding:
          new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
      margin: new EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 50.0,
            height: 50.0,
            alignment: Alignment.center,
            child: new ClipOval(
              child: getCachedNetworkImageWithurl(
                  url: favoriteResponse.data.user.profilePic ?? "",
                  fit: BoxFit.fill,
                  size: 50),
            ),
          ),
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new Text(
                    favoriteResponse?.data.title
                        ?? "",
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 3),
                  child: Row(
                    children: [
                      Container(
                          child: new Text(
                            "Favor Post Owner",
                            style: TextThemes.greyTextFieldNormalNw,
                          )),
                      favoriteResponse?.data.isActive == 1 ? Container(
                        width: 3,
                        height: 3,
                        margin: new EdgeInsets.only(left: 4, right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkgrey,
                        ),
                      ) : Container(),
                      favoriteResponse?.data.isActive == 1 ? Container(
                          child: new Text(
                            "VERIFIED",
                            style: TextThemes.blueMediumSmallNew,
                          )) : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Container(
                child: Image.asset(AssetStrings.verify),
                width: 21,
                height: 21,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    screenSize = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: favoriteResponse != null && favoriteResponse.data != null
                ? SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    height: 214,
                    width: double.infinity,
                    child: ClipRRect(
                      // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                      borderRadius: new BorderRadius.circular(0.0),

                      child: getCachedNetworkImageRect(
                        url: favoriteResponse.data.image,
                        size: 214,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  buildItem(),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(left: 17.0, right: 17.0),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      padding: new EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        ResString().get('description'),
                        style: TextThemes.blackCirculerMediumHeight,
                      )),
                  Container(
                    padding: new EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 10.0, bottom: 18),
                    color: Colors.white,
                    width: double.infinity,
                    child: ReadMoreText(
                      favoriteResponse?.data?.description ?? "",
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
                  buildItemUser(),
                  buildItemRating(1, "User Ratings"),
                  buildItemRating(2, "Refer Others"),
                  Container(
                      color: Colors.white,
                      padding:
                      new EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
                      margin: new EdgeInsets.only(top: 4),
                      alignment: Alignment.centerLeft,
                      child: new Text(
                        ResString().get('payment_brkdown'),
                        style: TextThemes.blackCirculerMediumHeight,
                      )),
                  getRowsPayment(ResString().get('job_payment'), "€50", 23.0),
                  getRowsPayment(
                      ResString().get('payvor_service_fee'), "€50", 9.0),
                  new Container(
                    height: 13,
                    color: Colors.white,
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(left: 17.0, right: 17.0),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  new Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(
                        left: 16, right: 16, top: 9, bottom: 21),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Text(
                          ResString().get('you_all_receive'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.bluePrimary,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        new Text(
                          "€40",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.bluePrimary,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  new SizedBox(
                    height: 150.0,
                  ),
                ],
              ),
            ) : Container(),
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
                margin: new EdgeInsets.only(top: 35, left: 16, right: 5),
                child: new Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: new SvgPicture.asset(
                          AssetStrings.back,
                          width: 21.0,
                          height: 18.0,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                          onTapDown: (TapDownDetails details) {
                            _showPopupMenu(details.globalPosition);
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: new Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 32,
                              )))
                    ],
                  ),
                ),
              )),
          favoriteResponse != null && favoriteResponse.data != null
              ? Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Material(
              elevation: 18.0,
              child: Container(
                  color: Colors.white,
                  padding: new EdgeInsets.only(top: 9, bottom: 28),
                  child: getSetupButtonNew(
                      callback, ResString().get('apply_for_fav'), 16,
                      newColor: AppColors.colorDarkCyan)),
            ),
          ) : Container(),


//          new Center(
//            child: getFullScreenProviderLoader(
//              status: provider.getLoading(),
//              context: context,
//            ),
//          ),
          Visibility(visible: provider.getLoading(), child: ShimmerDetails())
          /* new Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
