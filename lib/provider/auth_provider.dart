import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:payvor/current_user_hired_by_favor/current_user_favor_hire.dart';
import 'package:payvor/current_user_hired_by_favor/current_user_hire_favor.dart';
import 'package:payvor/filter/filter_request.dart';
import 'package:payvor/filter/refer_request.dart';
import 'package:payvor/filter/refer_response.dart';
import 'package:payvor/filter/refer_user.dart';
import 'package:payvor/filter/refer_user_response.dart';
import 'package:payvor/model/add_paypal/add_paypal_request.dart';
import 'package:payvor/model/add_paypal/get_paypal_data.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/applied_user/favour_applied_user.dart';
import 'package:payvor/model/category/category_response.dart';
import 'package:payvor/model/common_response/common_success_response.dart';
import 'package:payvor/model/common_response/favour_end_job_response.dart';
import 'package:payvor/model/create_payvor/create_payvor_response.dart';
import 'package:payvor/model/create_payvor/payvorcreate.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/favour_posted_by_user.dart';
import 'package:payvor/model/forgot_password/forgot_password_request.dart';
import 'package:payvor/model/forgot_password/forgot_password_response.dart';
import 'package:payvor/model/hide_post_request.dart';
import 'package:payvor/model/hiew/hire_list.dart';
import 'package:payvor/model/hired_user_response_details/hired_user_response-details.dart';
import 'package:payvor/model/logged_in_user/logged_in_user_response.dart';
import 'package:payvor/model/login/loginrequest.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/my_profile_job_hire/my_profile_job_hire_response.dart';
import 'package:payvor/model/my_profile_job_hire/my_profile_response.dart';
import 'package:payvor/model/otp/otp_forgot_request.dart';
import 'package:payvor/model/otp/otp_request.dart';
import 'package:payvor/model/otp/resendotpresponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_details/report_request.dart';
import 'package:payvor/model/promotion/promotion_response.dart';
import 'package:payvor/model/rating/give_rating_request.dart';
import 'package:payvor/model/rating_list/rating_list.dart';
import 'package:payvor/model/report_reason/report_reason_response.dart';
import 'package:payvor/model/reset_password/reset_pass_request.dart';
import 'package:payvor/model/signup/signup_social_request.dart';
import 'package:payvor/model/signup/signuprequest.dart';
import 'package:payvor/model/stripe/stripe_add_users.dart';
import 'package:payvor/model/stripe/stripe_get_users.dart';
import 'package:payvor/model/suggest/suggest_response.dart';
import 'package:payvor/model/update_firebase_token/update_firebase_token_response.dart';
import 'package:payvor/model/update_firebase_token/update_token_request.dart';
import 'package:payvor/model/update_profile/update_profile_request.dart';
import 'package:payvor/model/update_profile/update_profile_response.dart';
import 'package:payvor/model/update_status/update_status_request.dart';
import 'package:payvor/networkmodel/APIHandler.dart';
import 'package:payvor/networkmodel/APIs.dart';
import 'package:payvor/notifications/notification_response.dart';
import 'package:payvor/pages/get_favor_list/favor_list_response.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/memory_management.dart';

class AuthProvider with ChangeNotifier {
  var _isLoading = false;

  BuildContext _context;

  getHomeContext() => _context;

