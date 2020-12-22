import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/common_response/common_success_response.dart';
import 'package:payvor/model/create_payvor/create_payvor_response.dart';
import 'package:payvor/model/create_payvor/payvorcreate.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/forgot_password/forgot_password_request.dart';
import 'package:payvor/model/forgot_password/forgot_password_response.dart';
import 'package:payvor/model/logged_in_user/logged_in_user_response.dart';
import 'package:payvor/model/login/loginrequest.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/otp/otp_request.dart';
import 'package:payvor/model/otp/otp_verification_response.dart';
import 'package:payvor/model/otp/resendotpresponse.dart';
import 'package:payvor/model/reset_password/reset_pass_request.dart';
import 'package:payvor/model/signup/signup_social_request.dart';
import 'package:payvor/model/signup/signuprequest.dart';
import 'package:payvor/model/update_profile/update_profile_request.dart';
import 'package:payvor/model/update_profile/update_profile_response.dart';
import 'package:payvor/networkmodel/APIHandler.dart';
import 'package:payvor/networkmodel/APIs.dart';
import 'package:payvor/pages/get_favor_list/favor_list_response.dart';

class AuthProvider with ChangeNotifier {
  var _isLoading = false;

  getLoading() => _isLoading;

  Future<dynamic> login(LoginRequest request, BuildContext context) async {
    print(APIs.loginUrl);
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.loginUrl, requestBody: request.toJson());

    hideLoader();
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      LoginSignupResponse loginSignupResponse = new LoginSignupResponse.fromJson(response);
      completer.complete(loginSignupResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> signup(SignUpRequest requests, BuildContext context) async {
    //  var request="?name=$name&email=$email&password=$password&type=$type";

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.signUpUrl, requestBody: requests.toJson());
    print(APIs.signUpUrl);

    var status = response["status"];

    if (status == false) {
      var data = response["data"]["email"][0];

      APIError apiError = new APIError(
        error: data,
        messag: data,
        status: 400,
        onAlertPop: () {},
      );
      completer.complete(apiError);
      return completer.future;
    } else {
      if (response is APIError) {
        completer.complete(response);
        return completer.future;
      } else {
        LoginSignupResponse loginResponseData =
            new LoginSignupResponse.fromJson(response);
        completer.complete(loginResponseData);
        notifyListeners();
        return completer.future;
      }
    }
  }

  Future<dynamic> socialSignup(
      SignUpSocialRequest requests, BuildContext context) async {

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.authSocialUrl,
        requestBody: requests.toJson());

    hideLoader();

//    try {
//      var status = response["status"];
//      if (status == false) {
//        var data = response["data"]["email"][0];
//
//        APIError apiError = new APIError(
//          error: data,
//          messag: data,
//          status: 400,
//          onAlertPop: () {},
//        );
//        completer.complete(apiError);
//        return completer.future;
//      }
//    }
//    catch(ex)
//    {
//      print("social error ${ex.toString()}");
//    }

    if (response is APIError) {
      completer.complete(response);
      notifyListeners();
      return completer.future;
    } else {
      LoginSignupResponse loginResponseData =
          new LoginSignupResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> refreshToken(BuildContext context) async {
    print(APIs.loginUrl);
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(context: context, url: APIs.refresh);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      LoginSignupResponse loginResponseData = new LoginSignupResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> loggedinUser(BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.post(context: context, url: APIs.looggedinUser);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      UserLoggedInResponse loginResponseData =
          new UserLoggedInResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> logout(BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.post(context: context, url: APIs.logoutUser);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      UserLoggedInResponse loginResponseData =
          new UserLoggedInResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> forgotPassword(
      ForgotPasswordRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.forgotPassword,
        requestBody: request.toJson());

    print(APIs.forgotPassword);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ForgotPasswordResponse loginResponseData =
          new ForgotPasswordResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> resetPassword(
      ResetPasswordRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.resetPassword,
        requestBody: request.toJson());

    print(APIs.resetPassword);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      CommonSuccessResponse loginResponseData =
          new CommonSuccessResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> createCredential(
      UpdateProfileRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.createPassword,
        requestBody: request.toJson());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      CommonSuccessResponse loginResponseData =
          new CommonSuccessResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> updateProfile(
      UpdateProfileRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.update_profile,
        requestBody: request.toJson());

    print(APIs.update_profile);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      try {
        var status = response["status"]["status"];

        print(response["error"]);
        if (status == false) {
          APIError apiError = new APIError(
            error: response["error"],
            messag: response["error"],
            status: 400,
            onAlertPop: () {},
          );
          completer.complete(apiError);
          return completer.future;
        }
        print(status);
      } catch (e) {}

      UpdateProfileResponse loginResponseData =
          new UpdateProfileResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> createPayvor(
      PayvorCreateRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.createPayvor,
        requestBody: request.toJson());

    print(APIs.createPayvor);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      try {
        var status = response["status"]["status"];

        print(response["error"]);
        if (status == false) {
          APIError apiError = new APIError(
            error: response["error"],
            messag: response["error"],
            status: 400,
            onAlertPop: () {},
          );
          completer.complete(apiError);
          return completer.future;
        }
        print(status);
      } catch (e) {}

      FavourCreateResponse loginResponseData =
          new FavourCreateResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> verifyOtp(OtpRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.otpVerifyUrl,
        requestBody: request.toJson());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      OtpVerification otpVerification =
          new OtpVerification.fromJson(response);
      //if wrong otp
      if(!otpVerification.status.status)
        {
          var apiError=APIError(messag: "Wrong OTP",status: 400);
          completer.complete(apiError);
        }
      else
        {
          completer.complete(otpVerification);
        }

      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getotp(String phoneNumber, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.getOtpUrl + phoneNumber);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ResendOtpResponse resendOtpResponse = new ResendOtpResponse.fromJson(
          response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getFavorPostDetails(BuildContext context, String id) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.favoeDetails + id);


    print(APIs.favoeDetails + id);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      FavourDetailsResponse resendOtpResponse =
          new FavourDetailsResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getFavorList(BuildContext context, int page) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.getFavorList + "?page=$page");

    print(APIs.getFavorList);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      GetFavorListResponse resendOtpResponse =
          new GetFavorListResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getSearchList(
      String data, BuildContext context, int page) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.seacrhList + data + "?page=$page");

    print(APIs.seacrhList + data);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      GetFavorListResponse resendOtpResponse =
          new GetFavorListResponse.fromJson(response);
      completer.complete(resendOtpResponse);
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
