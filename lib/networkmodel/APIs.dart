class APIs {
  APIs._();

  // Base url
  static const String baseUrl = "http://167.172.40.120/api/v1";

  //load image url
  static const String imageBaseUrl = "http://35.226.88.58";

  //new App Url
  static const String signUpUrl = "$baseUrl/auth/register";
  static const String authSocialUrl = "$baseUrl/auth/socialLogin";

  static const String loginUrl = "$baseUrl/auth/login";
  static const String homeUrl = "$baseUrl/home/";
  static const String refresh = "$baseUrl/auth/refresh";
  static const String looggedinUser = "$baseUrl/auth/me";
  static const String logoutUser = "$baseUrl/auth/logout";
  static const String otpVerifyUrl = "$baseUrl/auth/verify-otp-ph";
  static const String otpVerifyForgotUrl = "$baseUrl/auth/verify-otp-ph";
  static const String update_profile = "$baseUrl/auth/update-profile";
  static const String resetPassword = "$baseUrl/auth/change-password";
  static const String forgotPassword = "$baseUrl/auth/reset-pas-mail";
  static const String createPassword = "$baseUrl/auth/update-profile";
  static const String getOtpUrl = "$baseUrl/auth/send-otp-ph/";
  static const String hiFavIdDetails = "$baseUrl/hired-favour-detail/";
  static const String getFavorList = "$baseUrl/list-favour";
  static const String favoeDetails = "$baseUrl/favour-detail/";
  static const String getPromotionData = "$baseUrl/promo-list";
  static const String createPayvor = "$baseUrl/create-favour";
  static const String seacrhList = "$baseUrl/searchfavour/";
  static const String getDeviceToken = "$baseUrl/get-token";
  static const String seacrhSuggestList = "$baseUrl/searchtitle/";
  static const String refUsers = "$baseUrl/ref-user";
  static const String giveRating = "$baseUrl/give-rating";
  static const String updatetoken = "$baseUrl/update-token";
  static const String updateFavStatus = "$baseUrl/update-fav-status";
  static const String updatePushStatus = "$baseUrl/disable-push/";
  static const String deleteAccount = "$baseUrl/delete_account";
  static const String referUser = "$baseUrl/refer-user";
  static const String notiUser = "$baseUrl/noti-user";
  static const String reportFavor = "$baseUrl/report-hired-favour";
  static const String favorPostedByUser = "$baseUrl/myfavour";
  static const String favorHiredByUser = "$baseUrl/hiredfavour";
  static const String ratingList = "$baseUrl/rating-list";
  static const String gettingReportReason = "$baseUrl/rating-reasons";
  static const String userProfileDetails = "$baseUrl/userfavours/";
  static const String favorAppliedByUser = "$baseUrl/favourapplybyuser";
  static const String currentuserhirebyfavor = "$baseUrl/hiredbyfavour";
  static const String reportFavour = "$baseUrl/report-favour";
  static const String editFavour = "$baseUrl/edit-favour";
  static const String appliedFavor = "$baseUrl/applyfavour";
  static const String userHireFavList = "$baseUrl/appliedfavlist/";
  static const String endJobs = "$baseUrl/ended-jobs/";
  static const String endFavors = "$baseUrl/ended-favours/";
  static const String userHire = "$baseUrl/hire-user/";
  static const String deletePost = "$baseUrl/delete-repost-favour/";
}