  void setHomeContext(BuildContext context) {
    _context = context;
  }

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
      LoginSignupResponse loginSignupResponse =
          new LoginSignupResponse.fromJson(response);
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

//    var status = response["status"];
//
//    if (status == false) {
//      var data = response["data"]["email"][0];
//
//      APIError apiError = new APIError(
//        error: data,
//        messag: data,
//        status: 400,
//        onAlertPop: () {},
//      );
//      completer.complete(apiError);
//      return completer.future;
//    } else {
//      if (response is APIError) {
//        completer.complete(response);
//        return completer.future;
//      } else {
//        LoginSignupResponse loginResponseData =
//            new LoginSignupResponse.fromJson(response);
//        completer.complete(loginResponseData);
//        notifyListeners();
//        return completer.future;
//      }
//    }
    if (response is APIError) {
      response.error = "The email has already been taken";
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
      LoginSignupResponse loginResponseData =
          new LoginSignupResponse.fromJson(response);
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

  Future<dynamic> addPaypalMethod(
      PayPalAddRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();

    var response = await APIHandler.post(
        context: context, url: APIs.addPaypal, requestBody: request.toJson());

    print(APIs.addPaypal);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse loginResponseData = new ReportResponse.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getPaypalMethod(BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();

    var response = await APIHandler.get(context: context, url: APIs.getPaypal);

    print(APIs.getPaypal);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      GetPaypalData loginResponseData = new GetPaypalData.fromJson(response);
      completer.complete(loginResponseData);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> deletePaypalMethod(BuildContext context, String id) async {
    Completer<dynamic> completer = new Completer<dynamic>();

    var response =
        await APIHandler.get(context: context, url: APIs.deletePaypal + id);

    print(APIs.deletePaypal);

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
      LoginSignupResponse otpVerification =
          new LoginSignupResponse.fromJson(response);
      //if wrong otp
      if (!otpVerification.status.status) {
        var apiError = APIError(messag: "Wrong OTP", status: 400);
        completer.complete(apiError);
      } else {
        completer.complete(otpVerification);
      }

      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> verifyEmailVerify(
      OtpForgotRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.otpVerifyForgotUrl,
        requestBody: request.toJson());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      LoginSignupResponse otpVerification =
          new LoginSignupResponse.fromJson(response);
      //if wrong otp
      if (!otpVerification?.status?.status) {
        var apiError = APIError(messag: "Wrong OTP", status: 400);
        completer.complete(apiError);
      } else {
        completer.complete(otpVerification);
      }

      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> referUser(
      ReferUserRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.referUser, requestBody: request.toJson());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReferUserResponse otpVerification =
          new ReferUserResponse.fromJson(response);
      //if wrong otp

      completer.complete(otpVerification);
    }

    notifyListeners();
    return completer.future;
  }

  Future<dynamic> reportUser(
      ReportPostRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.reportFavour,
        requestBody: request.toJson());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse otpVerification = new ReportResponse.fromJson(response);
      //if wrong otp

      completer.complete(otpVerification);
    }

    notifyListeners();
    return completer.future;
  }

