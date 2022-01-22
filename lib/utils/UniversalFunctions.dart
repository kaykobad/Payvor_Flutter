import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:payvor/pages/login/login.dart';
import 'package:payvor/provider/location_provider.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';

import 'AppColors.dart';
import 'memory_management.dart';

// Todo: actual

// Returns screen size
Size getScreenSize({@required BuildContext context}) {
  return MediaQuery.of(context).size;
}

const Color dialogContentColor = AppColors.kBlack;

bool alertAlreadyActive = false;
const String OK = "OK";

const Duration timeoutDuration = const Duration(seconds: 60);

// Returns status bar height
double getStatusBarHeight({@required BuildContext context}) {
  return MediaQuery.of(context).padding.top;
}

bool isAndroidPlatform({@required BuildContext context}) {
  if (Platform.isAndroid) {
    return true;
  } else {
    return false;
  }
}

String readTimestamp(String timestamp) {
  var time = '';
  try {
    var now = new DateTime.now();
    var format = new DateFormat('HH:MM');
    var date =
        new DateTime.fromMicrosecondsSinceEpoch(num.parse(timestamp) * 1000);
    time = format.format(date);
  } catch (ex) {
    print("chat time ${ex.toString()}");
    time = timestamp;
  }
  return time;
}

// Returns bottom padding for round edge screens
double getSafeAreaBottomPadding({@required BuildContext context}) {
  return MediaQuery.of(context).padding.bottom;
}

// Returns Keyboard size
bool isKeyboardOpen({@required BuildContext context}) {
  return MediaQuery.of(context).viewInsets.bottom > 0.0;
}

// Returns spacer
Widget getSpacer({double height, double width}) {
  return new SizedBox(
    height: height ?? 0.0,
    width: width ?? 0.0,
  );
}

// Clears memory on logout success
void onLogoutSuccess({
  @required BuildContext context,
}) async {

    await MemoryManagement?.clearMemory();
    Navigator.pushAndRemoveUntil(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new LoginScreenNew();
      }),
          (route) => false,
    );
  }


// Checks target platform
bool isAndroid() {
  return defaultTargetPlatform == TargetPlatform.android;
}

// Asks for exit
Future<bool> askForExit() async {
//  if (canExitApp) {
//    exit(0);
//    return Future.value(true);
//  } else {
//    canExitApp = true;
//    Fluttertoast.showToast(
//      msg: "Please click BACK again to exit",
//      toastLength: Toast.LENGTH_LONG,
//      gravity: ToastGravity.BOTTOM,
//    );
//    new Future.delayed(
//        const Duration(
//          seconds: 2,
//        ), () {
//      canExitApp = false;
//    });
//    return Future.value(false);
//  }
}

