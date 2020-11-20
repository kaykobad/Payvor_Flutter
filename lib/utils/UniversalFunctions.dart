import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'AppColors.dart';

// Todo: actual

// Returns screen size
Size getScreenSize({@required BuildContext context}) {
  return MediaQuery.of(context).size;
}

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
}) {
 // MemoryManagement.clearMemory();

/*
  if (isAndroid()) {
    Fluttertoast.clearAllNotifications();
  }
  isUserSignedIn = false;*/
//  customPushAndRemoveUntilSplash(
//    context: context,
//  );
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

Widget backButton(VoidCallback callback)
{

  return InkWell(
    onTap: (){
      callback();
    },
    child: Icon(
      getPlatformSpecificBackIcon(),
      color: AppColors.kBlack,
      ),
  );
}



AppBar commonAppBar({VoidCallback callback,Widget action,@required String title})
{
  return AppBar(
    backgroundColor: AppColors.kWhite,
    // Here we take the value from the MyHomePage object that was created by
    // the App.build method, and use it to set our appbar title.
    title: Text(title,style: TextStyle(color: AppColors.kBlack),),
    centerTitle: true,
    leading: backButton(callback),
    actions: [action??Container()],
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
          ? getHalfAppThemedLoader(
              context: context,
            )
          : new Container();
    },
  );
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

// Checks Internet connection
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
        /* showAlert(
          context: context,
          titleText: Localization.of(context).trans(LocalizationValues.error),
          message: Messages.noInternetError,
          actionCallbacks: {
            Localization.of(context).trans(LocalizationValues.ok): () {
              return false;
            }
          },
        );*/
      }
    }
  } catch (_) {
    onFail();
    /*  showAlert(
        context: context,
        titleText: Localization.of(context).trans(LocalizationValues.error),
        message: Messages.noInternetError,
        actionCallbacks: {
          Localization.of(context).trans(LocalizationValues.ok): () {
            return false;
          }
        });*/
  }
  return false;
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
        child:Icon(
          Icons.image,
          color: Colors.grey,
          size: 36.0,
        )
      );
    },
  );
}

