import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:payvor/filter/refer_response.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/location_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:provider/provider.dart';

class SearchMapView extends StatefulWidget {
  LocationProvider provider;

  SearchMapView({this.provider});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchMapView>
    with AutomaticKeepAliveClientMixin<SearchMapView> {
  var screenSize;

  String searchkey = null;
  AuthProvider provider;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";
  double lat = 37.42796133580664;
  double long = -122.085749655962;
  List<DataRefer> listResult = List();
  final StreamController<bool> _streamControllerShowLoader =
      StreamController<bool>();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _LocationController = new TextEditingController();
  TextEditingController _LatLongController = new TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  LatLng center;
  MarkerId markerId;
  LatLng _lastMapPosition;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set<Marker> markers = Set();

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          new Container(
            color: Colors.white,
            height: screenSize.height,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  height: 50.0,
                ),
                getTextField(),
                Opacity(
                  opacity: 0.7,
                  child: new Container(
                    height: 0.5,
                    margin: new EdgeInsets.only(top: 16.0),
                    color: AppColors.dividerColor,
                  ),
                ),
                googlemap,
                Container(
                    color: Colors.white,
                    padding: new EdgeInsets.only(top: 9, bottom: 28),
                    child: getSetupButtonNew(callback, "Confirm Location", 16,
                        newColor: AppColors.colorDarkCyan)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  get floatingButton => Container(
        margin: new EdgeInsets.only(top: 150),
        height: 50,
        width: 40,
        child: FloatingActionButton(
          mini: true,
          onPressed: hitLocation,
          child: new Icon(
            Icons.gps_fixed,
            color: Colors.black54,
          ),
          backgroundColor: Colors.white,
        ),
      );

  get googlemap => Expanded(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          markers: markers,
          onCameraMove: _onCameraMove,
          onTap: (data) {
            print(data?.longitude);
            _LatLongController?.text =
                data?.latitude?.toString() + "," + data?.longitude?.toString();
            _add(data?.latitude, data?.longitude, "");
          },
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      );

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  moveToCamera() async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(_lastMapPosition.latitude, _lastMapPosition.longitude),
        zoom: 10.0,
      ),
    ));
  }

  void _add(double lat, double long, String text) async {
    markers?.clear();
    var markerIdVal = "Marker";
    markerId = MarkerId(markerIdVal);

    _kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 10,
    );

    _lastMapPosition = LatLng(lat, long);
    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        lat,
        long,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
    );

    var location = await getAddressFromLatLong(lat, long);

    MemoryManagement.setLocationName(geo: location);

    _LocationController?.text = location;

    if (text?.isNotEmpty) {
      _LocationController?.text = text;
    }

    var latLong = lat?.toString() + "," + long?.toString();

    MemoryManagement.setLocationName(geo: _LocationController?.text);
    MemoryManagement.setGeo(geo: latLong);

    moveToCamera();

    setState(() {
      // adding a new marker to map
      markers.add(marker);
    });
  }

  Future<String> getAddressFromLatLong(double lat, double long) async {
    String address = MemoryManagement.getLocationName();
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      print(placemarks);
      Placemark place = placemarks[0];
      address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    } catch (ex) {
      print("error ${ex.toString()}");
    }
    return address;
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<BitmapDescriptor> _getAssetIcon(BuildContext context) async {
    final Completer<BitmapDescriptor> bitmapIcon =
        Completer<BitmapDescriptor>();
    final ImageConfiguration config = createLocalImageConfiguration(context);

    const AssetImage(AssetStrings.location)
        .resolve(config)
        .addListener(ImageStreamListener((ImageInfo image, bool sync) async {
      final ByteData bytes =
          await image.image.toByteData(format: ImageByteFormat.png);
      if (bytes == null) {
        bitmapIcon.completeError(Exception('Unable to encode icon'));
        return;
      }
      final BitmapDescriptor bitmap =
          BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
      bitmapIcon.complete(bitmap);
    }));

    return await bitmapIcon.future;
  }

  @override
  void initState() {
    center = LatLng(lat, long);

    var latlong = MemoryManagement.getGeo();
    var location = MemoryManagement.getLocationName();

    if (latlong != null && latlong?.isNotEmpty) {
      var datas = latlong.trim().toString().split(",");

      try {
        var lat = datas[0].toString();
        var long = datas[1].toString();

        double latitude = double.parse(lat);
        double longitide = double.parse(long);

        _add(latitude, longitide, location);
      } catch (e) {}
    } else {
      _add(lat, long, "");
    }
    super.initState();
  }



  void hitLocation() async {
    var data = await currentPosition(1, context, widget?.provider);
    if (data is int && data == 1) {
      var latlong = MemoryManagement.getGeo();
      if (latlong != null && latlong?.isNotEmpty) {
        _LatLongController.text = latlong;
        var datas = latlong.trim().toString().split(",");

        try {
          var lat = datas[0].toString();
          var long = datas[1].toString();

          double latitude = double.parse(lat);
          double longitide = double.parse(long);

          _add(latitude, longitide, "");
        } catch (e) {}
      }
    }
  }

  void callback() {
    if (_LatLongController?.text?.isNotEmpty &&
        _LocationController?.text?.isNotEmpty) {
      widget?.provider?.locationProvider?.add(_LatLongController?.text);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      showInSnackBar("Please select a location");
    }
  }

  Widget getTopItem(String text, int type) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new SizedBox(
            width: 15.0,
          ),
          new Image.asset(
            AssetStrings.searches,
            width: 18.0,
            height: 18.0,
          ),
          new SizedBox(
            width: 10.0,
          ),
          new Container(
            child: new Text(
              text,
              style: new TextStyle(color: AppColors.kBlack, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget getTextField() {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
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
                  AssetStrings.back,
                ),
              ),
            ),
          ),
          new SizedBox(
            width: 10.0,
          ),
          Container(
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(3.0),
                color: AppColors.lightWhite),
            child: Container(
              width: getScreenSize(context: context).width - 65,
              height: 46.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Image.asset(
                    AssetStrings.searches,
                    width: 18.0,
                    height: 18.0,
                  ),
                  new SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Container(
                      padding: new EdgeInsets.only(left: 16, right: 5.0),
                      child: getLocationNew(
                        _LocationController,
                        context,
                        _streamControllerShowLoader,
                        true,
                        _LatLongController,
                        iconData: AssetStrings.location,
                        onTap: () {
                          if (_LatLongController?.text != null &&
                              _LatLongController.text.contains(",")) {
                            var datas = _LatLongController?.text
                                .trim()
                                .toString()
                                .split(",");

                            try {
                              var lat = datas[0].toString();
                              var long = datas[1].toString();

                              double latitude = double.parse(lat);
                              double longitide = double.parse(long);

                              _add(latitude, longitide,
                                  _LocationController?.text);
                            } catch (e) {}
                          }
                        },
                      ),
                    ),
                  ),
                  new SizedBox(
                    width: 4.0,
                  ),
                  InkWell(
                    onTap: () {
                      _LocationController?.text = "";
                      _LatLongController?.text = "";
                    },
                    child: new Image.asset(
                      AssetStrings.clean,
                      width: 18.0,
                      height: 18.0,
                    ),
                  ),
                  new SizedBox(
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

  @override
  bool get wantKeepAlive => true;
}
