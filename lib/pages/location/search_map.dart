import 'dart:async';

import 'package:flutter/material.dart';
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
  final LocationProvider provider;

  SearchMapView({this.provider});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchMapView> with AutomaticKeepAliveClientMixin<SearchMapView> {
  var screenSize;

  String searchkey;
  AuthProvider provider;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";
  double lat = 37.42796133580664;
  double long = -122.085749655962;
  bool _isCameraMoving = false;

  List<DataRefer> listResult = [];

  final StreamController<bool> _streamControllerShowLoader = StreamController<bool>();

  // bool _loadMore = false;
  // final StreamController<bool> _loaderStreamController = StreamController<bool>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _LocationController = TextEditingController();
  TextEditingController _LatLongController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  LatLng center;
  MarkerId markerId;
  LatLng _lastMapPosition;

  @override
  dispose() {
    _streamControllerShowLoader.close();
    super.dispose();
  }

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // int _markerIdCounter = 1;
  Set<Marker> markers = Set();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
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

  void _add(double lat, double long, String text, {bool shouldMoveCamera = true}) async {
    markers?.clear();
    var markerIdVal = "Marker";
    markerId = MarkerId(markerIdVal);

    _kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 10,
    );

    _lastMapPosition = LatLng(lat, long);
    // creating a MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        lat,
        long,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
    );

    /*   final coordinates = Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    Address first = addresses.first;*/

    var location = await getAddressFromLatLong(lat, long);

    MemoryManagement.setLocationName(geo: location);

    _LocationController?.text = location;

    if (text?.isNotEmpty ?? false) {
      _LocationController?.text = text;
    }

    var latLong = lat?.toString() ?? '' + "," + long?.toString();

    MemoryManagement.setLocationName(geo: _LocationController?.text);
    MemoryManagement.setGeo(geo: latLong);

    if (shouldMoveCamera) moveToCamera();

    setState(() {
      // adding a marker to map
      markers.add(marker);
    });
  }

  Future<String> getAddressFromLatLong(double lat, double long) async {
    String address = MemoryManagement.getLocationName();
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      print(placemarks);
      Placemark place = placemarks[0];
      address = '';
      if (place.street.isNotEmpty) address += place.street + ', ';
      if (place.subLocality.isNotEmpty) address += place.subLocality + ', ';
      if (place.locality.isNotEmpty) address += place.locality + ', ';
      if (place.administrativeArea.isNotEmpty) address += place.administrativeArea + ', ';
      if (place.country.isNotEmpty) address += place.country;
    } catch (ex) {
      print("error ${ex.toString()}");
    }
    return address;
  }

  // _onCameraMove(CameraPosition position) {
  //   _lastMapPosition = position.target;
  // }

  // Future<BitmapDescriptor> _getAssetIcon(BuildContext context) async {
  //   final Completer<BitmapDescriptor> bitmapIcon =
  //       Completer<BitmapDescriptor>();
  //   final ImageConfiguration config = createLocalImageConfiguration(context);
  //
  //   const AssetImage(AssetStrings.location)
  //       .resolve(config)
  //       .addListener(ImageStreamListener((ImageInfo image, bool sync) async {
  //     final ByteData bytes =
  //         await image.image.toByteData(format: ImageByteFormat.png);
  //     if (bytes == null) {
  //       bitmapIcon.completeError(Exception('Unable to encode icon'));
  //       return;
  //     }
  //     final BitmapDescriptor bitmap =
  //         BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  //     bitmapIcon.complete(bitmap);
  //   }));
  //
  //   return await bitmapIcon.future;
  // }

  @override
  void initState() {
    center = LatLng(lat, long);

    var latlong = MemoryManagement.getGeo();
    var location = MemoryManagement.getLocationName();

    if (latlong != null && latlong.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            height: screenSize.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(height: 50.0),
                getTextField(),
                Opacity(
                  opacity: 0.7,
                  child: Container(
                    height: 0.5,
                    margin: EdgeInsets.only(top: 16.0),
                    color: AppColors.dividerColor,
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    markers: markers,
                    onCameraMove: (cameraPosition) {
                      if (!_isCameraMoving) {
                        _isCameraMoving = true;
                        print(cameraPosition.target.toString());
                        _LatLongController?.text = cameraPosition.target.latitude.toString() + "," + cameraPosition.target.longitude.toString();
                        _add(cameraPosition.target.latitude, cameraPosition.target.longitude, "", shouldMoveCamera: false);
                        Future.delayed(Duration(milliseconds: 100), () => _isCameraMoving=false);
                      }
                    },
                    onTap: (data) {
                      print(data?.longitude);
                      _LatLongController?.text = data?.latitude?.toString() ?? '' + "," + data?.longitude?.toString();
                      _add(data?.latitude, data?.longitude, "");
                    },
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 8, bottom: 20),
                  child: getSetupButtonNew(callback, "Confirm Location", 16, newColor: AppColors.colorDarkCyan),
                ),
              ],
            ),
          ),

          /* Center(
            child: _getLoader,
          ),*/
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 120),
        height: 46,
        width: 46,
        child: FloatingActionButton(
          mini: true,
          onPressed: hitLocation,
          child: Icon(
            Icons.near_me,
            color: AppColors.kAppBlue,
            size: 28,
          ),
          backgroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  void hitLocation() async {
    var data = await currentPosition(1, context, widget?.provider);
    if (data is int && data == 1) {
      var latlong = MemoryManagement.getGeo();
      if (latlong != null && latlong.isNotEmpty) {
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
    if ((_LatLongController?.text?.isNotEmpty ?? false) &&
        (_LocationController?.text?.isNotEmpty ?? false)) {
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
          SizedBox(width: 15.0),
          Image.asset(AssetStrings.searches, width: 18.0, height: 18.0),
          SizedBox(width: 10.0),
          Container(
            child: Text(
              text,
              style: TextStyle(color: AppColors.kBlack, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTextField() {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: SvgPicture.asset(AssetStrings.back),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: AppColors.lightWhite,
            ),
            child: Container(
              width: getScreenSize(context: context).width - 65,
              height: 46.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10.0),
                  Image.asset(AssetStrings.searches, width: 18.0, height: 18.0),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 5.0),
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
                            var datas = (_LatLongController?.text ?? '')
                                .trim().toString().split(",");

                            try {
                              var lat = datas[0].toString();
                              var long = datas[1].toString();
                              double latitude = double.parse(lat);
                              double longitide = double.parse(long);
                              _add(latitude, longitide, _LocationController?.text);
                            } catch (e) {}
                          }
                        },
                      ),
                    ),
                  ),
                  /*  Flexible(
                    child: TextField(
                      controller: _controller,
                      style: TextThemes.blackTextFieldNormal,
                      keyboardType: TextInputType.text,
                      onSubmitted: (String value) {


                        hitSearchApi(title);
                      },
                      onChanged: (String value) {

                        hitSearchApi(title);
                      },
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 3.0),
                        hintText: "Search here by name",
                        hintStyle: TextThemes.greyTextNormal,
                      ),
                    ),
                  ),*/
                  SizedBox(width: 4.0),
                  InkWell(
                    onTap: () {
                      _LocationController?.text = "";
                      _LatLongController?.text = "";
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Image.asset(
                        AssetStrings.clean,
                        width: 18.0,
                        height: 18.0,
                        color: Color(0xFF5A5959),
                        colorBlendMode: BlendMode.dstATop,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
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
