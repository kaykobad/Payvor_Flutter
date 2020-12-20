import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/create_payvor/create_payvor_response.dart';
import 'package:payvor/model/create_payvor/payvorcreate.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class PostFavour extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<PostFavour>
    with AutomaticKeepAliveClientMixin<PostFavour> {
  var screenSize;

  final StreamController<bool> _loaderStreamController =
      new StreamController<bool>();
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
    _setScrollListener();

    super.initState();
  }

  @override
  void dispose() {
    _streamControllerShowLoader.close(); //close the stream on dispose

    super.dispose();
  }

  hitApi() async {
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
      } catch (e) {}
    }

    PayvorCreateRequest loginRequest = new PayvorCreateRequest(
        title: _TitleController.text,
        location: _LocationController.text,
        description: _DescriptionController.text,
        price: _PriceController.text,
        lat: lat,
        long: long);
    var response = await provider.createPayvor(loginRequest, context);

    if (response is FavourCreateResponse) {
      provider.hideLoader();

      print(response);
      try {
        showInSnackBar(response.success);
        /*   Navigator.pop(context);
        Navigator.pop(context);*/
      } catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
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
      child: new TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
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
          prefixText: focusNodeCurrent == _PriceField ? "€ " : "",
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  void callback() {
    hitApi();
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
                    padding: new EdgeInsets.only(top: 36.0),
                    margin: new EdgeInsets.only(left: 17.0, right: 17),
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
                            ResString().get('post_favour'),
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
                  _image == null ? new Container(
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
                              fit: BoxFit.fill,
                            ),
                          )),

                      Container(
                        alignment: Alignment.center,
                        height: 147,


                        child: Positioned(
                          top: 0.0,
                          bottom: 0.0,
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
                            ),
                          ),
                        ),

                        new Text(
                          ">",
                          style: new TextStyle(
                              fontFamily: AssetStrings.circulerNormal,
                              color: AppColors.lightGrey,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
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
                            callback, ResString().get('preview_favor'), 0,
                            border: Color.fromRGBO(103, 99, 99, 0.19),
                            newColor: Color.fromRGBO(248, 248, 250, 1.0),
                            textColor: Colors.black),
                      ),
                      new SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: getSetupButtonNew(
                            callback, ResString().get('apply_filters'), 0,
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
