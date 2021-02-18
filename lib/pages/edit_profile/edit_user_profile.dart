import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/update_profile/update_profile_request.dart';
import 'package:payvor/networkmodel/APIs.dart';
import 'package:payvor/pages/intro_screen/splash_intro_new.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final FavourDetailsResponse favourDetailsResponse;
  bool isEdit;
  ValueSetter<int> voidcallback;

  EditProfile(
      {this.favourDetailsResponse, this.isEdit = false, this.voidcallback});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<EditProfile>
    with AutomaticKeepAliveClientMixin<EditProfile> {
  var screenSize;

  ScrollController scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _EmailController = new TextEditingController();
  TextEditingController _NameController = new TextEditingController();
  TextEditingController _PhoneController = new TextEditingController();
  TextEditingController _OldPasswordController = new TextEditingController();
  TextEditingController _NewPasswordController = new TextEditingController();
  TextEditingController _LocationController = new TextEditingController();
  TextEditingController _LatLongController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _TitleField = new FocusNode();
  FocusNode _NameField = new FocusNode();
  FocusNode _PriceField = new FocusNode();
  FocusNode _OldPasswordField = new FocusNode();
  FocusNode _NewPasswordField = new FocusNode();
  FocusNode _LocationField = new FocusNode();

  File _image; //to store profile image
  String profile;
  bool isValid = false;
  LoginSignupResponse userinfo;

  final StreamController<bool> _streamControllerShowLoader =
  StreamController<bool>();

  AuthProvider provider;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    /*if (widget.favourDetailsResponse != null) {
      _EmailController.text = widget?.favourDetailsResponse?.data?.title ?? "";
      _PhoneController.text = widget?.favourDetailsResponse?.data?.price ?? "";
      _OldPasswordController.text =
          widget?.favourDetailsResponse?.data?.description ?? "";
      _LocationController.text =
          widget?.favourDetailsResponse?.data?.location ?? "";
      profile = widget?.favourDetailsResponse?.data?.image ?? "";


      _LatLongController.text = widget?.favourDetailsResponse?.data?.lat + "," +
          widget?.favourDetailsResponse?.data?.long;

      */ /*  print("lat ${widget?.favourDetailsResponse?.data?.lat}");
      print("long ${widget?.favourDetailsResponse?.data?.long}");
      print("latlong ${ _LatLongController.text}");*/ /*
    }*/

    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    userinfo = LoginSignupResponse.fromJson(infoData);
    _EmailController.text = userinfo?.user?.email ?? "";
    _NameController.text = userinfo?.user?.name ?? "";
    _PhoneController.text = userinfo?.user?.phone ?? "";
    profile = userinfo?.user?.profilePic ?? "";
    print("profile");
    _LocationController.text = userinfo?.user?.location ?? "";
    _LatLongController.text = userinfo?.user?.lat + "," + userinfo?.user?.long;

    _setScrollListener();

    super.initState();
  }

  @override
  void dispose() {
    _streamControllerShowLoader.close(); //close the stream on dispose

    super.dispose();
  }

  void deleteAccount() async {
    provider.setLoading();
    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {},
      onSuccess: () {},
    );

    if (gotInternetConnection) {
      var response = await provider.deleteAccount(
          context, userinfo?.user?.id?.toString() ?? "");

      provider.hideLoader();

      if (response != null && response is ReportResponse) {
        await MemoryManagement.clearMemory();

        Navigator.pushAndRemoveUntil(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new SplashIntroScreenNew();
          }),
          (route) => false,
        );
      } else {
        showInSnackBar("Something went wrong, Please try again later!");
      }
    }
  }

  hitApi(int type) async {
    provider.setLoading();
    var lat = "0.0";
    var long = "0.0";

    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {
        provider.hideLoader();
      },
      onSuccess: () {},
    );

    if (!gotInternetConnection) {
      return;
    }

    if (_LatLongController.text.length > 0) {
      var data = _LatLongController.text.trim().toString().split(",");

      try {
        lat = data[0];
        long = data[1];
      } catch (e) {
        showInSnackBar("Please enter valid location");
        return;
      }
    } else {
      showInSnackBar("Please enter valid location");
      return;
    }
    Map<String, String> headers = {
//header
      "Content-Type": "multipart/form-data",
      "Accept": "application/json"
    };

    if (MemoryManagement.getAccessToken() != null) {
      headers["Authorization"] = "Bearer " + MemoryManagement.getAccessToken();
    }
    http.MultipartRequest request;

    //changed

    request = new http.MultipartRequest("POST", Uri.parse(APIs.update_profile));

    request.headers.addAll(headers);

    request.fields['name'] = _NameController.text;
    request.fields['location'] = _LocationController.text;

    if (_NewPasswordController.text.length > 0 &&
        _OldPasswordController.text.length > 0) {
      request.fields['password'] = _NewPasswordController.text;
      request.fields['old_password'] = _OldPasswordController.text;
    }

    request.fields['lat'] = lat;
    request.fields['long'] = long;

    if (_image != null) {
      final fileName = _image.path;
      print("imsgrs $fileName");

      var bytes = await _image.readAsBytes();

      request.files.add(new http.MultipartFile.fromBytes(
        "profile_pic",
        bytes,
        filename: fileName,
      ));
    }

