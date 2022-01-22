import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/chat/decorator_view.dart';
import 'package:payvor/pages/myjobs/my_jobs.dart';
import 'package:payvor/pages/myposts/my_posts.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';

class PostScreen extends StatefulWidget {
  final ValueChanged<Widget> lauchCallBack;

  PostScreen({@required this.lauchCallBack});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<PostScreen> with TickerProviderStateMixin {
  TabController tabBarController;
  int _tabIndex = 0;
  String image;
  double currentIndexPage = 0.0;
  final StreamController<int> _streamControllerActiveUsers =
      StreamController<int>();
  final StreamController<int> _streamControllerProjects =
      StreamController<int>();
  var screensize;

  @override
  void initState() {
    tabBarController =
        new TabController(initialIndex: _tabIndex, length: 2, vsync: this);
  }

  @override
  void dispose() {
    _streamControllerActiveUsers.close();
    _streamControllerProjects.close();
    super.dispose();
  }

  get tabs => Expanded(
        child: Container(
          width: screensize.width,
          height: 40.0,
          child: DecoratedTabBar(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      width: 1.0, color: Color.fromRGBO(151, 151, 151, 0.2)),
                ),
                color: Colors.transparent),
            tabBar: new TabBar(
                indicatorColor: AppColors.colorDarkCyan,
                labelStyle: new TextStyle(
                    fontSize: 18, fontFamily: AssetStrings.circulerMedium),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: false,
                unselectedLabelStyle: new TextStyle(
                    fontSize: 18, fontFamily: AssetStrings.circulerMedium),
                unselectedLabelColor: Color.fromRGBO(103, 99, 99, 1),
                labelColor: AppColors.colorDarkCyan,
                controller: tabBarController,
                tabs: <Widget>[
                  new Tab(text: "My Posts"),
                  new Tab(
                    text: "My Jobs",
                  ),
                ]),
          ),
        ),
      );

  get tabView => Expanded(
        child: Container(
          child: new TabBarView(
            controller: tabBarController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              new MyPosts(lauchCallBack: widget.lauchCallBack),
              new MyJobs(lauchCallBack: widget.lauchCallBack)
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    screensize = MediaQuery.of(context).size;
    return SafeArea(
      child: new Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            children: <Widget>[
              Material(
                child: Container(
                  decoration: new BoxDecoration(color: Colors.white),
                  padding: new EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: <Widget>[tabs],
                  ),
                ),
              ),
              tabView
            ],
          ),
        ),
      ),
    );
  }
}