// Returns no data view
Widget getNoDataView({
  @required String msg,
  TextStyle messageTextStyle,
  @required VoidCallback onRetry,
}) {
  return new Center(
    child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(
          msg ?? "No data found",
          style: messageTextStyle ??
              const TextStyle(
                fontSize: 18.0,
              ),
        ),
        new InkWell(
          onTap: onRetry ?? () {},
          child: new Text(
            "REFRESH",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

// Returns platform specific back button icon
IconData getPlatformSpecificBackIcon() {
  return defaultTargetPlatform == TargetPlatform.iOS
      ? Icons.arrow_back_ios
      : Icons.arrow_back;
}

Widget backButton(VoidCallback callback) {
  return InkWell(
    onTap: () {
      callback();
    },
    child: Icon(
      getPlatformSpecificBackIcon(),
      color: AppColors.kBlack,
    ),
  );
}

AppBar commonAppBar(
    {VoidCallback callback, Widget action, @required String title}) {
  return AppBar(
    backgroundColor: AppColors.kWhite,
    // Here we take the value from the MyHomePage object that was created by
    // the App.build method, and use it to set our appbar title.
    title: Text(
      title,
      style: TextStyle(color: AppColors.kBlack),
    ),
    centerTitle: true,
    leading: backButton(callback),
    actions: [action ?? Container()],
  );
}

Widget getFullScreenProviderLoader({
  @required bool status,
  @required BuildContext context,
}) {
  return status
      ? getAppThemedLoader(
          context: context,
        )
      : new Container();
}

Widget getFullScreenLoader({
  @required Stream<bool> stream,
  @required BuildContext context,
  Color bgColor,
  Color color,
  double strokeWidth,
}) {
  return new StreamBuilder<bool>(
    stream: stream,
    initialData: false,
    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      bool status = snapshot.data;
      return status
          ? getAppThemedLoader(
              context: context,
            )
          : new Container();
    },
  );
}

Widget getHalfScreenLoader({
  @required bool status,
  @required BuildContext context,
  Color bgColor,
  Color color,
  double strokeWidth,
}) {
  return status
      ? getHalfAppThemedLoader(
          context: context,
        )
      : new Container();
}

Widget getHalfAppThemedLoader({
  @required BuildContext context,
  Color bgColor,
  Color color,
  double strokeWidth,
}) {
  return new Container(
    // color: bgColor ?? const Color.fromRGBO(1, 1, 1, 0.6),
    height: 50,
    width: getScreenSize(context: context).width,
    child: getChildLoader(
      color: color ?? AppColors.kPrimaryBlue,
      strokeWidth: strokeWidth,
    ),
  );
}

Widget getCachedNetworkImageWithurl(
    {@required String url, BoxFit fit, double size}) {
  return new CachedNetworkImage(
    width: size,
    height: size,
    imageUrl: url??"",
    fit: fit != null ? fit : BoxFit.cover,
    placeholder: (context, String val) {
      return new Center(
        child: new CupertinoActivityIndicator(),
      );
    },
    errorWidget: (BuildContext context, String error, Object obj) {
      print("errro $error");
      return new Center(
        child: Container(
            width: size,
            height: size,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: new Image.asset(AssetStrings.noPhoto)),
//          child: new SvgPicture.asset(
//        AssetStrings.imageFirst,
//        fit: BoxFit.fill,
//      )
      );
    },
  );
}

Widget getCachedNetworkImageRect(
    {@required String url, BoxFit fit, double size}) {
  return new CachedNetworkImage(
    width: size,
    height: size,
    imageUrl: "$url",
    matchTextDirection: true,
    fit: fit != null ? fit : BoxFit.cover,
    placeholder: (context, String val) {
      return new Center(
        child: new CupertinoActivityIndicator(),
      );
    },
    errorWidget: (BuildContext context, String error, Object obj) {
      print("errro $error");
      return Container(
        width: double.infinity,
        height: size,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: AppColors.greyProfile,
        ),
        child: new Image.asset(
          AssetStrings.emailPngnew,
          width: 20,
          height: 20,
        ),
      );
    },
  );
}

Future<bool> hasInternetConnection({
  @required BuildContext context,
  bool mounted,
  @required Function onSuccess,
  @required Function onFail,
  bool canShowAlert = true,
}) async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      onSuccess();
      return true;
    } else {
      if (canShowAlert) {
        onFail();
        showAlert(
          context: context,
          titleText: "Error",
          message: Messages.noInternetError,
          actionCallbacks: {
            OK: () {
              return false;
            }
          },
        );
      }
    }
  } catch (_) {
    onFail();
    showAlert(
        context: context,
        titleText: "Error",
        message: Messages.noInternetError,
        actionCallbacks: {
          OK: () {
            return false;
          }
        });
  }
  return false;
}

// Returns app themed loader
Widget getAppThemedLoader({
  @required BuildContext context,
  Color bgColor,
  Color color,
  double strokeWidth,
}) {
  return new Container(
    color: bgColor ?? const Color.fromRGBO(1, 1, 1, 0.6),
    height: getScreenSize(context: context).height,
    width: getScreenSize(context: context).width,
    child: getChildLoader(
      color: color ?? AppColors.kPrimaryBlue,
      strokeWidth: strokeWidth,
    ),
  );
}

// Returns app themed list view loader
Widget getChildLoader({
  Color color,
  double strokeWidth,
}) {
  return new Center(
    child: new CircularProgressIndicator(
      backgroundColor: Colors.transparent,
      valueColor: new AlwaysStoppedAnimation<Color>(
        color ?? Colors.white,
      ),
      strokeWidth: strokeWidth ?? 6.0,
    ),
  );
}

