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
import 'package:payvor/model/create_payvor/payvorcreate.dart';
import 'package:payvor/model/favour_details_response/favour_details_response.dart';
import 'package:payvor/networkmodel/APIs.dart';
import 'package:payvor/pages/preview_post/preview_post.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class PostFavour extends StatefulWidget {
  final FavourDetailsResponse favourDetailsResponse;
   bool isEdit;
   ValueSetter<int> voidcallback;

  PostFavour({this.favourDetailsResponse, this.isEdit=false, this.voidcallback});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PostFavour>
    with AutomaticKeepAliveClientMixin<PostFavour> {
  var screenSize;

   ScrollController scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _TitleController = new TextEditingController();
  TextEditingController _PriceController = new TextEditingController();
  TextEditingController _DescriptionController = new TextEditingController();
  TextEditingController _LocationController = new TextEditingController();
  TextEditingController _LatLongController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _TitleField = new FocusNode();
  FocusNode _PriceField = new FocusNode();
  FocusNode _DescriptionField = new FocusNode();
  FocusNode _LocationField = new FocusNode();

  File _image; //to store profile image
  String profile;
  bool isValid = false;

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
    if (widget.favourDetailsResponse != null) {
      _TitleController.text = widget?.favourDetailsResponse?.data?.title ?? "";
      _PriceController.text = widget?.favourDetailsResponse?.data?.price ?? "";
      _DescriptionController.text =
          widget?.favourDetailsResponse?.data?.description ?? "";
      _LocationController.text =
          widget?.favourDetailsResponse?.data?.location ?? "";
      profile = widget?.favourDetailsResponse?.data?.image ?? "";


      _LatLongController.text = widget?.favourDetailsResponse?.data?.lat + "," +
          widget?.favourDetailsResponse?.data?.long;

      /*  print("lat ${widget?.favourDetailsResponse?.data?.lat}");
      print("long ${widget?.favourDetailsResponse?.data?.long}");
      print("latlong ${ _LatLongController.text}");*/
    }

    _setScrollListener();

    super.initState();
  }

  @override
  void dispose() {
    _streamControllerShowLoader.close(); //close the stream on dispose

    super.dispose();
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
    }
    else {
      showInSnackBar("Please enter valid location");
      return;
    }
    Map<String, String> headers = {
//header
      "Content-Type": "multipart/form-data",
      "Accept": "application/json"
    };

    if (MemoryManagement.getAccessToken() != null) {
      headers["Authorization"] =
          "Bearer " + MemoryManagement.getAccessToken();
    }
    http.MultipartRequest request;

    //changed


    if (widget.isEdit != null && widget.isEdit) {
      request = new http.MultipartRequest("POST", Uri.parse(APIs.editFavour));

      request.fields['id'] = widget.favourDetailsResponse?.data?.id?.toString();
      print("edit true");
    }
    else {
      request = new http.MultipartRequest("POST", Uri.parse(APIs.createPayvor));
      print("edit false");
    }

    request.headers.addAll(headers);

    request.fields['title'] = _TitleController.text;
    request.fields['location'] = _LocationController.text;
    request.fields['description'] = _DescriptionController.text;
    request.fields['price'] = _PriceController.text;
    request.fields['lat'] = lat;
    request.fields['long'] = long;

    if (_image != null) {
      final fileName = _image.path;
      print("imsgrs $fileName");

      var bytes = await _image.readAsBytes();

      request.files.add(new http.MultipartFile.fromBytes(
        "image",
        bytes,
        filename: fileName,
      ));
    }

