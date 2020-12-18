import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/themes_styles.dart';

class PostFavour extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PostFavour>
    with AutomaticKeepAliveClientMixin<PostFavour> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _TitleController = new TextEditingController();
  TextEditingController _PriceController = new TextEditingController();
  TextEditingController _DescriptionController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _TitleField = new FocusNode();
  FocusNode _PriceField = new FocusNode();
  FocusNode _DescriptionField = new FocusNode();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    _setScrollListener();

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void _setScrollListener() {}

  Widget getTextField(
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      int lines) {
    return Container(
      padding: new EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      color: Colors.white,
      child: new TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        focusNode: focusNodeCurrent,
        maxLines: lines,
        onSubmitted: (String value) {
          if (focusNodeCurrent == _DescriptionField) {
            _DescriptionField.unfocus();
          } else {
            FocusScope.of(context).autofocus(focusNodeNext);
          }
        },
        decoration: new InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  void callback() {}

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    color: Colors.white,
                    height: 36.0,
                  ),
                  Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(top: 36.0),
                    margin: new EdgeInsets.only(left: 17.0, right: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                AssetStrings.cross,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            ResString().get('post_favour'),
                            style: TextThemes.darkBlackMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          child: new Text(
                            "",
                            style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                color: AppColors.redLight,
                                fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    color: Colors.white,
                    height: 16.0,
                  ),
                  new Container(
                    color: Colors.white,
                    width: double.infinity,
                    margin: new EdgeInsets.only(top: 9.0),
                    padding: new EdgeInsets.only(
                        left: 16, right: 16, top: 36, bottom: 33),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: new Image.asset(
                            AssetStrings.camera,
                            width: 34.0,
                            height: 30.0,
                          ),
                        ),
                        Container(
                          padding: new EdgeInsets.only(top: 10),
                          child: new Text(
                            ResString().get('upload_photo'),
                            style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                color: AppColors.bluePrimary,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        new Text(
                          ResString().get('photo_not_mandetry'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  new SizedBox(
                    height: 8.0,
                  ),
                  getTextField(ResString().get('title'), _TitleController,
                      _TitleField, _PriceField, TextInputType.emailAddress, 1),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  getTextField(
                      ResString().get('price'),
                      _PriceController,
                      _PriceField,
                      _DescriptionField,
                      TextInputType.emailAddress,
                      1),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  getTextField(
                      ResString().get('description'),
                      _DescriptionController,
                      _DescriptionField,
                      _DescriptionField,
                      TextInputType.emailAddress,
                      8),
                  new SizedBox(
                    height: 9.0,
                  ),
                  new Container(
                    color: Colors.white,
                    height: 64.0,
                    margin: new EdgeInsets.only(top: 9.0),
                    padding: new EdgeInsets.only(left: 16, right: 16),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Text(
                          ResString().get('location'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        new Text(
                          ">",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
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
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Material(
              elevation: 18.0,
              child: Container(
                  color: Colors.white,
                  padding: new EdgeInsets.only(
                      top: 9, bottom: 28, left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: getSetupButtonBorderNew(
                            callback, ResString().get('preview_favor'), 0,
                            border: Color.fromRGBO(103, 99, 99, 0.19),
                            newColor: Color.fromRGBO(248, 248, 250, 1.0),
                            textColor: Colors.black),
                      ),
                      new SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: getSetupButtonNew(
                            callback, ResString().get('apply_filters'), 0,
                            newColor: AppColors.colorDarkCyan),
                      ),
                    ],
                  )),
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
