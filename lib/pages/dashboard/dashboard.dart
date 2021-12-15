import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/chat/chat_screen.dart';
import 'package:payvor/model/category/category_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/update_firebase_token/update_token_request.dart';
import 'package:payvor/pages/chat/private_chat.dart';
import 'package:payvor/pages/dummy.dart';
import 'package:payvor/pages/guest_view/guest_view.dart';
import 'package:payvor/pages/intro_screen/splash_intro_new.dart';
import 'package:payvor/pages/my_profile/my_profile.dart';
import 'package:payvor/pages/original_post/original_post_data.dart';
import 'package:payvor/pages/pay_feedback/pay_feedback_common.dart';
import 'package:payvor/pages/pay_feedback/pay_give_feedback.dart';
import 'package:payvor/pages/post/post_home.dart';
import 'package:payvor/pages/post_a_favour/post_favour.dart';
import 'package:payvor/pages/post_details/post_details.dart';
import 'package:payvor/pages/search/search_home.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/provider/location_provider.dart';
import 'package:payvor/review/review_post.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  // Properties & Variables needed

  //bottom navigator keys

  final _homeScreen = GlobalKey<NavigatorState>();
  final _chatScreen = GlobalKey<NavigatorState>();
  final _notificationScreen = GlobalKey<NavigatorState>();
  final _profileScreen = GlobalKey<NavigatorState>();
  final _dummyScreen = GlobalKey<NavigatorState>();

  GlobalKey<HomeState> _HomeKey = new GlobalKey<HomeState>();

  int currentTab = 0;
  bool guestViewMain = false;

  // to keep track of active tab index

  final PageStorageBucket bucket = PageStorageBucket();

  FirebaseMessaging _firebaseMessaging;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Color selectedColor = AppColors.bluePrimary;
  Color unselectedColor = AppColors.moreText;

  // double selectedDotSize = 20;
  double selectedDotSize = 0;
  FirebaseProvider _firebaseProvider;
  AuthProvider authProvider;
  bool _isNewActivityFound = false;

  String userName = "";
  String userId = "";
  LocationProvider locationProvider;
  String profile = "";

  Future<bool> _onBackPressed() async {
    bool canPop = false;
    if (guestViewMain == null || !guestViewMain) {
      switch (currentTab) {
        case 0:
          {
            canPop = _homeScreen.currentState.canPop();
            if (canPop) _homeScreen.currentState.pop();
            break;
          }
        case 3:
          {
            canPop = _profileScreen.currentState.canPop();
            if (canPop) _profileScreen.currentState.pop();

            break;
          }

        case 1:
          {
            canPop = _chatScreen.currentState.canPop();
            if (canPop) _chatScreen.currentState.pop();

            break;
          }
        case 2:
          {
            canPop = _notificationScreen.currentState.canPop();
            if (canPop) _notificationScreen.currentState.pop();

            break;
          }
      }
    } else {
      canPop = false;
    }

    if (!canPop) //check if screen popped or not and showing home tab data
      return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Exit the app?'),
                content: Text('Do you want to exit an App'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('YES'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      exit(0); //close app
                    },
                  ),
                ],
              );
            },
          ) ??
          false;
  }

  redirect() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    var data = await Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: new PostFavour());
      }),
    );

    if (data is bool && data) {
      if (_HomeKey != null && _HomeKey.currentState != null) {
        _HomeKey.currentState.hitApiDashboard();
      }
    }

    (currentTab == 0)
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  ValueChanged<Widget> homeCallBack(Widget screen) {
    _redirect(screen);
  }

  ValueChanged<int> callbackChangePage(int type) {
    currentTab = type;
    setState(() {});
  }

  void _redirect(Widget screen) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    var value = await Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return screen;
      }),
    );

    print("callback $value");

    (currentTab == 0)
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  VoidCallback logoutCallBack() {
    _logout();
  }

  void _logout() async {
    await MemoryManagement.clearMemory();

    Navigator.pushAndRemoveUntil(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new SplashIntroScreenNew();
      }),
      (route) => false,
    );
  }

  @override
  void initState() {
    MemoryManagement.setScreenType(type: "3");
    _firebaseMessaging = FirebaseMessaging.instance;

    Future.delayed(new Duration(microseconds: 2000), () {
      setCategory();
      print("call fun");
    });
    configurePushNotification();

    _initPushNotification();

    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    Future.delayed(Duration(milliseconds: 200), () {
      _setupCounterChangeListener();
    });

    var userData = MemoryManagement.getUserInfo();
    if (userData != null) {
      Map<String, dynamic> data = jsonDecode(userData);
      LoginSignupResponse userResponse = LoginSignupResponse.fromJson(data);
      userName = userResponse.user.name ?? "";
      profile = userResponse.user.profilePic ?? "";
      userId = userResponse.user.id.toString();
    }
    var guestUser = MemoryManagement.getGuestUser();
    if (guestUser != null) {
      guestViewMain = guestUser;
    }
  }

  void showNotification(
    String title,
    String body,
    Map<String, dynamic> data,
    String type,
    String favid,
    String userId,
  ) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description');
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        new IOSNotificationDetails();

    MacOSNotificationDetails macOSNotificationDetails =
        new MacOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
        macOS: macOSNotificationDetails);
    // int type = int.tryParse(data["data"]["type"]);
    await flutterLocalNotificationsPlugin.show(
        100, title, body, platformChannelSpecifics,
        payload: "$type,$favid,$userId");
  }

  //redirect to chat screen when receive the notification
  void _moveToChatScreen() {
    setState(() {
      currentTab = 3;
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print('Handling a background message ${message.messageId}');
    if (message != null) {
      _showLocalPush(message.data);
    }
  }

  void configurePushNotification() async {
    print("config Notification");

    // Set the background messaging handler early on, as a named top-level function
   // FirebaseMessaging.instance.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        _showLocalPush(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _showLocalPush(message.data);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message != null) _showLocalPush(message.data);
    });

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("config Notification onMessage");
    //     print("onMessage $message");
    //     if (Platform.isIOS) {
    //       //move to chat screen
    //       var type = message['notification']['type'];
    //       String title = message['notification']['title'];
    //       String description = message['notification']['body'];
    //       if (type.toString() == "7") {
    //         showNotification(title, description, message, type, "0", "0");
    //       } else {
    //         String favid = message['notification']['fav_id'];
    //         String userid = message['notification']['user_id'];
    //         showNotification(title, description, message, type, favid, userid);
    //       }
    //     }
    //   },
    //   onReceive: (Map<String, dynamic> message) async {
    //     print("config Notification onReceive");
    //     //  print("onResume: ${message}");
    //     print("onResume: ${message['data']['type']}");
    //     print("onMessage $message");
    //     if (Platform.isIOS) {
    //       var type = message['notification']['type'];
    //       String title = message['notification']['title'];
    //       String description = message['notification']['body'];
    //       if (type.toString() == "7") {
    //         showNotification(title, description, message, type, "0", "0");
    //       } else {
    //         String favid = message['notification']['fav_id'];
    //         String userid = message['notification']['user_id'];
    //         showNotification(title, description, message, type, favid, userid);
    //       }
    //     }
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("config Notification onResume");
    //     //  print("onResume: ${message}");
    //     print("onResume $message");
    //
    //     if (Platform.isIOS) {
    //       var type = message['notification']['type'];
    //       String title = message['notification']['title'];
    //       String description = message['notification']['body'];
    //       if (type.toString() == "7") {
    //         showNotification(title, description, message, type, "0", "0");
    //       } else {
    //         String favid = message['notification']['fav_id'];
    //         String userid = message['notification']['user_id'];
    //         showNotification(title, description, message, type, favid, userid);
    //       }
    //     } else {
    //       var type = message['data']['type'];
    //       if (type.toString() == "7") {
    //         _moveToChatScreen();
    //       } else {
    //         String favid = message['data']['fav_id'];
    //         String userid = message['data']['user_id'];
    //         moveToScreen(int.tryParse(type), favid, userid);
    //       }
    //     }
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("config Notification onLaunch");
    //     print("onLaunch $message");
    //     if (Platform.isIOS) {
    //       var type = message['notification']['type'];
    //       String title = message['notification']['title'];
    //       String description = message['notification']['body'];
    //       if (type.toString() == "7") {
    //         showNotification(title, description, message, type, "0", "0");
    //       } else {
    //         String favid = message['notification']['fav_id'];
    //         String userid = message['notification']['user_id'];
    //         showNotification(title, description, message, type, favid, userid);
    //       }
    //     } else {
    //       var type = message['data']['type'];
    //       if (type.toString() == "7") {
    //         _moveToChatScreen();
    //       } else {
    //         String favid = message['data']['fav_id'];
    //         String userid = message['data']['user_id'];
    //         moveToScreen(int.tryParse(type), favid, userid);
    //       }
    //     }
    //   },
    // );

    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, badge: true, alert: true));
    //
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });

    _firebaseMessaging.getToken().then((String token) {
      print("DevToken   $token");
      if (token != null) {
        setDeviceToken(token);
        // updateTokenToFirebase(token); //save to firebase
      }
    });
  }

  void _showLocalPush(Map<String, dynamic> message) {
    print("config Notification onMessage");
    print("onMessage $message");

    if (Platform.isIOS) {
      var type = message['notification']['type'];
      String title = message['notification']['title'];
      String description = message['notification']['body'];
      if (type.toString() == "7") {
        showNotification(title, description, message, type, "0", "0");
      } else {
        String favid = message['notification']['fav_id'];
        String userid = message['notification']['user_id'];
        showNotification(title, description, message, type, favid, userid);
      }
    } else {
      var type = message['type'];
      if (type.toString() == "7") {
        _moveToChatScreen();
      } else {
        String title = message['title'];
        String description = message['body'];
        String favid = message['fav_id'];
        String userid = message['user_id'];
       // moveToScreen(int.tryParse(type), favid, userid);
        showNotification(title, description, message, type, favid, userid);
      }
    }
  }

  void moveToScreen(int type, String favid, String userid) {
    if (type == 1) {
      //"hire to u
      _firebaseProvider?.changeScreen(new PayFeebackDetailsCommon(
        postId: favid,
        userId: userid,
        giveFeedback: false,
        voidcallback: null,
        lauchCallBack: null,
      ));
    } else if (type == 2) {
      // hire and paid favor

      _firebaseProvider?.changeScreen(new PayFeebackDetails(
        postId: favid,
        userId: userid,
        type: 1,
        voidcallback: null,
      ));
    } else if (type == 3) {
      print("review_post from dashboard screen");
      // for rated user
      _firebaseProvider?.changeScreen(Material(
          child: new ReviewPost(
        id: favid ?? "",
      )));
    } else if (type == 4) {
      // for applied user
      _firebaseProvider?.changeScreen(Material(
          child: new OriginalPostData(
        id: favid,
      )));
    } else {
      // for apploed and refered favor( type 3,4 etc)
      _firebaseProvider?.changeScreen(new PostFavorDetails(
        id: favid.toString(),
      ));
    }
  }

  void movetochatScreen(String senderid, String image, String name) {
    var screen = PrivateChat(
      peerId: senderid ?? "",
      peerAvatar: image ?? "",
      userName: name ?? "",
      isGroup: false,
      currentUserId: userId,
      currentUserName: userName,
      currentUserProfilePic: profile,
    );
    _firebaseProvider?.changeScreen(screen);
  }

  void setDeviceToken(String token) async {
    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {},
      onSuccess: () {},
    );

    if (gotInternetConnection) {
      var updatetokenrequest =
          UpdateTokenRequest(user_id: userId ?? "", device_id: token);

      var response =
          authProvider.updateTokenRequest(updatetokenrequest, context);
      // api hit
      /*var request = new DeviceTokenRequest(deviceToken: token);to
      var response = await _dashBoardBloc.setDeviceToken(
          context: context, devicetokenRequest: request);

      //logged in successfully
      if (response != null && (response is ChangePasswordResponse)) {
        print(response.message);
      } else {}*/
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
      }
    }
  }

  void getDeviceToken() {
    //  var response=   authProvider.updateTokenRequest( context);
  }

  void _initPushNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print("noti calllledddddd");
      debugPrint('notification payload: ' + payload);
