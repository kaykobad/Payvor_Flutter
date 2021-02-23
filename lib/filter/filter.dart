import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/filter/data.dart';
import 'package:payvor/filter/filter_request.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';

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

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
  ScrollController scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  var _currentSliderValue = 0.0;


  var _paymentMin = 0;
  var _paymentMax = 100;
  TextEditingController _LocationController = new TextEditingController();
  TextEditingController _LatLongController = new TextEditingController();

  final StreamController<bool> _streamControllerShowLoader =
  StreamController<bool>();

  var list = List<DataModel>();

  RangeValues _currentRangeValues = RangeValues(0, 100);

  @override
  void initState() {
    _setScrollListener();

    var data = DataModel(name: "Newest post first",
        isSelect: false,
        sendTitle: "newest_first",
        id: 1);
    var data1 = DataModel(name: "Most relevant",
        isSelect: false,
        sendTitle: "most_relevent",
        id: 2);
    var data2 = DataModel(name: "Closest location first",
        isSelect: false,
        sendTitle: "nearest_location",
        id: 3);
    var data3 = DataModel(name: "Price low to high",
        isSelect: false,
        sendTitle: "price_low_to_high",
        id: 4);
    var data4 = DataModel(name: "Price high to low",
        isSelect: false,
        sendTitle: "price_high_to_low",
        id: 5);
    list.add(data);
    list.add(data1);
    list.add(data2);
    list.add(data3);
    list.add(data4);


    if (widget.filterRequest != null) {
      if (widget.filterRequest.list != null) {
        list.clear();
        list.addAll(widget.filterRequest.list);
      }
      _paymentMin = widget.filterRequest.minprice ?? 0;
      _paymentMax = widget.filterRequest.maxprice ?? 100;
      _currentRangeValues =
          RangeValues(_paymentMin?.toDouble(), _paymentMax?.toDouble());
      _currentSliderValue = widget.filterRequest.distance?.toDouble() ?? 0.0;
      _LocationController.text = widget.filterRequest.location ?? "";
      _LatLongController.text = widget.filterRequest.latlongData ?? "";
    }

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void _setScrollListener() {}

  Iterable<Widget> get actorWidgets sync* {
    for (DataModel data in list) {
      yield InkWell(
        onTap: () {
          data.isSelect = !data.isSelect;

          var id = data.id;

          if ((id == 4 || id == 5) && data.isSelect) {
            if (id == 4) {
              list[4].isSelect = false;
            }
            else {
              list[3].isSelect = false;
            }
          }


          setState(() {});
        },
        child: data.isSelect
            ? Container(
                margin:
                    new EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                padding:
                    new EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                decoration: new BoxDecoration(
                  color: AppColors.colorDarkCyan,
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                child: Text(
                  data.name,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: AssetStrings.circulerNormal),
                ),
              )
            : Container(
                margin:
                    new EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                padding:
                    new EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                decoration: new BoxDecoration(
                  color: AppColors.lightCyan,
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                child: Text(
                  data.name,
                  style: new TextStyle(
                      color: AppColors.colorDarkCyan,
                      fontSize: 13,
                      fontFamily: AssetStrings.circulerNormal),
                ),
        ),
      );
    }
  }

  void callback() {
    if (_LocationController.text.length > 0 &&
        _LatLongController.text.isEmpty) {
      showInSnackBar("Please select a specific location");
      return;
    }

    var filter = FilterRequest(
      location: _LocationController.text,
      latlongData: _LatLongController.text,
      minprice: _paymentMin,
      maxprice: _paymentMax,
      distance: _currentSliderValue?.toInt(),
      list: list,
    );

    widget.voidcallback(filter);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                            style: TextThemes.darkBlackMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _currentRangeValues = RangeValues(0, 100);
                            _paymentMin = 0;
                            _paymentMax = 100;
                            _currentSliderValue = 0.0;
                            _LocationController.text = "";
                            _LatLongController.text = "";
                            for (DataModel data in list) {
                              data.isSelect = false;
                            }

                            setState(() {

                            });
                          },
                          child: Container(
                            height: 20,
                            child: new Text(
                              ResString().get('reset'),
                              style: new TextStyle(
                                  fontFamily: AssetStrings.circulerMedium,
                                  color: AppColors.redLight,
                                  fontSize: 14),
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
                  new Container(
                    color: Colors.white,
                    height: 64.0,
                    margin: new EdgeInsets.only(top: 9.0),
                    padding: new EdgeInsets.only(right: 16),
                    child: new Row(
                      children: [
                        /*   new Text(
                          ResString().get('location'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
*/
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
                        /*  new Text(
                          ">",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),*/
                      ],
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
                          ResString().get('distance'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerMedium,
                              color: Colors.black,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        new Text(
                          _currentSliderValue.toInt().toString() + " km",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerMedium,
                              color: AppColors.colorDarkCyan,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(top: 24, bottom: 16),
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
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        new Text(
                          "€$_paymentMin" + "-" "€$_paymentMax",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerMedium,
                              color: AppColors.colorDarkCyan,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(top: 24, bottom: 16),
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
                          ;
                        });
                      },
                    ),
                  ),
                  new SizedBox(
                    height: 9.0,
                  ),
                  Container(
                    padding: new EdgeInsets.only(left: 16, top: 10),
                    width: getScreenSize(context: context).width,
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: new Text(
                      "Sort By",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          color: Colors.black,
                          fontSize: 16),
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
                        children: actorWidgets.toList(),
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
