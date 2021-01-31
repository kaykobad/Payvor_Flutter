import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/rating/give_rating_request.dart';
import 'package:payvor/model/report_reason/report_reason_response.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class ReportProblems extends StatefulWidget {
  final String id;

  ReportProblems({@required this.id});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ReportProblems>
    with AutomaticKeepAliveClientMixin<ReportProblems> {
  var screenSize;

  TextEditingController _DescriptionController = new TextEditingController();
  FocusNode _DesField = new FocusNode();

  List<DataReport> listRecent = List();

  Widget widgets;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();

  AuthProvider provider;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      getReportReasonApi();
    });

    super.initState();
  }

  Widget getTextField(
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      {bool obsectextType}) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      padding: new EdgeInsets.only(left: 15, right: 15, bottom: 10),
      height: 150,
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(8),
          border: new Border.all(color: AppColors.colorGray)),
      child: new TextFormField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        focusNode: focusNodeCurrent,
        maxLines: 8,
        onFieldSubmitted: (String value) {},
        decoration: new InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  _buildContestListSearch() {
    return Container(
      color: Colors.white,

      child: new ListView.builder(
        padding: new EdgeInsets.all(0.0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildItemRecent(index, listRecent[index]);
        },
        itemCount: listRecent.length,
      ),
    );
  }

  Widget getAppBarNew(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(53.0),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              new SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.white,
                child: Container(
                  margin: new EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: new EdgeInsets.only(left: 17.0, top: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: new Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: new SvgPicture.asset(
                              AssetStrings.back,
                              width: 16.0,
                              height: 16.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: new EdgeInsets.only(right: 25.0, top: 10),
                          width: getScreenSize(context: context).width,
                          child: new Text(
                            "Report a Problem",
                            style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: 0.7,
                child: new Container(
                  height: 0.5,
                  margin: new EdgeInsets.only(top: 12),
                  color: AppColors.dividerColor,
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBarNew(context),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          listRecent?.length > 0 ? SingleChildScrollView(
            child: new Container(
              color: Colors.white,
              height: getScreenSize(context: context).height,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildContestListSearch(),
                  Column(
                    children: [
                      Container(
                        margin: new EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 60),
                        alignment: Alignment.centerLeft,
                        child: new Text(
                          "Write your Problem",
                          style: new TextStyle(
                              color: Colors.black,
                              fontFamily: AssetStrings.circulerMedium,
                              fontSize: 18.0),
                        ),
                      ),
                      new SizedBox(
                        height: 15.0,
                      ),
                      getTextField(
                          "Write us about your problem here..",
                          _DescriptionController,
                          _DesField,
                          _DesField,
                          TextInputType.text,
                          AssetStrings.emailPng),
                      new SizedBox(
                        height: 90.0,
                      ),
                      Container(
                          color: Colors.white,
                          padding: new EdgeInsets.only(top: 9, bottom: 28),
                          child: getSetupButtonNew(callback, "End Favor", 16,
                              newColor: AppColors.colorDarkCyan)),
                      new SizedBox(
                        height: 40.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ) : Container(),
          new Center(
            child: Container(
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

  void callback() async {
    hitReportApi();
  }

  void callbackDone() async {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  hitReportApi() async {
    var typeId = "";
    var selected = false;


    for (var datareport in listRecent) {
      if (datareport?.isSelected ?? false) {
        selected = true;
        typeId = datareport?.id?.toString();
        break;
      }
    }

    if (!selected) {
      showInSnackBar("Please select a reason");
      return;
    }

    /* if (_rating < 1.0) {
      showInSnackBar("Please give a rating");
      return;
    }*/

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

    var request = new GiveReportRequest(
        favour_id: widget?.id?.toString(),
        type: typeId,
        description: _DescriptionController.text?.isNotEmpty
            ? _DescriptionController.text.toString()
            : "");

    var response = await provider.reportPostApi(request, context);

    if (response is ReportResponse) {
      provider.hideLoader();

      if (response != null && response?.status?.code == 200) {
        showBottomSheetSuccesss();
      }

      setState(() {});

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.messag);

      showInSnackBar(apiError.messag["message"]);
    }
  }


  getReportReasonApi() async {
    /* if (_rating < 1.0) {
      showInSnackBar("Please give a rating");
      return;
    }*/
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


    var response = await provider.getReportReason(context);

    if (response is GettingReportReason) {
      provider.hideLoader();

      if (response != null && response?.status?.code == 200) {
        var report = DataReport(id: 1, title: "");
        listRecent?.add(report);
        listRecent?.addAll(response?.data);
      }

      setState(() {});

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemRecent(int pos, DataReport report) {
    return Container(
      child: Column(
        children: [
          pos == 0
              ? Container(
            margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 5),
                  alignment: Alignment.centerLeft,
                  child: new Text(
                    "Select a reason",
                    style: new TextStyle(
                        color: Colors.black,
                        fontFamily: AssetStrings.circulerMedium,
                        fontSize: 18.0),
                  ),
                )
              : buildItemRecentSearch(pos, report),


          pos != 0 ? Opacity(
            opacity: 0.12,
            child: new Container(
              height: 1.0,
              margin:
              new EdgeInsets.only(left: 18.0, right: 18.0, top: 12),
              color: AppColors.dividerColor,
            ),
          ) : Container(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget buildItemRecentSearch(int pos, DataReport repor) {
    return InkWell(
      onTap: () {
        for (int i = 0; i < listRecent.length; i++) {
          listRecent[i].isSelected = false;
        }

        repor?.isSelected = true;
        setState(() {});
      },
      child: Container(
        padding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 12),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /* new Container(
                width: 19,
                height: 19,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: repor?.isSelected ?? false
                        ? Color.fromRGBO(255, 107, 102, 1)
                        : Color.fromRGBO(103, 99, 99, 0.3)),
                child: new Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
*/
              Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: repor?.isSelected ?? false
                      ? Colors.white
                      : Colors.transparent,
                ),
                child: Image.asset(
                  AssetStrings.checkTick,
                  width: 21,
                  height: 21,
                  color: repor?.isSelected ?? false
                      ? Color.fromRGBO(255, 107, 102, 1)
                      : Color.fromRGBO(103, 99, 99, 0.3),
                ),
              ),
              new SizedBox(
                width: 14,
              ),
              Expanded(
                child: Container(
                  child: new Text(
                    repor?.title ?? "",
                    style: new TextStyle(
                      color: repor?.isSelected ?? false
                          ? Colors.black
                          : Color.fromRGBO(103, 99, 99, 1),
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
            ],
          ),
        ),
      ),
    );
  }

  void showBottomSheetSuccesss() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
              child: Container(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86.0,
                    height: 86.0,
                    margin: new EdgeInsets.only(top: 38),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(37, 26, 101, 1),
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          //_showPopupMenu(details.globalPosition);
                        },
                        child: new SvgPicture.asset(
                          AssetStrings.check,
                          width: 42.0,
                          height: 42.0,
                          color: Colors.white,
                        )),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 40),
                    child: new Text(
                      "Favor End!",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 10, left: 35, right: 35),
                    alignment: Alignment.center,
                    child: new Text(
                      "You have ended the favor Contract.",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        height: 1.5,
                        color: Color.fromRGBO(114, 117, 112, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: getSetupButtonNew(callbackDone, "Done", 0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }
}
