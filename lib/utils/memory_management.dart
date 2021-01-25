
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SharedPrefsKeys.dart';

class MemoryManagement {
  static SharedPreferences prefs;

  static Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  static void setAccessToken({@required String accessToken}) {
    prefs.setString(SharedPrefsKeys.ACCESS_TOKEN, accessToken);
  }

  static String getAccessToken() {
    return prefs.getString(SharedPrefsKeys.ACCESS_TOKEN);
  }

  static void setuserName({@required String username}) {
    prefs.setString(SharedPrefsKeys.NAME, username);
  }

  static String getuserName() {
    return prefs.getString(SharedPrefsKeys.NAME);
  }




  static void setVerifyMailTemp({@required bool verify}) {
    prefs.setBool(SharedPrefsKeys.MAIL_VERIFY_TEMP, verify);
  }

  static bool getVerifyMailTemp() {
    return prefs.getBool(SharedPrefsKeys.MAIL_VERIFY_TEMP);
  }

  static void setVerifyMail({@required bool verify}) {
    prefs.setBool(SharedPrefsKeys.MAIL_VERIFY, verify);
  }

  static bool getVerifyMail() {
    return prefs.getBool(SharedPrefsKeys.MAIL_VERIFY);
  }

  static void setShowReelId({@required String id}) {
    prefs.setString(SharedPrefsKeys.SHOWREELID, id);
  }

  static String getShowReelId() {
    return prefs.getString(SharedPrefsKeys.SHOWREELID);
  }

  static String getPayPalId() {
    return prefs.getString(SharedPrefsKeys.PAYPAL_ID);
  }

  static void setPayPalId({@required String id}) {
    prefs.setString(SharedPrefsKeys.PAYPAL_ID, id);
  }

  static void setImage({@required String image}) {
    prefs.setString(SharedPrefsKeys.IMAGE, image);
  }

  static String getImage() {
    return prefs.getString(SharedPrefsKeys.IMAGE);
  }

  static void setNotificationOnOff({@required bool onoff}) {
    prefs.setBool(SharedPrefsKeys.NOTIFICATION_ONOFF, onoff);
  }

  static bool getNotificationOnOff() {
    return prefs.getBool(SharedPrefsKeys.NOTIFICATION_ONOFF);
  }


  static void setToolTipState({@required int state}) {
    prefs.setInt(SharedPrefsKeys.TUTORIAL_STATE, state);
  }

  static int getToolTipState() {
    return prefs.getInt(SharedPrefsKeys.TUTORIAL_STATE);
  }



  static void setSocialStatus({@required bool status}) {
    prefs.setBool(SharedPrefsKeys.LOGIN_STATUS, status);
  }

  static bool getSocialStatus() {
    return prefs.getBool(SharedPrefsKeys.LOGIN_STATUS);
  }

  static void setFilterData({@required String filter}) {
    prefs.setString(SharedPrefsKeys.FILTER_DATA, filter);
  }

  static String getFilterData() {
    return prefs.getString(SharedPrefsKeys.FILTER_DATA);
  }

  static void setFilterDataStatus({@required bool filterstatus}) {
    prefs.setBool(SharedPrefsKeys.FILTER_DATA_STATUS, filterstatus);
  }

  static bool getFilterDataStatus() {
    return prefs.getBool(SharedPrefsKeys.FILTER_DATA_STATUS);
  }

  static void setTabDataStatus({@required bool filterstatus}) {
    prefs.setBool(SharedPrefsKeys.TAB_DATA_STATUS, filterstatus);
  }

  static bool getAccountFilterDataStatus() {
    return prefs.getBool(SharedPrefsKeys.ACCCOUNT_DATA_STATUS);
  }

  static void setAccountFilterDataStatus({@required bool filterstatus}) {
    prefs.setBool(SharedPrefsKeys.ACCCOUNT_DATA_STATUS, filterstatus);
  }

  static void setAccountFilterData({@required String filter}) {
    prefs.setString(SharedPrefsKeys.ACCOUNT_FILTER_DATA, filter);
  }

