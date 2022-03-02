import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/networkmodel/APIs.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class AddProfilePicture extends StatefulWidget {
  final String name;
  const AddProfilePicture({Key key, this.name}) : super(key: key);

  @override
  _AddProfilePictureState createState() => _AddProfilePictureState();
}

class _AddProfilePictureState extends State<AddProfilePicture> {
  AuthProvider provider;
  FirebaseProvider firebaseProvider;
  bool _isButtonActive = false;
  File _image;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    return Material(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                foregroundColor: Colors.black,
              ),
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: double.maxFinite),
                    Text(
                      "Add a Profile Photo",
                      style: TextStyle(
                        fontFamily: AssetStrings.circulerBoldStyle,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "You need to add a profile photo to continue",
                      style: TextThemes.grayNormal,
                    ),
                    Spacer(flex: 1),
                    _profilePictureWidget(),
                    SizedBox(height: 25),
                    Center(
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Spacer(flex: 2),
                    Container(
                      child: getSetupButtonColor(
                        _image == null ? (){} : hitApi,
                        "Let's Go",
                        0,
                        newColor: _image == null ? AppColors.grayDark : AppColors.kPrimaryBlue,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Center(
              child: getFullScreenProviderLoader(
                status: provider.getLoading(),
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  _cupertinoActionSheet() {
    return containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
          actions: <Widget>[
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
          ),
      ),
    );
  }

  Widget _profilePictureWidget() {
    return Center(
      child: InkWell(
        onTap: _cupertinoActionSheet,
        splashFactory: NoSplash.splashFactory,
        child: _image == null
            ? Container(
                height: 103,
                width: 103,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEBEBEB),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Color(0xFF676363),
                  ),
                ),
              )
            : ClipOval(
                child: Image.file(
                  _image,
                  width: 103,
                  height: 103,
                  fit: BoxFit.cover,
                ),
        ),
      )
    );
  }

  Future _getCameraImage() async {
    var imageFileSelect = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: Constants.maxWidth,
        maxHeight: Constants.maxHeight);

    var imageFile = await ImageCropper().cropImage(
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

  Future _getGalleryImage() async {
    var imageFileSelect = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: Constants.maxWidth,
        maxHeight: Constants.maxHeight);
    var imageFile = await ImageCropper().cropImage(
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

  hitApi() async {
    provider.setLoading();
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

    Map<String, String> headers = {
      "Content-Type": "multipart/form-data",
      "Accept": "application/json"
    };

    if (MemoryManagement.getAccessToken() != null) {
      headers["Authorization"] = "Bearer " + MemoryManagement.getAccessToken();
    }

    http.MultipartRequest request;
    request = new http.MultipartRequest("POST", Uri.parse(APIs.update_profile));
    request.headers.addAll(headers);
    request.fields['name'] = widget.name;

    if (_image != null) {
      final fileName = _image.path;
      var bytes = await _image.readAsBytes();
      request.files.add(new http.MultipartFile.fromBytes(
        "profile_pic",
        bytes,
        filename: fileName,
      ));
    }

    print(request.fields);

    http.StreamedResponse response = await request.send();
    provider.hideLoader();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print("respStr: $respStr");
      Map data = jsonDecode(respStr); // Parse data from JSON string

      LoginSignupResponse dataResponse = new LoginSignupResponse.fromJson(data);

      MemoryManagement.setUserInfo(userInfo: json.encode(dataResponse));
      firebaseProvider.updateUserProfilePic(profilePic: dataResponse.user.profilePic);
      setState(() {});
      Navigator.pushAndRemoveUntil(
        context,
        new CupertinoPageRoute(builder: (BuildContext context) {
          return DashBoardScreen();
        }),
        (route) => false,
      );
    } else {
      var data = await response.stream?.bytesToString();
      Map dataMap = jsonDecode(data);
      var stringdata = dataMap["data"];
      ScaffoldMessenger.of(context).showSnackBar(stringdata);
    }
  }
}
