import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:payvor/current_user_hired_by_favor/current_user_favor_hire.dart';
import 'package:payvor/current_user_hired_by_favor/current_user_hire_favor.dart';
import 'package:payvor/filter/filter_request.dart';
import 'package:payvor/filter/refer_request.dart';
import 'package:payvor/filter/refer_response.dart';
import 'package:payvor/filter/refer_user.dart';
import 'package:payvor/filter/refer_user_response.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/applied_user/favour_applied_user.dart';
import 'package:payvor/model/common_response/common_success_response.dart';
import 'package:payvor/model/create_payvor/create_payvor_response.dart';
import 'package:payvor/model/create_payvor/payvorcreate.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/favour_posted_by_user.dart';
import 'package:payvor/model/forgot_password/forgot_password_request.dart';
import 'package:payvor/model/forgot_password/forgot_password_response.dart';
import 'package:payvor/model/hiew/hire_list.dart';
import 'package:payvor/model/hired_user_response_details/hired_user_response-details.dart';
import 'package:payvor/model/logged_in_user/logged_in_user_response.dart';
import 'package:payvor/model/login/loginrequest.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/otp/otp_request.dart';
import 'package:payvor/model/otp/otp_verification_response.dart';
import 'package:payvor/model/otp/resendotpresponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_details/report_request.dart';
import 'package:payvor/model/promotion/promotion_response.dart';
import 'package:payvor/model/rating/give_rating_request.dart';
import 'package:payvor/model/reset_password/reset_pass_request.dart';
import 'package:payvor/model/signup/signup_social_request.dart';
import 'package:payvor/model/signup/signuprequest.dart';
import 'package:payvor/model/suggest/suggest_response.dart';
import 'package:payvor/model/update_profile/update_profile_request.dart';
import 'package:payvor/model/update_profile/update_profile_response.dart';
import 'package:payvor/model/update_profile/user_hired_favor_response.dart';
import 'package:payvor/model/update_status/update_status_request.dart';
import 'package:payvor/networkmodel/APIHandler.dart';
import 'package:payvor/networkmodel/APIs.dart';
import 'package:payvor/notifications/notification_response.dart';
import 'package:payvor/pages/get_favor_list/favor_list_response.dart';
import 'package:payvor/utils/memory_management.dart';

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
        context: context, url: APIs.deletePost + id + "/0");

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
      //if wrong otp

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

  Future<dynamic> getotp(String phoneNumber, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.getOtpUrl + phoneNumber);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ResendOtpResponse resendOtpResponse =
          new ResendOtpResponse.fromJson(response);
      completer.complete(resendOtpResponse);
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
    var response = await APIHandler.get(
        context: context, url: APIs.getPromotionData);


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
      if (filterRequest.latlongData.isNotEmpty &&
          filterRequest.location.isNotEmpty) {
        if (filterRequest.latlongData.length > 0) {
          var datas = filterRequest.latlongData.trim().toString().split(",");

          try {
            var lat = datas[0].toString();
            var long = datas[1].toString();
            isFilter = true;

            data.write("&lat=$lat&long=$long");
          } catch (e) {}
        }
      } else {
        var datas = jsonDecode(MemoryManagement.getUserInfo());
        var userinfo = LoginSignupResponse.fromJson(datas);
        if (userinfo?.user?.lat != "0" && userinfo?.user?.lat != "0.0") {
          data.write(
              "&lat=${userinfo?.user?.lat}&long=${userinfo?.user?.long}");
        }
      }

      if (filterRequest.distance != null && filterRequest.distance > 0) {
        isFilter = true;
        data.write("&distance=${filterRequest?.distance?.toString()}");
      }
      if (filterRequest.minprice > 0 || filterRequest.maxprice < 100) {
        isFilter = true;
        data.write(
            "&minprice=${filterRequest?.minprice
                ?.toString()}&maxprice=${filterRequest?.maxprice?.toString()}");
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
            datanew = datanew + dataitem.sendTitle + ",";
          }
        }
        if (datanew != null && isData) {
          isFilter = true;
          data.write("&sort_by=$datanew");
        }
      }

      if (isFilter) {
        voidcallback(true);
      }
      else {
        voidcallback(false);
      }
      print("data $data");

      if (data
          .toString()
          .length > 0) {
        uri = uri + data.toString();
      }
    } else {
      var datas = jsonDecode(MemoryManagement.getUserInfo());
      var userinfo = LoginSignupResponse.fromJson(datas);
      if (userinfo?.user?.lat != "0" && userinfo?.user?.lat != "0.0") {
        data.write("&lat=${userinfo?.user?.lat}&long=${userinfo?.user?.long}");
      }
      voidcallback(false);
      uri = uri + data.toString();
    }
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(context: context, url: uri);

    print(uri);

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

  Future<dynamic> getReferList(ReferRequest requests, BuildContext context,
      int page, ReferRequestNew requestsNew, int type) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.refUsers + "?page=$page",
        requestBody: type == 1 ? requests.toJson() : requestsNew.toJson()
    );

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

  Future<dynamic> giveUserRating(
      GiveRatingRequest requests, BuildContext context) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.post(
        context: context, url: APIs.giveRating, requestBody: requests.toJson());

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
      print("res $jsonDecode($response)");
      CurrentUserHiredFavorResponse resendOtpResponse =
          new CurrentUserHiredFavorResponse.fromJson(response);
      completer.complete(resendOtpResponse);
      notifyListeners();
      return completer.future;
    }
  }

  Future<dynamic> userProfileDetails(
      BuildContext context, int page, String userID) async {
    print("fave");
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.userProfileDetails + userID);

    print(APIs.userProfileDetails);
    print(APIs.userProfileDetails);

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      print("res $jsonDecode($response)");
      UserProfileFavorResponse resendOtpResponse =
          new UserProfileFavorResponse.fromJson(response);
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
        await APIHandler.get(context: context, url: APIs.favorPostedByUser
    );

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


  Future<dynamic> favourjobapplieduser(BuildContext context,
      int page,) async {
    print("fave");

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.favorAppliedByUser
    );

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


  Future<dynamic> currentuserhirefavor(BuildContext context,
      int page,) async {
    print("fave");

    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.currentuserhirebyfavor
    );

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


  Future<dynamic> getNotificationList(BuildContext context,
      int page,) async {
    Completer<dynamic> completer = new Completer<dynamic>();
    var response = await APIHandler.get(
        context: context, url: APIs.notiUser + "?page=$page"
    );

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


  Future<dynamic> getSearchSuggestList(String data, BuildContext context,
      int page) async {
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