/*
    PayvorCreateRequest loginRequest = new PayvorCreateRequest(
        title: _TitleController.text,
        location: _LocationController.text,
        description: _DescriptionController.text,
        price: _PriceController.text,
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
      String responseData = data['status']['message'];

      _TitleController.text = "";
      _PriceController.text = "";
      _DescriptionController.text = "";
      _LocationController.text = "";
      _LatLongController.text = "";
      _image = null;
      isValid = false;
      profile = null;

      showBottomSheet();
      setState(() {});
    }
    else {
      showInSnackBar("Something went wrong!!Please try again");
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

            onSubmitted: (String value) {
              if (focusNodeCurrent == _DescriptionField) {
                _DescriptionField.unfocus();
              } else {
                FocusScope.of(context).autofocus(focusNodeNext);
              }
            },
            decoration: new InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: labelText,

              contentPadding: new EdgeInsets.only(right: 50.0),
//              prefix: new Text(
//                  focusNodeCurrent == _PriceField&&_PriceField.hasFocus
//                      ? "€ "
//                      : ""),
              hintStyle: controller.text.length == 0 && isValid ? TextThemes
                  .readAlert : TextThemes.greyTextFieldHintNormal,
            ),
          ),

          controller.text.length == 0 && isValid ? new Positioned(
            right: 0.0,
            child: new Padding(padding: lines > 1
                ? new EdgeInsets.only(bottom: 4)
                : new EdgeInsets.only(top: 13),
              child: new SvgPicture.asset(
                AssetStrings.notFilled,
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  void callback() {
    if (getResult()) {
      hitApi(1);
    }
    else {
      setState(() {

      });
    }
  }

  void callbackMain() {
    if (getResult()) {
      hitApi(2);
    }
    else {
      setState(() {

      });
    }
  }


  bool getResult() {
    var title = _TitleController.text;
    var price = _PriceController.text;
    var desc = _DescriptionController.text;
    var location = _LocationController.text;
    isValid = true;
    if (title.isEmpty || title
        .trim()
        .length == 0) {
      showInSnackBar("Please enter the title");
      return false;
    } else if (price.isEmpty || price.length == 0) {
      showInSnackBar("Please enyter the price");
      return false;
    }
    else if (desc.isEmpty || desc.length == 0) {
      showInSnackBar("Please enter the description");
      return false;
    }
    else if (location.isEmpty || location.length == 0) {
      showInSnackBar("Please enter the location");
      return false;
    }
    else {
      isValid = false;
      return true;
    }
  }


  void callbackPreview() {
    if (getResult()) {
      var lat = "0.0";
      var long = "0.0";

      if (_LatLongController.text.length > 0) {
        var data = _LatLongController.text.trim().toString().split(",");

        try {
          lat = data[0];
          long = data[1];
        } catch (e) {}
      }
      else {
        showInSnackBar("Please enter valid location");
        return;
      }


      PayvorCreateRequest loginRequest = new PayvorCreateRequest(
          title: _TitleController.text,
          location: _LocationController.text,
          description: _DescriptionController.text,
          price: _PriceController.text,
          lat: lat,
          long: long);

      Navigator.push(
        context,
        new CupertinoPageRoute(builder: (BuildContext context) {
          return Material(child: new PreviewPost(
            request: loginRequest,
            type: 1,
            file: _image,
            voidcallback: voidCallBackDialog,));
        }),
      );
    }
    else {
      setState(() {

      });
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
                        child: new Text("Successful!", style: new TextStyle(
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 20,
                            color: Colors.black),),
                      ),

                      new Container(
                        margin: new EdgeInsets.only(top: 10),
                        child: new Text(
                          widget?.isEdit ?? false
                          ? "You have updated favor successfully."
                          : "You have created a favor successfully.",
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        color: Color.fromRGBO(114, 117, 112, 1),
                      ),
                    ),


                      ),

                      Container(
                        margin: new EdgeInsets.only(
                            top: 60, left: 16, right: 16),
                        child: getSetupButtonNew(
                            callbackFavourPage,
                        widget?.isEdit ?? false
                            ? "Go to Home Page"
                            : "Go to Favor Page",
                        0,
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
    if ((widget?.isEdit??false) && widget?.voidcallback != null) {
      widget?.voidcallback(1);
      Navigator.pop(context);
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<ValueSetter> voidCallBackDialog(int type) async {
    print("calllll");

    hitApi(1);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery
        .of(context)
        .size;
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: AppColors.whiteGray,
            height: screenSize.height,
            child: SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    color: Colors.white,
                    height: 36.0,
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        new EdgeInsets.only(top: 14.0, left: 17, right: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                AssetStrings.cross,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: new Text(
                            widget.isEdit != null && widget.isEdit
                                ? "Edit Favor"
                                : ResString().get('post_favour'),
                            style: TextThemes.darkBlackMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          child: new Text(
                            "",
                            style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                color: AppColors.redLight,
                                fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    color: Colors.white,
                    height: 16.0,
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  profile != null && profile.isNotEmpty ? Stack(
                    children: [
                      new Container(
                          width: double.infinity,
                          padding: new EdgeInsets.only(left: 16, right: 16),
                          height: 147.0,
                          child: ClipRect(
                            child: getCachedNetworkImageWithurl(
                                url: profile,
                                fit: BoxFit.cover,
                                size: 147
                            ),
                          )),

                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: InkWell(
                              onTap: () {
                                profile = null;
                                setState(() {

                                });
                              },
                              child: new Container(
                                  width: 46,
                                  height: 46,

                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
                                  ),
                                  child: new Icon(
                                      Icons.delete, color: Colors.red)
                              )
                          ),
                        ),
                      ),
                    ],
                  ) : _image == null ? new Container(
                    color: Colors.white,
                    width: double.infinity,
                    margin: new EdgeInsets.only(top: 9.0),
                    padding: new EdgeInsets.only(
                        left: 16, right: 16, top: 36, bottom: 33),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            _crupitinoActionSheet();
                          },
                          child: new Image.asset(
                            AssetStrings.camera,
                            width: 34.0,
                            height: 30.0,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _crupitinoActionSheet();
                          },
                          child: Container(
                            padding: new EdgeInsets.only(top: 10),
                            child: new Text(
                              ResString().get('upload_photo'),
                              style: new TextStyle(
                                  fontFamily: AssetStrings.circulerMedium,
                                  color: AppColors.bluePrimary,
                                  fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        new Text(
                          ResString().get('photo_not_mandetry'),
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ) : Stack(
                    children: [
                      new Container(
                          width: double.infinity,
                          padding: new EdgeInsets.only(left: 16, right: 16),
                          height: 147.0,
                          child: ClipRect(
                            child: new Image.file(
                              _image,
                              fit: BoxFit.cover,
                            ),
                          )),

                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: InkWell(
                              onTap: () {
                                _image = null;
                                setState(() {

                                });
                              },
                              child: new Container(
                                  width: 46,
                                  height: 46,

                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
                                  ),
                                  child: new Icon(
                                      Icons.delete, color: Colors.red)
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                  new SizedBox(
                    height: 8.0,
                  ),
                  getTextField(ResString().get('title'), _TitleController,
                      _TitleField, _PriceField, TextInputType.emailAddress, 1),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  getTextField(
                      ResString().get('price'),
                      _PriceController,
                      _PriceField,
                      _DescriptionField,
                      TextInputType.number,
                      1),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  getTextField(
                      ResString().get('description'),
                      _DescriptionController,
                      _DescriptionField,
                      _DescriptionField,
                      TextInputType.text,
                      8),
                  new SizedBox(
                    height: 9.0,
                  ),
                  new Container(
                    color: Colors.white,
                    height: 64.0,
                    margin: new EdgeInsets.only(top: 9.0),
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
                            child: getLocation(_LocationController, context,
                                _streamControllerShowLoader,
                                true,
                                _LatLongController,
                                iconData: AssetStrings.location,
                                colorAlert: isValid
                            ),
                          ),
                        ),
                        new SizedBox(
                          width: 15,
                        ),
                        isValid ? new SvgPicture.asset(
                          AssetStrings.notFilled,
                        ) : Container(),
                        isValid ? new SizedBox(
                          width: 5,
                        ) : Container(),
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
                    height: 150.0,
                  ),
                ],
              ),
            ),
          ),
          Offstage(
            offstage: true,
            child: new Center(
              child: new Text(
                "No Favors Found",
                style: new TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Material(
              elevation: 18.0,
              child: Container(
                  color: Colors.white,
                  padding: new EdgeInsets.only(
                      top: 9, bottom: 28, left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: getSetupButtonBorderNew(
                            callbackPreview, ResString().get('preview_favor'),
                            0,
                            border: Color.fromRGBO(103, 99, 99, 0.19),
                            newColor: Color.fromRGBO(248, 248, 250, 1.0),
                            textColor: Colors.black),
                      ),
                      new SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: getSetupButtonNew(
                            widget.isEdit != null && widget.isEdit
                                ? callbackMain
                                : callback,
                            widget.isEdit != null && widget.isEdit
                                ? "Update Favor"
                                : ResString().get('post_favor'), 0,
                            newColor: AppColors.colorDarkCyan),
                      ),
                    ],
                  )),
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
