import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/utils/memory_management.dart';

import 'login/login.dart';

class Dummy extends StatelessWidget {
  final VoidCallback logoutCallBack;
  Dummy({@required this.logoutCallBack});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("comming soon",style: TextStyle(fontSize: 20))),
          Center(
            child: TextButton(
                onPressed: logoutCallBack,
                child: Text("Logout",style: TextStyle(fontSize: 20),)),
          )
        ],
      ),
    );
  }


}