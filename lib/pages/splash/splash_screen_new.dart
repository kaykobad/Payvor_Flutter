import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:payvor/pages/create_credential/create_credential.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/intro_screen/splash_intro_new.dart';
import 'package:payvor/pages/phone_number_add/phone_number_add.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/memory_management.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FadeIn();
}

enum UniLinksType { string, uri }

class FadeIn extends State<SplashScreen> {
  String _initialLink;
  Uri _initialUri;
  String _latestLink = 'Unknown';
  Uri _latestUri;
  StreamSubscription _sub;
  UniLinksType _type = UniLinksType.string;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    initPlatformState();

    moveToScreen();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
//    if (_type == UniLinksType.string) {
//      await initPlatformStateForStringUniLinks();
//    }
  }

  /// An implementation using a [String] link
//  Future<void> initPlatformStateForStringUniLinks() async {
//    // Attach a listener to the links stream
//    _sub = getLinksStream().listen((String link) {
//      print("avinashhh");
//
//      if (!mounted) return;
//      setState(() {
//        _latestLink = link ?? 'Unknown';
//        _latestUri = null;
//        try {
//          if (link != null) _latestUri = Uri.parse(link);
//        } on FormatException {}
//      });
//    }, onError: (Object err) {
//      print("avinashhht");
//      if (!mounted) return;
//      setState(() {
//        _latestLink = 'Failed to get latest link: $err.';
//        _latestUri = null;
//      });
//    });
//
//    // Attach a second listener to the stream
//    getLinksStream().listen((String link) {
//      print("avinashhh");
//      print('got link: $link');
//    }, onError: (Object err) {
//      print('got err: $err');
//    });
//
//    // Get the latest link
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      _initialLink = await getInitialLink();
//      print("aviinashhh");
//      print('initial link: $_initialLink');
//      if (_initialLink != null) _initialUri = Uri.parse(_initialLink);
//    } on PlatformException {
//      _initialLink = 'Failed to get initial link.';
//      _initialUri = null;
//    } on FormatException {
//      _initialLink = 'Failed to parse the initial link as Uri.';
//      _initialUri = null;
//    }
//
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//
//    setState(() {
//      _latestLink = _initialLink;
//      _latestUri = _initialUri;
//    });
//  }

  @override
  Widget build(BuildContext context) {
//    var width = MediaQuery
//        .of(context)
//        .size
//        .width;
//    var height = MediaQuery
//        .of(context)
//        .size
//        .height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.kPrimaryBlue,
        body: Container(
          margin: new EdgeInsets.only(top: 80.0),
          alignment: Alignment.center,
          child: new Column(children: <Widget>[
            Lottie.asset('assets/payvor.json',
                repeat: true,
                reverse: false,
                animate: true,
                width: 240,
                height: 240),
          ]),
        ),
      ),
    );
  }

//  Future<void> initPlatformStateForUriUniLinks() async {
//    // Attach a listener to the Uri links stream
//    _sub = getUriLinksStream().listen((Uri uri) {
//      if (!mounted) return;
//      setState(() {
//        _latestUri = uri;
//        _latestLink = uri?.toString() ?? 'Unknown';
//      });
//    }, onError: (Object err) {
//      if (!mounted) return;
//      setState(() {
//        _latestUri = null;
//        _latestLink = 'Failed to get latest link: $err.';
//      });
//    });
//
//    // Attach a second listener to the stream
//    getUriLinksStream().listen((Uri uri) {
//      print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
//    }, onError: (Object err) {
//      print('got err: $err');
//    });
//
//    // Get the latest Uri
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      _initialUri = await getInitialUri();
//      print('initial uri: ${_initialUri?.path}'
//          ' ${_initialUri?.queryParametersAll}');
//      _initialLink = _initialUri?.toString();
//    } on PlatformException {
//      _initialUri = null;
//      _initialLink = 'Failed to get initial uri.';
//    } on FormatException {
//      _initialUri = null;
//      _initialLink = 'Bad parse the initial link as Uri.';
//    }
//
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//
//    setState(() {
//      _latestUri = _initialUri;
//      _latestLink = _initialLink;
//    });
//  }

  void moveToScreen() async {
    //ebale firebase store local caceh
//    await Firestore.instance.settings(
//           persistenceEnabled: true,
//    );
    await MemoryManagement.init();
    //show tutorial on home screen
    //  MemoryManagement.setToolTipState(state:TUTORIALSTATE.HOME.index);
    var status = MemoryManagement.getUserLoggedIn() ?? false;

    //

    var screenType = MemoryManagement.getScreenType();
    Timer _timer = new Timer(const Duration(seconds: 2), () {
      if (screenType == "1") {
        Navigator.pushAndRemoveUntil(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new PhoneNumberAdd(
              type: true,
            );
          }),
          (route) => false,
        );
      } else if (screenType == "2") {
        Navigator.pushAndRemoveUntil(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return CreateCredential(
              type: true,
            );
          }),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return (status)
                ? new DashBoardScreen()
                : new SplashIntroScreenNew();
          }),
          (route) => false,
        );
      }
    });
  }
}
