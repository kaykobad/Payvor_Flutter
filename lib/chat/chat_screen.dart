import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/chat/decorator_view.dart';
import 'package:payvor/notifications/notification.dart';
import 'package:payvor/pages/payment/search_message.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback logoutCallBack;

  ChatScreen({@required this.logoutCallBack});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  TabController tabBarController;
  int _tabIndex = 0;
  String image;
  double currentIndexPage = 0.0;

  final StreamController<int> _streamControllerActiveUsers =
      StreamController<int>();

  final StreamController<int> _streamControllerProjects =
      StreamController<int>();

  @override
  void initState() {
    tabBarController =
        new TabController(initialIndex: _tabIndex, length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamControllerActiveUsers.close();
    _streamControllerProjects.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return SafeArea(
      child: new Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            children: <Widget>[
              Material(
                child: Container(
                  decoration: new BoxDecoration(color: Colors.white),
                  padding: new EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          width: screensize.width,
                          height: 40.0,
                          child: DecoratedTabBar(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 1.0,
                                      color:
                                          Color.fromRGBO(151, 151, 151, 0.2)),
                                ),
                                color: Colors.transparent),
                            tabBar: new TabBar(
                                indicatorColor: Color.fromRGBO(37, 26, 101, 1),
                                labelStyle: new TextStyle(
                                    fontSize: 18,
                                    fontFamily: AssetStrings.circulerMedium),
                                indicatorWeight: 3,
                                indicatorSize: TabBarIndicatorSize.tab,
                                isScrollable: false,
                                unselectedLabelStyle: new TextStyle(
                                    fontSize: 18,
                                    fontFamily: AssetStrings.circulerMedium),
                                unselectedLabelColor:
                                    Color.fromRGBO(103, 99, 99, 1),
                                labelColor: Color.fromRGBO(37, 26, 101, 1),
                                labelPadding: new EdgeInsets.only(left: 15.0),
                                indicatorPadding:
                                    new EdgeInsets.only(left: 15.0),
                                controller: tabBarController,
                                tabs: <Widget>[
                                  new Tab(text: "Messages"),
                                  new Tab(
                                    text: "Notifications",
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: new TabBarView(
                    controller: tabBarController,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      new SearchMessage(),
                      new Notifications()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