/*
    PayvorCreateRequest loginRequest = new PayvorCreateRequest(
        title: _EmailController.text,
        location: _LocationController.text,
        description: _OldPasswordController.text,
        price: _PhoneController.text,
        lat: lat,
        long: long);
    var response = await provider.createPayvor(loginRequest, context);*/

    print(request.fields);

    http.StreamedResponse response = await request.send();
    provider.hideLoader();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print("respStr: $respStr");
      Map data = jsonDecode(respStr); // Parse data from JSON string

      LoginSignupResponse dataResponse = new LoginSignupResponse.fromJson(data);

      MemoryManagement.setUserInfo(userInfo: json.encode(dataResponse));

      _OldPasswordController.text = "";
      _NewPasswordController.text = "";

      showInSnackBar("Profile updated successfully.");

      setState(() {});
    } else {
      var data = await response.stream?.bytesToString();
      Map dataMap = jsonDecode(data);

      var stringdata = dataMap["data"];

      showInSnackBar(stringdata);
    }

/*
    if (response is FavourCreateResponse) {
      provider.hideLoader();

      print(response);
      try {
        showInSnackBar(response.success);
        */ /*   Navigator.pop(context);
        Navigator.pop(context);*/ /*
      } catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }*/
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  Future _getGalleryImage() async {
    var imageFileSelect = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: Constants.maxWidth,
        maxHeight: Constants.maxHeight);
    var imageFile = await ImageCropper.cropImage(
        sourcePath: imageFileSelect.path,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    _image = imageFile;
    setState(() {});
  }

  Future _getCameraImage() async {
    var imageFileSelect = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: Constants.maxWidth,
        maxHeight: Constants.maxHeight);

    var imageFile = await ImageCropper.cropImage(
        sourcePath: imageFileSelect.path,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    _image = null;

    _image = imageFile;

    setState(() {});
  }

  _crupitinoActionSheet() {
    return containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
          actions: <Widget>[
            //to show delete image option
            _image != null
                ? CupertinoActionSheetAction(
                    child: Text(
                      Constants.DELETE_PHOTO,
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      _image = null;
                      Navigator.pop(context);
                      setState(() {});
                    },
                  )
                : Container(),

            CupertinoActionSheetAction(
              child: Text(Constants.CAMERA),
              onPressed: () {
                _getCameraImage();
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Text(Constants.GALLARY),
              onPressed: () {
                _getGalleryImage();
                Navigator.pop(context);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(Constants.CANCEL),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _setScrollListener() {}

  Widget getTextField(
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      int lines) {
    return Container(
      padding: new EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      color: Colors.white,
      child: Stack(
        children: [
          new TextField(
            controller: controller,
            keyboardType: textInputType,
            style: TextThemes.blackTextFieldNormal,
            keyboardAppearance: Brightness.light,
            focusNode: focusNodeCurrent,
            maxLines: lines,
            enabled:
                controller == _EmailController || controller == _PhoneController
                    ? false
                    : true,
            onSubmitted: (String value) {
              /* if (focusNodeCurrent == _DescriptionField) {
                _DescriptionField.unfocus();
              } else {
                FocusScope.of(context).autofocus(focusNodeNext);
              }*/
            },
            decoration: new InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: labelText,

              contentPadding: new EdgeInsets.only(right: 50.0),
//              prefix: new Text(
//                  focusNodeCurrent == _PriceField&&_PriceField.hasFocus
//                      ? "€ "
//                      : ""),
              hintStyle: controller.text.length == 0
                  ? TextThemes.greyTextFieldHintNormal
                  : TextThemes.greyTextFieldHintNormal,
            ),
          ),
          new Positioned(
            right: 0.0,
            child: Container(
              margin: new EdgeInsets.only(top: 10),
              child: focusNodeCurrent == _PriceField ||
                      focusNodeCurrent == _TitleField
                  ? new Image.asset(
                      AssetStrings.lockProfile,
                      width: 17,
                      height: 20,
                    )
                  : Container(),
            ),
          )
        ],
      ),
    );
  }

  void callback() {
    if (getResult()) {
    } else {
      setState(() {});
    }
  }

  void callbackMain() {
    if (getResult()) {
      hitApi(2);
    } else {
      setState(() {});
    }
  }

  void hitUpdateProfile() {
    UpdateProfileRequest updateProfileRequest = new UpdateProfileRequest(
        name: _NameController.text, location: _LocationController.text);

    if (_NewPasswordController.text.length > 0 &&
        _OldPasswordController.text.length > 0) {
      updateProfileRequest.password = _NewPasswordController.text;
    }
  }

  bool getResult() {
    var name = _NameController.text;
    var password = _OldPasswordController.text;
    var newpassword = _NewPasswordController.text;
    var location = _LocationController.text;
    var locationLatlong = _LatLongController.text;

    if (name.isEmpty || name.length == 0) {
      showInSnackBar("Please enter the name");
      return false;
    } else if (location.isEmpty || location.length == 0) {
      showInSnackBar("Please enter the location");
      return false;
    } else if (locationLatlong.isEmpty || locationLatlong.length == 0) {
      showInSnackBar("No location info found please try again.");
      return false;
    } else {
      if (password.isNotEmpty || password.length > 0) {
        if (newpassword.isEmpty || newpassword.length == 0) {
          showInSnackBar("Please enter the new password");

          return false;
        }
      } else if (newpassword.isNotEmpty || newpassword.length > 0) {
        if (password.isEmpty || password.length == 0) {
          showInSnackBar("Please enter the old password");

          return false;
        }
      }

      return true;
    }
  }



  void showBottomSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86.0,
                    height: 86.0,
                    margin: new EdgeInsets.only(top: 38),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(37, 26, 101, 1),
                      shape: BoxShape.circle,
                    ),
                    child: new SvgPicture.asset(
                      AssetStrings.check,
                      width: 42.0,
                      height: 42.0,
                      color: Colors.white,
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 40),
                    child: new Text(
                      "Successful!",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 10),
                    child: new Text(
                      "You have updated profile successfully.",
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        color: Color.fromRGBO(114, 117, 112, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: getSetupButtonNew(
                        callbackFavourPage, "Done", 0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }

  void callbackFavourPage() async {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<ValueSetter> voidCallBackDialog(int type) async {
    print("calllll");

    hitApi(1);
  }

  Widget getAppBarNew(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(53.0),
        child: Container(
          color: Colors.white,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            padding: new EdgeInsets.only(top: 45.0, left: 17, right: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: new Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new SvgPicture.asset(
                        AssetStrings.back,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: new Text(
                    "Edit Profile",
                    style: TextThemes.darkBlackMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: callbackMain,
                  child: Container(
                    child: new Text(
                      "Save",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          color: AppColors.colorDarkCyan,
                          fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<bool> showDeleteAccount() async {
    return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete the account?'),
              content: Text('Do you want to delete your account?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('YES'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    deleteAccount();
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBarNew(context),
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  new Container(
                    width: double.infinity,
                    child: Container(
                      margin: new EdgeInsets.only(top: 14),
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              new Border.all(width: 2, color: Colors.white)),
                      child: ClipOval(
                        // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

                        child: _image != null
                            ? Image.file(
                                _image,
                                width: 89,
                                height: 89,
                                fit: BoxFit.cover,
                              )
                            : getCachedNetworkImageWithurl(
                          url: userinfo?.user?.profilePic ?? "",
                          size: 89,
                          fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _crupitinoActionSheet();
                    },
                    child: Container(
                      padding: new EdgeInsets.only(top: 14),
                      alignment: Alignment.center,
                      child: new Text(
                        "Change Profile Photo",
                        style: new TextStyle(
                            fontFamily: AssetStrings.circulerMedium,
                            color: AppColors.colorDarkCyan,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  new SizedBox(
                    height: 23.0,
                  ),
                  getTextField("Name", _NameController, _NameField, _TitleField,
                      TextInputType.text, 1),
                  new SizedBox(
                    height: 4.0,
                  ),
                  getTextField("Email", _EmailController, _TitleField,
                      _PriceField, TextInputType.emailAddress, 1),
                  new SizedBox(
                    height: 4.0,
                  ),
                  /* Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),*/
                  getTextField("Phone Number", _PhoneController, _PriceField,
                      _LocationField, TextInputType.number, 1),

                  /*   Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),*/
                  new Container(
                    color: Colors.white,
                    height: 64.0,
                    margin: new EdgeInsets.only(top: 6.0),
                    padding: new EdgeInsets.only(right: 16),
                    child: new Row(
                      children: [
                        /*   new Text(
                          ResString().get('location'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
*/
                        Expanded(
                          child: Container(
                            padding: new EdgeInsets.only(left: 16, right: 5.0),
                            alignment: Alignment.centerLeft,
                            child: getLocation(
                                _LocationController,
                                context,
                                _streamControllerShowLoader,
                                true,
                                _LatLongController,
                                iconData: AssetStrings.location,
                                colorAlert: isValid),
                          ),
                        ),
                        new SizedBox(
                          width: 15,
                        ),
                        /* new Text(
                          ">",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),*/
                      ],
                    ),
                  ),
                  new SizedBox(
                    height: 24,
                  ),
                  new Container(
                    padding: new EdgeInsets.only(left: 16, right: 5.0, top: 17),
                    color: Colors.white,
                    width: double.infinity,
                    child: new Text(
                      "Change Password",
                      style: TextThemes.darkBlackMedium,
                    ),
                  ),
                  getTextField(
                      "Old Password",
                      _OldPasswordController,
                      _OldPasswordField,
                      _NewPasswordField,
                      TextInputType.text,
                      1),
                  new SizedBox(
                    height: 6,
                  ),
                  getTextField(
                      "New Password",
                      _NewPasswordController,
                      _NewPasswordField,
                      _NewPasswordField,
                      TextInputType.text,
                      1),
                  new SizedBox(
                    height: 24.0,
                  ),
                  InkWell(
                    onTap: () {
                      showDeleteAccount();
                    },
                    child: new Container(
                      padding: new EdgeInsets.only(
                          left: 16, right: 5.0, top: 26, bottom: 26),
                      color: Colors.white,
                      width: double.infinity,
                      child: new Text(
                        "Delete Account",
                        style: TextThemes.darkRedMediumNewS,
                      ),
                    ),
                  ),
                  new SizedBox(
                    height: 50.0,
                  ),
                ],
              ),
            ),
          ),
          new Center(
            child: getFullScreenProviderLoader(
              status: provider.getLoading(),
              context: context,
            ),
          ),
          /* new Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }
}
