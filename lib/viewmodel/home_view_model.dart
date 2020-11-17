import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:payvor/model/home/homerequest.dart';
import 'package:payvor/model/places/placeitem.dart';






class HomeViewModel with ChangeNotifier {

  var _isLoading = false;

  getLoading() => _isLoading;


  List<Map<String, dynamic>> locations = [
    {
      "Location_Number": "-76.97892538.882767",
      "Location_Name": "John Dean and Hannibal Hamlin Burial Sites",
      "coordinates": [-76.978923660098019, 38.882767398397789]
    },
    {
      "Location_Number": "-77.16515878125193238.938782583950172",
      "Location_Name": "Camp Greene",
      "coordinates": [-77.165158781251932, 38.938782583950172]
    },
    {
      "Location_Number": "-77.04500938.919531",
      "Location_Name": "John Little Farm Site",
      "coordinates": [-77.045009, 38.919531]
    },
  ];

  Future<dynamic> getHomeData(HomeRequest request, BuildContext context) async {

    Completer<dynamic> completer = new Completer<dynamic>();
//    var response = await APIHandler.post(
//        context: context, url: APIs.loginUrl, requestBody: request.toJson());
    await Future.delayed(Duration(seconds: 0, milliseconds: 3000));

    hideLoader();
    completer.complete(locations);
    notifyListeners();
    return completer.future;
//    if (response is APIError) {
//      completer.complete(response);
//      return completer.future;
//    } else {
//
//      completer.complete(loginResponseData);
//      notifyListeners();
//      return completer.future;
//    }
  }

  Future<dynamic> getMediaStoreData(HomeRequest request, BuildContext context) async {

    Completer<dynamic> completer = new Completer<dynamic>();
//    var response = await APIHandler.post(
//        context: context, url: APIs.loginUrl, requestBody: request.toJson());
    await Future.delayed(Duration(seconds: 0, milliseconds: 3000));
    var imagesList=List<String>();
    for(var i=1;i<=100;i++)
      {
         imagesList.add("https://picsum.photos/250?image=$i");
      }
    hideLoader();
    completer.complete(imagesList);
    notifyListeners();
    return completer.future;
//    if (response is APIError) {
//      completer.complete(response);
//      return completer.future;
//    } else {
//
//      completer.complete(loginResponseData);
//      notifyListeners();
//      return completer.future;
//    }
  }

  Future<dynamic> getPlacesData(HomeRequest request, BuildContext context) async {

    Completer<dynamic> completer = new Completer<dynamic>();
//    var response = await APIHandler.post(
//        context: context, url: APIs.loginUrl, requestBody: request.toJson());
    await Future.delayed(Duration(seconds: 0, milliseconds: 3000));
    var placeList=List<PlacesItem>();
    for(var i=1;i<=100;i++)
    {
      var item=PlacesItem(imageUrl: "https://picsum.photos/250?image=$i",title: "What is Lorem Ipsum $i");
      placeList.add(item);
    }
    hideLoader();
    completer.complete(placeList);
    notifyListeners();
    return completer.future;
//    if (response is APIError) {
//      completer.complete(response);
//      return completer.future;
//    } else {
//
//      completer.complete(loginResponseData);
//      notifyListeners();
//      return completer.future;
//    }
  }

  void hideLoader() {
    _isLoading = false;
    notifyListeners();
  }

  void setLoading() {
    _isLoading = true;
    notifyListeners();
  }
}
