import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginreponse.dart';
import 'package:payvor/model/login/loginrequest.dart';
import 'package:payvor/networkmodel/APIHandler.dart';
import 'package:payvor/networkmodel/APIs.dart';






class AuthViewModel with ChangeNotifier {


  var _isLoading = false;

  getLoading() => _isLoading;




  Future<dynamic> login(LoginRequest request, BuildContext context) async {

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.loginUrl, requestBody: request.toJson());
    hideLoader();
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      LoginResponse loginResponseData = new LoginResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> signup(LoginRequest request, BuildContext context) async {

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.loginUrl, requestBody: request.toJson());
    hideLoader();
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      LoginResponse loginResponseData = new LoginResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
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