// Show alert dialog
void showAlert(
    {@required BuildContext context,
    String titleText,
    Widget title,
    String message,
    Widget content,
    Map<String, VoidCallback> actionCallbacks}) {
  Widget titleWidget = titleText == null
      ? title
      : new Text(
          titleText.toUpperCase(),
          textAlign: TextAlign.center,
          style: new TextStyle(
            color: dialogContentColor,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        );
  Widget contentWidget = message == null
      ? content != null
          ? content
          : new Container()
      : new Text(
          message,
          textAlign: TextAlign.center,
          style: new TextStyle(
            color: dialogContentColor,
            fontWeight: FontWeight.w400,
//            fontFamily: Constants.contentFontFamily,
          ),
        );

  OverlayEntry alertDialog;
  // Returns alert actions
  List<Widget> _getAlertActions(Map<String, VoidCallback> actionCallbacks) {
    List<Widget> actions = [];
    actionCallbacks.forEach((String title, VoidCallback action) {
      actions.add(
        new ButtonTheme(
          minWidth: 0.0,
          child: new CupertinoDialogAction(
            child: new Text(title,
                style: new TextStyle(
                  color: dialogContentColor,
                  fontSize: 16.0,
//                        fontFamily: Constants.contentFontFamily,
                )),
            onPressed: () {
              action();
              alertDialog?.remove();
              alertAlreadyActive = false;
            },
          ),
//          child: defaultTargetPlatform != TargetPlatform.iOS
//              ? new FlatButton(
//                  child: new Text(
//                    title,
//                    style: new TextStyle(
//                      color: IfincaColors.kPrimaryBlue,
////                      fontFamily: Constants.contentFontFamily,
//                    ),
//                    maxLines: 2,
//                  ),
//                  onPressed: () {
//                    action();
//                  },
//                )
//              :
// new CupertinoDialogAction(
//                  child: new Text(title,
//                      style: new TextStyle(
//                        color: IfincaColors.kPrimaryBlue,
//                        fontSize: 16.0,
////                        fontFamily: Constants.contentFontFamily,
//                      )),
//                  onPressed: () {
//                    action();
//                  },
//                ),
        ),
      );
    });
    return actions;
  }

  List<Widget> actions =
      actionCallbacks != null ? _getAlertActions(actionCallbacks) : [];

  OverlayState overlayState;
  overlayState = Overlay.of(context);

  alertDialog = new OverlayEntry(builder: (BuildContext context) {
    return new Positioned.fill(
      child: new Container(
        color: Colors.black.withOpacity(0.7),
        alignment: Alignment.center,
        child: new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new Dialog(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
            child: new Material(
              borderRadius: new BorderRadius.circular(10.0),
              color: AppColors.kWhite,
              child: new Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                            ),
                            child: titleWidget,
                          ),
                          contentWidget,
                        ],
                      ),
                    ),
                    new Container(
                      height: 0.6,
                      margin: new EdgeInsets.only(
                        top: 24.0,
                      ),
                      color: dialogContentColor,
                    ),
                    new Row(
                      children: <Widget>[]..addAll(
                          new List.generate(
                            actions.length +
                                (actions.length > 1 ? (actions.length - 1) : 0),
                            (int index) {
                              return index.isOdd
                                  ? new Container(
                                      width: 0.6,
                                      height: 30.0,
                                      color: dialogContentColor,
                                    )
                                  : new Expanded(
                                      child: actions[index ~/ 2],
                                    );
                            },
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  });

  if (!alertAlreadyActive) {
    alertAlreadyActive = true;
    overlayState.insert(alertDialog);
  }
}

// Closes keyboard by clicking any where on screen
void closeKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

Future<dynamic> currentPosition(
    int type, BuildContext context, LocationProvider provider) async {
  try {
    //  provider.setLoading();

    var geolocator = await Geolocator.isLocationServiceEnabled();
    print("aviiii $geolocator");
    if (geolocator) {
      var permissionCheck = await Geolocator.checkPermission();

      if (permissionCheck == LocationPermission.denied) {
        print("aviiii denied");
        permissionCheck = await Geolocator.requestPermission();

        if (permissionCheck == LocationPermission.always ||
            permissionCheck == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          print(position);
          print("aviiii");

          var lat = position.latitude;
          var long = position.longitude;
          print("lat $lat");
          print("long $long");

          /*    final coordinates = new Coordinates(lat, long);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          var first = addresses.first;*/

          var location = await GetAddressFromLatLong(position);

          MemoryManagement.setLocationName(geo: location);

          // MemoryManagement.setLocationName(geo: first?.addressLine);

          if (provider != null) {
            provider.locationProvider
                .add(lat.toString() + "," + long.toString());
          }

          MemoryManagement.setGeo(geo: lat.toString() + "," + long.toString());

          /* Future.delayed(new Duration(seconds: 3), () {
              provider.hideLoader();
            });*/

          if (type == 1) {
            closeKeyboard();
          } else {
            // provider.hideLoader();
          }

          if (type == 1) {
            return 1;
          }
        } else {
          // provider.hideLoader();
        }
      } else if (permissionCheck == LocationPermission.deniedForever) {
        // provider.hideLoader();
        print("aviiii forever");
        showAlert(
          context: context,
          titleText: "Permission Alert",
          message:
              "Some core functionality of the app might not work correctly without Location permissions. Please go to settings and enable it for District Lead.",
          actionCallbacks: {
            "OK": () {
              Geolocator?.openAppSettings();
            }
          },
        );

        /* return Future.error(
         'Location permissions are permantly denied, we cannot request permissions.');*/
      } else {
        print("aviiii allow");

        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print(position);
        print("aviiii");

        var lat = position.latitude;
        var long = position.longitude;

        print("lat $lat");
        print("long $long");
        /* final coordinates = new Coordinates(lat, long);
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        Address first = addresses.first;*/

        var location = await GetAddressFromLatLong(position);

        MemoryManagement.setLocationName(geo: location);

        if (provider != null) {
          provider.locationProvider.add(lat.toString() + "," + long.toString());
        }
        MemoryManagement.setGeo(geo: lat.toString() + "," + long.toString());

        if (type == 1) {
          closeKeyboard();
        } else {
          // provider.hideLoader();
        }
        if (type == 1) {
          return 1;
        }
      }
    } else {
      //  provider.hideLoader();

      showAlert(
        context: context,
        titleText: "Location",
        message:
            "It seems your location settings are turned Off. Please turn on to get most accurate location",
        actionCallbacks: {
          "OK": () {
            Geolocator?.openLocationSettings();
          }
        },
      );
    }
  } catch (e, stacktrace) {
    print("excepption $e");
  }
}

Future<String> GetAddressFromLatLong(Position position) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  print(placemarks);
  Placemark place = placemarks[0];
  String address =
      '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  return address;
}

String getCardImage(String brand) {
  String image = AssetStrings.visaCard;

  switch (brand?.toLowerCase()) {
    case "visa":
      image = AssetStrings.visaCard;
      break;
    case "mastercard":
      image = AssetStrings.materCard;
      break;
    case "american express":
      image = AssetStrings.amexCard;
      break;
    case "discover & diners":
      image = AssetStrings.amexCard;
      break;
    case "china unionpay":
      image = AssetStrings.amexCard;
      break;
    case "japan credit bureau":
      image = AssetStrings.amexCard;
      break;
    case "cartes bancaires":
      image = AssetStrings.amexCard;
      break;
    case "Interac":
      image = AssetStrings.amexCard;
      break;
  }

  return image;
}

//cached Network image
Widget getCachedNetworkImage(
    {@required String url, BoxFit fit, height, width}) {
  return new CachedNetworkImage(
    width: width ?? double.infinity,
    height: height ?? double.infinity,
    imageUrl: url ?? "",
    matchTextDirection: true,
    fit: fit,
    placeholder: (context, String val) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: new Center(
          child: new CupertinoActivityIndicator(),
        ),
      );
    },
    errorWidget: (BuildContext context, String error, Object obj) {
      return new Center(
          child: Icon(
        Icons.image,
        color: Colors.grey,
        size: 36.0,
      ));
    },
  );
}

awesomeSuccessDialog(String message, BuildContext context,
    {VoidCallback callback}) {
  AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      headerAnimationLoop: false,
      dialogType: DialogType.SUCCES,
      showCloseIcon: true,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {
        debugPrint('OnClcik');
        if (callback != null) {
          callback();
        }
      },
      btnOkIcon: Icons.check_circle,
      onDissmissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      })
    ..show();
}

awesomeErrorDialog(String message, BuildContext context,
    {VoidCallback callback}) {
  AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.RIGHSLIDE,
      headerAnimationLoop: true,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {
        if (callback != null) {
          callback();
        }
      },
      btnOkIcon: Icons.cancel,
      btnOkColor: Colors.red)
    ..show();
}