  static String getAccountFilterData() {
    return prefs.getString(SharedPrefsKeys.ACCOUNT_FILTER_DATA);
  }

  static bool getTabDataStatus() {
    return prefs.getBool(SharedPrefsKeys.TAB_DATA_STATUS);
  }

  static void setDeviceId({@required String deviceID}) {
    prefs.setString(SharedPrefsKeys.DEVICE_ID, deviceID);
  }

  static String getDeviceId() {
    return prefs?.getString(SharedPrefsKeys.DEVICE_ID);
  }

  static Future<void> setScreenType({@required String type}) async {
    prefs.setString(SharedPrefsKeys.SCREEN_TYPE, type);
  }

  static String getScreenType() {
    return prefs?.getString(SharedPrefsKeys.SCREEN_TYPE);
  }

  static void setUserInfo({@required String userInfo}) {
    prefs.setString(SharedPrefsKeys.USER_INFO, userInfo);
  }

  static String getUserInfo() {
    return prefs.getString(SharedPrefsKeys.USER_INFO);
  }

  static void setYoutubeToken({@required String token}) {
    prefs.setString(SharedPrefsKeys.YOUTUBE_TOKEN, token);
  }

  static String getYoutubeToken() {
    return prefs.getString(SharedPrefsKeys.YOUTUBE_TOKEN);
  }

  static void setVimeoToken({@required String token}) {
    prefs.setString(SharedPrefsKeys.VIMEO_TOKEN, token);
  }

  static String getVimeoToken() {
    return prefs.getString(SharedPrefsKeys.VIMEO_TOKEN);
  }


  static void setUserLoggedIn({@required bool isUserLoggedin}) {
    prefs.setBool(SharedPrefsKeys.IS_USER_LOGGED_IN, isUserLoggedin);
  }

  static bool getUserLoggedIn() {
    return prefs.getBool(SharedPrefsKeys.IS_USER_LOGGED_IN);
  }

  static void setUserType({@required String userType}) {
    prefs.setString(SharedPrefsKeys.USER_TYPE, userType);
  }

  static String getUserType() {
    return prefs?.getString(SharedPrefsKeys.USER_TYPE);
  }

  static void setUserLanguage({@required String languageCode}) {
    prefs.setString(SharedPrefsKeys.LANGUAGE_CODE, languageCode);
  }

  static String getUserLanguage() {
    return prefs?.getString(SharedPrefsKeys.LANGUAGE_CODE);
  }


  static void setRoleCount({@required int role}) {
    prefs.setInt(SharedPrefsKeys.COUNT_ROLE, role);
  }

  static int getRoleCount() {
    return prefs?.getInt(SharedPrefsKeys.COUNT_ROLE);
  }



  static void setUserPushNotificationsStatus({@required int status}) {
    prefs.setInt(SharedPrefsKeys.PUSH_NOTIFICATIONS_STATUS, status);
  }

  static bool getUserPushNotificationsStatus() {
    return prefs?.getInt(SharedPrefsKeys.PUSH_NOTIFICATIONS_STATUS) == 1;
  }

  static void setDeepLinkTimestamp({@required int timestamp}) {
    prefs.setInt(SharedPrefsKeys.DEEPLINK_TIMESTAMP, timestamp);
  }

  static int getDeepLinkTimestamp() {
    return prefs?.getInt(SharedPrefsKeys.DEEPLINK_TIMESTAMP);
  }

  static void setConfirmationUser({@required bool isConfirmUser}) {
    prefs.setBool(SharedPrefsKeys.CONFIRMATION_USER, isConfirmUser);
  }

  static bool getConfirmationUser() {
    return prefs.getBool(SharedPrefsKeys.CONFIRMATION_USER);
  }

  // Paginating list data storage

  // ASSET_MILLS
  static void setAssetMills({@required String millsData}) {
    prefs.setString(SharedPrefsKeys.ASSET_MILLS, millsData);
  }

  static String getAssetMills() {
    return prefs.getString(SharedPrefsKeys.ASSET_MILLS);
  }

