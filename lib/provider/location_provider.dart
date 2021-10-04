import 'dart:async';

import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  StreamController<String> locationProvider;

  void initListener() {
    locationProvider = StreamController<String>();
  }

  void disposeListener() {
    locationProvider.close();
  }
}