  Future<dynamic> deletePost(String id, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.deletePost + id + "/1");
    hideLoader();
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse otpVerification = new ReportResponse.fromJson(response);
      completer.complete(otpVerification);
    }

    notifyListeners();
    return completer.future;
  }

  Future<dynamic> hidePost(String postId, int type, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var hidePost = new HidePostRequest(postId: postId);
    var response = await APIHandler.post(
        context: context, url: APIs.hidePost+"?post_id=$postId&block_user=$type");
    hideLoader();
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse otpVerification = new ReportResponse.fromJson(response);
      completer.complete(otpVerification);
    }

    notifyListeners();
    return completer.future;
  }

  Future<dynamic> userHireList(String id, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.userHireFavList + id);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      UserHireListResponse otpVerification =
          new UserHireListResponse.fromJson(response);
      print("hired user list ${otpVerification.toJson()}");
      completer.complete(otpVerification);
    }

    notifyListeners();
    return completer.future;
  }

  Future<dynamic> userHire(
      String favid, String userid, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();

    print("url ${APIs.userHireFavList + favid + "/" + userid}");
    var response = await APIHandler.get(
        context: context, url: APIs.userHire + favid + "/" + userid);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      UserHireListResponse otpVerification =
          new UserHireListResponse.fromJson(response);
      //if wrong otp

      completer.complete(otpVerification);
    }

    notifyListeners();
    return completer.future;
  }

  Future<dynamic> applyFav(
      ReportPostRequest request, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.appliedFavor,
        requestBody: request.toJson());

    print("applied fav");

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse otpVerification = new ReportResponse.fromJson(response);
      //if wrong otp

      completer.complete(otpVerification);
    }

    notifyListeners();
    return completer.future;
  }

  Future<dynamic> getotp(
      String phoneNumber, String countryCode, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: "${APIs.getOtpUrl}$countryCode/$phoneNumber");

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      try {
        ResendOtpResponse resendOtpResponse =
            new ResendOtpResponse.fromJson(response);
        completer.complete(resendOtpResponse);
      } catch (ex) {
        completer.complete(APIError(error: Messages.genericError));
      }

      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getHiredFavorDetails(BuildContext context, String id) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.hiFavIdDetails + id?.toString());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      HiredUserDetailsResponse resendOtpResponse =
          new HiredUserDetailsResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getFavorPostDetailsProfile(
      BuildContext context, String id) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.favoeDetails + id);

    print(APIs.favoeDetails + id);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      EndedJobFavourResponse favourDetailsResponse =
          new EndedJobFavourResponse.fromJson(response);
      print("detail_response ${favourDetailsResponse.toJson()}");
      completer.complete(favourDetailsResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getFavorPostDetails(BuildContext context, String id) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.favoeDetails + id);

    print(APIs.favoeDetails + id);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      FavourDetailsResponse favourDetailsResponse =
          new FavourDetailsResponse.fromJson(response);
      print("detail_response ${favourDetailsResponse.toJson()}");
      completer.complete(favourDetailsResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getPromotionData(BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.getPromotionData);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      PropmoteDataResponse favourDetailsResponse =
          new PropmoteDataResponse.fromJson(response);
      completer.complete(favourDetailsResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getFavorList(BuildContext context, int page,
      FilterRequest filterRequest, ValueSetter<bool> voidcallback) async {
    var uri = APIs.getFavorList + "?page=$page";

    var data = new StringBuffer();

    if (filterRequest != null) {
      var isFilter = false;
      if (filterRequest.latlongData.isNotEmpty) {
        if (filterRequest.latlongData.length > 0) {
          var datas = filterRequest.latlongData.trim().toString().split(",");

          try {
            var lat = datas[0].toString();
            var long = datas[1].toString();

            data.write("&lat=$lat&long=$long");
          } catch (e) {}
        }
      } else {
        if (MemoryManagement.getUserInfo() != null &&
            MemoryManagement.getUserInfo().isNotEmpty) {
          var datas = jsonDecode(MemoryManagement.getUserInfo());
          var userinfo = LoginSignupResponse.fromJson(datas);

          if (userinfo?.user?.lat != "0" && userinfo?.user?.lat != "0.0") {
            data.write(
                "&lat=${userinfo?.user?.lat}&long=${userinfo?.user?.long}");
          }
        }
      }

      if (filterRequest.distance != null && filterRequest.distance > 0) {
        isFilter = true;
        data.write("&distance=${filterRequest?.distance?.toString()}");
      }
      if ((filterRequest.minprice != null && filterRequest.minprice > 0) ||
          (filterRequest.maxprice != null && filterRequest.maxprice < 100)) {
        isFilter = true;
        data.write(
            "&minprice=${filterRequest?.minprice?.toString()}&maxprice=${filterRequest?.maxprice?.toString()}");
      }
      if (filterRequest?.list != null) {
        var datanew = "";
        var isData = false;
        for (int i = 0; i < filterRequest.list.length; i++) {
          var dataitem = filterRequest.list[i];

          if (dataitem.isSelect) {
            if (!isData) {
              isData = true;
            }
            datanew = datanew + dataitem.sendTitle;
          }
        }
        if (datanew != null && isData) {
          isFilter = true;
          data.write("&sort_by=$datanew");
        }
      }

      if (filterRequest?.listCategory != null &&
          filterRequest?.listCategory.length > 0) {
        isFilter = true;
        data.write("&category_id=${filterRequest?.listCategory?.toString()}");
      }

      if (isFilter) {
        voidcallback(true);
      } else {
        voidcallback(false);
      }
      print("data $data");

      if (data.toString().length > 0) {
        uri = uri + data.toString();
      }
    } else {
      if (MemoryManagement.getUserInfo() != null &&
          MemoryManagement.getUserInfo()?.isNotEmpty) {
        var datas = jsonDecode(MemoryManagement.getUserInfo());
        var userinfo = LoginSignupResponse.fromJson(datas);
        if (userinfo?.user?.lat != "0" &&
            userinfo?.user?.lat != "0.0" &&
            userinfo?.user?.lat != null) {
          data.write(
              "&lat=${userinfo?.user?.lat}&long=${userinfo?.user?.long}");
        }
      }

      voidcallback(false);
      uri = uri + data.toString();
    }
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(context: context, url: uri);

    print(uri);
    hideLoader();
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

  Future<dynamic> getDeviceToken(BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.getDeviceToken);

    print(APIs.getDeviceToken);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("restoken $jsonDecode($response)");
      GetFavorListResponse resendOtpResponse =
          new GetFavorListResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getReferList(ReferRequest requests, BuildContext context,
      int page, ReferRequestNew requestsNew, int type) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.refUsers + "?page=$page",
        requestBody: type == 1 ? requests.toJson() : requestsNew.toJson());

    print(APIs.refUsers);
    print("request ${requests}");
    print("requestsNew ${requestsNew}");

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      ReferListResponse resendOtpResponse =
          new ReferListResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> updateTokenRequest(
      UpdateTokenRequest requests, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.put(
        context: context,
        url: APIs.updatetoken,
        requestBody: requests.toJson());
    print("updatetoken ${APIs.updatetoken}");
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      UpdateTokenResponse resendOtpResponse =
          new UpdateTokenResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> setCategory(BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(context: context, url: APIs.category);
    print("category ${APIs.category}");
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      CategoryResponse resendOtpResponse =
          new CategoryResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> giveUserRating(
      GiveRatingRequest requests, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.giveRating, requestBody: requests.toJson());
    print("give_rating ${APIs.giveRating}");
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse resendOtpResponse = new ReportResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getAddedCards(BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.getStripeUsers);
    hideLoader();
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      GetStripeResponse resendOtpResponse =
          new GetStripeResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> endedFavours(BuildContext context, String id) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.endFavours + id);
    print("addStripeUsers ${APIs.endFavours}");

    log(jsonEncode(response));
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      GetStripeResponse resendOtpResponse =
          new GetStripeResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> addStripeCards(
      BuildContext context, AddStripeRequest request) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.addStripeUsers,
        requestBody: request?.toJson());
    print("addStripeUsers ${APIs.addStripeUsers}");
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      AddStripeUsers resendOtpResponse = new AddStripeUsers.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> reportPostApi(
      GiveReportRequest requests, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.reportFavor,
        requestBody: requests.toJson());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse resendOtpResponse = new ReportResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> updateFavStatus(
      UpdateStatusRequest requests, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context,
        url: APIs.updateFavStatus,
        requestBody: requests.toJson());
    hideLoader();
    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse resendOtpResponse = new ReportResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> updatePushNotiStatus(
      BuildContext context, String userid) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
      context: context,
      url: APIs.updatePushStatus + userid?.toString(),
    );

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse resendOtpResponse = new ReportResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> deleteAccount(BuildContext context, String userid) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.deleteAccount + userid?.toString());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse resendOtpResponse = new ReportResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getReportReason(
    BuildContext context,
  ) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.gettingReportReason);

    print(APIs.gettingReportReason);
    print(APIs.gettingReportReason);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      GettingReportReason resendOtpResponse =
          new GettingReportReason.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> hiredFavourPost(
    BuildContext context,
    int page,
  ) async {
    print("fave");
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.favorHiredByUser);

    print(APIs.favorHiredByUser);
    print(APIs.favorHiredByUser);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      CurrentUserHiredFavorResponse resendOtpResponse =
          new CurrentUserHiredFavorResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> reviewList(BuildContext context, int page, String id) async {
    print("fave");

    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.ratingList + "/$id");

    print(APIs.ratingList);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");

      RatingReviewResponse resendOtpResponse =
          new RatingReviewResponse.fromJson(response);

      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> userProfileDetails(
      BuildContext context, int page, String userID) async {
    print("user id$userID");
    print(APIs.userProfileDetails);
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.userProfileDetails + userID);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      MyProfileResponse resendOtpResponse =
          new MyProfileResponse.fromJson(response);
      print("other profile response ${resendOtpResponse.toJson()}");

      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> favourpostedbyuser(
    BuildContext context,
    int page,
  ) async {
    print("fave");
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.favorPostedByUser);

    print(APIs.favorPostedByUser);
    print(APIs.favorPostedByUser + userinfo.user?.id?.toString());

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      FavourPostedByUserResponse resendOtpResponse =
          new FavourPostedByUserResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> favourjobapplieduser(
    BuildContext context,
    int page,
  ) async {
    print("fave");

    Completer<dynamic> completer = new Completer<dynamic>();
    var response =
        await APIHandler.get(context: context, url: APIs.favorAppliedByUser);

    print(APIs.favorAppliedByUser);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      FavourAppliedByUserResponse resendOtpResponse =
          new FavourAppliedByUserResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> currentuserhirefavor(
    BuildContext context,
    int page,
  ) async {
    print("fave");

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.currentuserhirebyfavor);

    print(APIs.currentuserhirebyfavor);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      CurrentUserHiredByFavorResponse resendOtpResponse =
          new CurrentUserHiredByFavorResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> myprofileendedjobs(
      BuildContext context, int page, String id) async {
    print("fave");

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.endJobs + id + "?page=$page");

    print(APIs.endJobs);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      EndedJobHireResponse resendOtpResponse =
          new EndedJobHireResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> myprofileendedFavors(
      BuildContext context, int page, String id) async {
    print("fave");

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.endFavors + id + "?page=$page");
    print(APIs.endFavors);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      EndedJobHireResponse resendOtpResponse =
          new EndedJobHireResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getNotificationList(
    BuildContext context,
    int page,
  ) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.notiUser + "?page=$page");

    print(APIs.notiUser);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      NotificationResponse resendOtpResponse =
          new NotificationResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> getSearchSuggestList(
      String data, BuildContext context, int page) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.seacrhSuggestList + data + "?page=$page");

    print(APIs.seacrhSuggestList + data);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      SuggestSearchResponse resendOtpResponse =
          new SuggestSearchResponse.fromJson(response);
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