  // ASSET_FARMERS
  static void setAssetFarmers({@required String farmersData}) {
    prefs.setString(SharedPrefsKeys.ASSET_FARMERS, farmersData);
  }

  static String getAssetFarmers() {
    return prefs.getString(SharedPrefsKeys.ASSET_FARMERS);
  }

  // ASSET_EXPORTERS
  static void setAssetExporters({@required String exportersData}) {
    prefs.setString(SharedPrefsKeys.ASSET_EXPORTERS, exportersData);
  }

  static String getAssetExporters() {
    return prefs.getString(SharedPrefsKeys.ASSET_EXPORTERS);
  }

  // ASSET_COOPS
  static void setAssetCoops({@required String coopsData}) {
    prefs.setString(SharedPrefsKeys.ASSET_COOPS, coopsData);
  }

  static String getAssetCoops() {
    return prefs.getString(SharedPrefsKeys.ASSET_COOPS);
  }

  // ASSET_IMPORTERS
  static void setAssetImporters({@required String importersData}) {
    prefs.setString(SharedPrefsKeys.ASSET_IMPORTERS, importersData);
  }

  static String getAssetImporters() {
    return prefs.getString(SharedPrefsKeys.ASSET_IMPORTERS);
  }

  // ASSET_CAFE_STORES
  static void setAssetCafeStores({@required String cafeStoresData}) {
    prefs.setString(SharedPrefsKeys.ASSET_CAFE_STORES, cafeStoresData);
  }

  static String getAssetCafeStores() {
    return prefs.getString(SharedPrefsKeys.ASSET_CAFE_STORES);
  }

  // ASSET_ROASTER
  static void setAssetRoasters({@required String roastersData}) {
    prefs.setString(SharedPrefsKeys.ASSET_ROASTERS, roastersData);
  }

  static String getAssetRoasters() {
    return prefs.getString(SharedPrefsKeys.ASSET_ROASTERS);
  }

  static void setAccessGrant() {
    prefs.setBool(SharedPrefsKeys.GRANT_ACCESS, true);
  }

  static bool getAccessGrant() {
    return prefs?.getBool(SharedPrefsKeys.GRANT_ACCESS);
  }
  static void setHideProfile(bool status) {
    prefs.setBool(SharedPrefsKeys.HIDE_PROFILE, status);
  }

  static bool getHideProfile() {
    return prefs?.getBool(SharedPrefsKeys.HIDE_PROFILE);
  }

  static void setCurrentProjectName(String projectName) {
    prefs.setString(SharedPrefsKeys.PROJECT_NAME, projectName);
  }

  static String getCurrentProjectName() {
    return prefs?.getString(SharedPrefsKeys.PROJECT_NAME);
  }

  static void setUpgradedAccount(bool upgradecount) {
    prefs.setBool(SharedPrefsKeys.IS_UPGRADED_ACCOUNT, upgradecount);
  }

  static bool getUpgradedAccount() {
    return prefs?.getBool(SharedPrefsKeys.IS_UPGRADED_ACCOUNT);
  }


  //clear all values from shared preferences
  static void clearMemory()async {
    await prefs.clear();
  }

  //Theme module
  static void changeTheme(bool value) {
     prefs.setBool(SharedPrefsKeys.is_dark_mode, value);
  }

  static bool get isDarkMode {
    return prefs.getBool(SharedPrefsKeys.is_dark_mode) ?? false;
  }

  //Locale module
  static String get appLocale {
    return prefs.getString(SharedPrefsKeys.language_code) ?? null;
  }

  static void changeLanguage(String value) {
    prefs.setString(SharedPrefsKeys.language_code, value);
  }

  static void socialMediaStatus(String value) {
    prefs.setString(SharedPrefsKeys.USER_SOCIAL_STATUS, value);
  }

  static String getSocialMediaStatus() {
    return prefs?.getString(SharedPrefsKeys.USER_SOCIAL_STATUS);
  }

  static void setUserEmail(String value) {
    prefs.setString(SharedPrefsKeys.USER_EMAIL, value);
  }

  static String getUserEmail() {
    return prefs?.getString(SharedPrefsKeys.USER_EMAIL);
  }
}