//      Map valueMap = json.decode(payload);
      print("type $payload");
      var data = payload.split(",");
      if (data[0] == "7") {
        _moveToChatScreen();
      } else {}
      // moveToScreen(int.tryParse(data[0]), data[1], data[2]);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _firebaseProvider.notificationStreamController.close();
  }

  Widget normalView() {
    return IndexedStack(
      index: currentTab,
      sizing: StackFit.loose,
      children: <Widget>[
        Navigator(
            key: _homeScreen,
            onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => SearchCompany(
                    callbackmyid: callbackChangePage,
                    userid: userId?.toString(),
                    key: _HomeKey,
                  ),
                )),
        Navigator(
          key: _chatScreen,
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => PostScreen(
              lauchCallBack: homeCallBack,
            ),
          ),
        ),
        Navigator(
          key: _dummyScreen,
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => Dummy(
              logoutCallBack: logoutCallBack,
            ),
          ),
        ),
        Navigator(
          key: _notificationScreen,
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => ChatScreen(
              logoutCallBack: logoutCallBack,
            ),
          ),
        ),
        Navigator(
          key: _profileScreen,
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => MyProfile(
              id: userId ?? "",
              name: userName ?? "",
              hireduserId: userId ?? "",
              image: profile ?? "",
              userButtonMsg: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget guestView() {
    return IndexedStack(
      index: currentTab,
      children: <Widget>[
        Navigator(
            onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => SearchCompany(
                    callbackmyid: callbackChangePage,
                    userid: userId?.toString(),
                    key: _HomeKey,
                  ),
                )),
        Navigator(
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => GuestView(
              lauchCallBack: homeCallBack,
            ),
          ),
        ),
        Navigator(
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => GuestView(
              lauchCallBack: homeCallBack,
            ),
          ),
        ),
        Navigator(
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => GuestView(
              lauchCallBack: homeCallBack,
            ),
          ),
        ),
        Navigator(
          onGenerateRoute: (route) => MaterialPageRoute(
            settings: route,
            builder: (context) => GuestView(
              lauchCallBack: homeCallBack,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _firebaseProvider = Provider.of<FirebaseProvider>(context);
    authProvider = Provider.of<AuthProvider>(context);
    locationProvider = Provider.of<LocationProvider>(context);
    _firebaseProvider.setHomeContext(context);
    authProvider.setHomeContext(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: AppColors.kAppScreenBackGround,
        resizeToAvoidBottomInset: false,
//      body: PageStorage(
//        child: screens[currentTab],
//        bucket: bucket,
//      ),
        body:
            guestViewMain != null && guestViewMain ? guestView() : normalView(),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(top: 24),
          height: Constants.FLOATING_BUTTON_SIZE,
          width: Constants.FLOATING_BUTTON_SIZE,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4),
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            elevation: 0.0,
            child: CustomFloatingButton(),
            onPressed: () {
              if (guestViewMain != null && guestViewMain) {
                Navigator.push(
                  context,
                  new CupertinoPageRoute(builder: (BuildContext context) {
                    return Material(
                        child: new GuestView(
                      lauchCallBack: homeCallBack,
                    ));
                  }),
                );
              } else {
                redirect();
              }
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          //  height: 90,
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon:
                      bottomMenuIconWidget(AssetStrings.home_inactive, 22, 23),
                  activeIcon:
                      bottomMenuIconWidget(AssetStrings.home_active, 22, 23),
                  label: ""),
              BottomNavigationBarItem(
                  icon: bottomMenuIconWidget(AssetStrings.job_inactive, 25, 23),
                  activeIcon:
                      bottomMenuIconWidget(AssetStrings.job_active, 25, 23),
                  label: ""),
              BottomNavigationBarItem(
                  icon: firstWidget(AppColors.kWhite, AssetStrings.group),
                  activeIcon: firstWidget(AppColors.kWhite, AssetStrings.group),
                  label: ""),
              BottomNavigationBarItem(
                  icon: bottomMenuIconWidget(
                      (_isNewActivityFound)
                          ? AssetStrings.activity_unselected_with_noti
                          : AssetStrings.activity_not_selected,
                      26,
                      26),
                  activeIcon: bottomMenuIconWidget(
                      (_isNewActivityFound)
                          ? AssetStrings.activity_selected_with_noti
                          : AssetStrings.activity_selected,
                      26,
                      26),
                  label: ""),
              BottomNavigationBarItem(
                  icon: bottomMenuIconWidget(
                      AssetStrings.profile_inactive, 19, 24),
                  activeIcon:
                      bottomMenuIconWidget(AssetStrings.profile_active, 19, 24),
                  label: ""),
            ],
            currentIndex: currentTab,
            onTap: (int index) {
              setState(() {
                currentTab = index;
                if (index == 0) //for home tab
                {
                  SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.light);

                  _homeScreen.currentState?.popUntil((route) => route.isFirst);
                } else if (index == 2) {
                  redirect();
                } else {
                  SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark);
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget firstWidget(Color color, String image) {
    return SvgPicture.asset(image,
        width: Constants.bottomIconSize,
        height: Constants.bottomIconSize,
        color: color);
  }

  Widget bottomMenuIconWidget(String image, double width, double height) {
    return Center(
      child: SvgPicture.asset(
        image,
        width: width,
        height: height,
      ),
    );
  }

  void _setupCounterChangeListener() {
    _firebaseProvider.setStreamNotifier(StreamController<bool>());
    _firebaseProvider.notificationStreamController.stream.listen((event) {
      print("notificatoion count status $event");

      if (event != _isNewActivityFound) {
        print("update called");
        _isNewActivityFound = event;
        setState(() {});
      }
    });
  }
}

class CustomFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        width: Constants.FLOATING_BUTTON_SIZE,
        height: Constants.FLOATING_BUTTON_SIZE,
        decoration: BoxDecoration(
            color: AppColors.colorDarkCyan, shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Image.asset(
            AssetStrings.floatingplushome,
          ),
        ));
  }
}
