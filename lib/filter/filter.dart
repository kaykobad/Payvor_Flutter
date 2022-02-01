import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/filter/data.dart';
import 'package:payvor/filter/filter_request.dart';
import 'package:payvor/model/category/category_response.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class Filter extends StatefulWidget {
  ValueSetter<FilterRequest> voidcallback;
  FilterRequest filterRequest;

  Filter({this.voidcallback, this.filterRequest});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Filter>
    with AutomaticKeepAliveClientMixin<Filter> {
  var screenSize;
  ScrollController scrollController = new ScrollController();
  List<DataCategory> categoryList = [];
  String text = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _currentSliderValue = 0.0;
  var _paymentMin = 0;
  var _paymentMax = 100;
  AuthProvider authProvider;
  List<DataModel> list = [];
  RangeValues _currentRangeValues = RangeValues(0, 100);

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    _setScrollListener();

    var data = DataModel(
        name: "Most Recent", isSelect: false, sendTitle: "most_recent", id: 1);
    var data1 = DataModel(
        name: "Nearest to me",
        isSelect: false,
        sendTitle: "nearest_location",
        id: 2);
    var data2 = DataModel(
        name: "Cheapest",
        isSelect: false,
        sendTitle: "price_low_to_high",
        id: 3);
    var data3 = DataModel(
        name: "Most Expensive",
        isSelect: false,
        sendTitle: "price_high_to_low",
        id: 4);
    list.add(data);
    list.add(data1);
    list.add(data2);
    list.add(data3);

    if (widget.filterRequest != null) {
      if (widget.filterRequest.list != null) {
        list.clear();
        list.addAll(widget.filterRequest.list);
      }

      for (var data in list) {
        if (data?.isSelect != null && data?.isSelect) {
          text = data?.name;
        }
      }

      _paymentMin = widget.filterRequest.minprice ?? 0;
      _paymentMax = widget.filterRequest.maxprice ?? 100;
      _currentRangeValues =
          RangeValues(_paymentMin?.toDouble(), _paymentMax?.toDouble());
      _currentSliderValue = widget.filterRequest.distance?.toDouble() ?? 0.0;
    }

    Future.delayed(new Duration(microseconds: 2000), () {
      getCategory();
      print("call fun");
    });

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void _setScrollListener() {}

  void getCategory() {
    var data = MemoryManagement.getCategory() ?? "";
    if (data?.isNotEmpty) {
      var infoData = jsonDecode(data);
      var catData = CategoryResponse.fromJson(infoData);
      categoryList?.addAll(catData?.data);
      print("cat ${categoryList?.length}");
      setSelectCategory();
      setState(() {});
    } else {
      setCategory();
    }
  }

  void setCategory() async {
    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {},
      onSuccess: () {},
    );

    if (gotInternetConnection) {
      var response = await authProvider.setCategory(context);
      if (response is CategoryResponse) {
        MemoryManagement.setCategory(userInfo: jsonEncode(response));
        categoryList?.clear();
        categoryList?.addAll(response?.data);
        setSelectCategory();
        print("cat ${categoryList?.length}");
        setState(() {});
      }
    }
  }

  void setSelectCategory() {
    if (widget.filterRequest != null) {
      if (widget.filterRequest.listCategory != null &&
          widget.filterRequest.listCategory.length > 0) {
        for (var dataitem in widget.filterRequest.listCategory) {
          for (var data in categoryList) {
            if (dataitem == data?.id?.toString()) {
              data?.isSelect = true;
            }
          }
        }
      }

      setState(() {});
    }
  }

  Iterable<Widget> get categoryWidget sync* {
    for (DataCategory data in categoryList) {
      yield InkWell(
          onTap: () {
            if (data.isSelect == null) {
              data.isSelect = false;
            }
            data.isSelect = !data.isSelect;

            setState(() {});
          },
          child: Container(
            margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            padding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(26.0),
                border: new Border.all(color: AppColors.desabledGray)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new Container(
                  width: 24,
                  height: 24,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: data?.isSelect != null && data?.isSelect
                          ? AppColors.colorDarkCyan
                          : Colors.transparent,
                      border: new Border.all(
                          color: data?.isSelect != null && data?.isSelect
                              ? Colors.transparent
                              : AppColors.desabledGray)),
                  child: new Icon(
                    Icons.check,
                    color: AppColors.kWhite,
                    size: 16,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 5),
                  child: Text(
                    data.name,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: AssetStrings.circulerNormal),
                  ),
                ),
              ],
            ),
          ));
    }
  }

  buildContestListSearch(StateSetter setState) {
    return Container(
      child: new ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildItemRecentSearch(index, list[index], setState);
        },
        itemCount: list.length,
      ),
    );
  }

  Widget buildItemRecentSearch(
      int index, DataModel data, StateSetter setStateMain) {
    return InkWell(
      onTap: () {
        for (var localData in list) {
          localData?.isSelect = false;
        }
        data?.isSelect = true;
        text = data?.name;

        setStateMain(() {});

        setState(() {});

        Navigator.pop(context);
      },
      child: new Container(
        padding: new EdgeInsets.only(top: 15, left: 20, right: 20),
        child: Column(
          children: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: new EdgeInsets.only(left: 5),
                  child: Text(
                    data.name,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: AssetStrings.circulerNormal),
                  ),
                ),
                new Container(
                  child: data?.isSelect
                      ? new Icon(
                    Icons.radio_button_checked,
                    color: AppColors.colorDarkCyan,
                  )
                      : new Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.kBlack.withOpacity(0.2),
                  ),
                )
              ],
            ),
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(top: 15),
                color: AppColors.dividerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomSheets() {
    /*showModalBottomSheet<void>(
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

                      new SizedBox(
                        height: 10,
                      ),
                      buildContestListSearch()
                    ],
                  )));
        });
*/

    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateMain) {
                return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            new SizedBox(
                              height: 10,
                            ),
                            buildContestListSearch(setStateMain)
                          ],
                        )));
              });
        });
  }

  void callback() {
    var dataList = List<String>();

    print("calllll");

    for (var data in categoryList) {
      print("isSelect ${data?.isSelect}");

      if (data?.isSelect != null && data?.isSelect) {
        dataList?.add(data?.id?.toString());
      }
    }

    var filter = FilterRequest(
        minprice: _paymentMin,
        maxprice: _paymentMax,
        distance: _currentSliderValue?.toInt(),
        list: list,
        listCategory: dataList,
    );

    print("calllllss");

    widget.voidcallback(filter);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.kWhite,
            height: screenSize.height,
            child: SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    color: Colors.white,
                    height: 20.0,
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                    new EdgeInsets.only(top: 36.0, left: 17.0, right: 17),
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
                            ResString().get('filters'),
                            style: TextStyle(
                              fontFamily: AssetStrings.circulerMedium,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _currentRangeValues = RangeValues(0, 100);
                            _paymentMin = 0;
                            _paymentMax = 100;
                            _currentSliderValue = 0.0;
                            for (DataModel data in list) {
                              data.isSelect = false;
                            }

                            for (DataCategory data in categoryList) {
                              data.isSelect = false;
                            }

                            text = "";

                            setState(() {});
                          },
                          child: Container(
                            height: 20,
                            child: new Text(
                              ResString().get('reset'),
                              style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                color: AppColors.redLight,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  new Container(
                    color: Colors.white,
                    height: 20.0,
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  /* new Container(
                    color: Colors.white,
                    height: 64.0,
                    margin: new EdgeInsets.only(top: 9.0),
                    padding: new EdgeInsets.only(right: 16),
                    child: new Row(
                      children: [
                        */ /*   new Text(
                          ResString().get('location'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
*/ /*
                        Expanded(
                          child: Container(
                            padding: new EdgeInsets.only(left: 16, right: 5.0),
                            alignment: Alignment.centerLeft,
                            child: getLocation(_LocationController, context,
                                _streamControllerShowLoader,
                                true,
                                _LatLongController,
                                iconData: AssetStrings.location
                            ),
                          ),
                        ),
                        new SizedBox(
                          width: 15,
                        ),
                        */ /*  new Text(
                          ">",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),*/ /*
                      ],
                    ),
                  ),*/
                  new Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(left: 16, right: 16, top: 20),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Text(
                          ResString().get('distance'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerMedium,
                              color: Colors.black,
                              fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        new Text(
                          _currentSliderValue.toInt().toString() + " km",
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: AssetStrings.circulerMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(top: 24, bottom: 16),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.0,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 14.0,
                          pressedElevation: 8.0,
                        ),
                      ),
                      child: Slider(
                        value: _currentSliderValue,
                        min: 0,
                        max: 100,
                        activeColor: AppColors.colorDarkCyan,
                        inactiveColor: Color.fromRGBO(143, 146, 161, 0.2),
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderValue = value;
                            print(_currentSliderValue);
                          });
                        },
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(left: 16, right: 16),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  new Container(
                    color: Colors.white,
                    margin: new EdgeInsets.only(top: 9.0),
                    padding: new EdgeInsets.only(left: 16, right: 16, top: 10),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Text(
                          ResString().get('payment'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerMedium,
                              color: Colors.black,
                              fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        new Text(
                          "€$_paymentMin" + "-" "€$_paymentMax",
                          style: new TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(top: 24, bottom: 16),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.0,
                        rangeThumbShape: RoundRangeSliderThumbShape(
                          enabledThumbRadius: 14.0,
                          pressedElevation: 8.0,
                        ),
                      ),
                      child: RangeSlider(
                        values: _currentRangeValues,
                        min: 0,
                        max: 100,
                        activeColor: AppColors.colorDarkCyan,
                        inactiveColor: Color.fromRGBO(143, 146, 161, 0.2),
                        labels: RangeLabels(
                          _currentRangeValues.start.round().toString(),
                          _currentRangeValues.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                            _paymentMin = _currentRangeValues.start.round();
                            _paymentMax = _currentRangeValues.end.round();
                          });
                        },
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(left: 16, right: 16),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(left: 16, top: 25, right: 16),
                    width: getScreenSize(context: context).width,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            color: Colors.white,
                            child: new Text(
                              "Sort Type",
                              style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                color: Colors.black,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showBottomSheets();
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            color: Colors.white,
                            child: new Text(
                              text != null && text?.isNotEmpty ? text : "None",
                              style: new TextStyle(
                                color: Colors.black,
                                fontFamily: AssetStrings.circulerMedium,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          margin: new EdgeInsets.only(left: 2),
                          child: new Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: AppColors.colorDarkCyan,
                          ),
                        )
                      ],
                    ),
                  ),
                  /* Container(
                      color: Colors.white,
                      padding:
                          new EdgeInsets.only(left: 12, top: 16, bottom: 16.0),
                      width: getScreenSize(context: context).width,
                      child: new Wrap(
                        runSpacing: 2.0,
                        spacing: 2.0,
                        children: actorWidgets.toList(),
                      )),*/

                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(left: 16, right: 16, top: 25),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                    padding: new EdgeInsets.only(left: 16, top: 20),
                    width: getScreenSize(context: context).width,
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: new Text(
                      "Category",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          color: Colors.black,
                          fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      padding:
                      new EdgeInsets.only(left: 12, top: 16, bottom: 16.0),
                      width: getScreenSize(context: context).width,
                      child: new Wrap(
                        runSpacing: 2.0,
                        spacing: 2.0,
                        children: categoryWidget.toList(),
                      )),
                  new SizedBox(
                    height: 100.0,
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
                  padding: new EdgeInsets.only(top: 9, bottom: 28),
                  child: getSetupButtonNew(
                      callback, ResString().get('apply_filters'), 16,
                      newColor: AppColors.colorDarkCyan)),
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
