import 'dart:async';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/update_profile/update_profile_request.dart';
import 'package:payvor/model/update_profile/update_profile_response.dart';
import 'package:payvor/pages/otp/enter_otp.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class PhoneNumberAdd extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<PhoneNumberAdd> {
  TextEditingController _LocationController = new TextEditingController();
  TextEditingController _LatLongController = new TextEditingController();
  TextEditingController _PhoneController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();

  final StreamController<bool> _streamControllerShowLoader =
      StreamController<bool>();

  FocusNode _LocationField = new FocusNode();
  FocusNode _PhoneField = new FocusNode();
  Country _selected;
  AuthProvider provider;

  Widget space() {
    return new SizedBox(
      height: 30.0,
    );
  }

  Widget getView() {
    return new Container(
      height: 1.0,
      color: Colors.grey.withOpacity(0.7),
    );
  }


  @override
  void dispose() {
    _streamControllerShowLoader.close(); //close the stream on dispose

    super.dispose();
  }

  Widget _buildDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );

  void _openCountryPickerDialog() => showDialog(
    context: context,
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.pink),
      child: new CountryPickerDialog(
        titlePadding: EdgeInsets.all(8.0),
        searchCursorColor: Colors.pinkAccent,
        searchInputDecoration: InputDecoration(hintText: "Search" + '...'),
        isSearchable: true,
        title: new Text("Select Code"),
        onValuePicked: (Country country) {
          setState(() {
            _selected = country;
          });
        },
        itemBuilder: _buildDialogItem,
      ),
    ),
  );

  /*Widget getTextFieldPhone(String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      padding: new EdgeInsets.only(top: 2.0, bottom: 2.0, right: 10.0),
      decoration: new BoxDecoration(
          color: Colors.transparent,
          border: new Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: new BorderRadius.circular(8.0)),
      child: new TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        decoration: new InputDecoration(
          border: InputBorder.none,
          contentPadding: new EdgeInsets.only(top: 15.0, left: 2.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 5.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new Image.asset(
                  svgPicture,
                  width: 20.0,
                  height: 20.0,
                ),
                new InkWell(
                  onTap: () {
                    _openCountryPickerDialog();
                  },
                  child: Container(
                    padding: new EdgeInsets.only(
                      left: 16,
                    ),
                    child: Text("+${_selected.phoneCode}",
                        style: TextThemes.blackTextFieldNormal),
                  ),
                ),
              ],
            ),
          ),
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }*/

  Widget getTextFieldPhone(
    String labelText,
    TextEditingController controller,
    FocusNode focusNodeCurrent,
    FocusNode focusNodeNext,
    TextInputType textInputType,
    String svgPicture,
  ) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      height: Constants.textFieldHeight,
      child: new TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        decoration: new InputDecoration(
          enabledBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
              borderRadius: new BorderRadius.circular(8)),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: AppColors.colorCyanPrimary,
              ),
              borderRadius: new BorderRadius.circular(8)),
          contentPadding: new EdgeInsets.only(top: 10.0, left: 2.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 5.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new Image.asset(
                  svgPicture,
                  width: 20.0,
                  height: 20.0,
                ),
                new InkWell(
                  onTap: () {
                    _openCountryPickerDialog();
                  },
                  child: Container(
                    padding: new EdgeInsets.only(
                      left: 16,
                        bottom: 2),
                    child: Text("+${_selected.phoneCode}",
                        style: TextThemes.blackTextFieldNormal),
                  ),
                ),
              ],
            ),
          ),
          suffixIcon: new Container(
            width: 1,
          ),
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  @override
  void initState() {
    _selected = CountryPickerUtils.getCountryByPhoneCode('1');

    super.initState();
  }

  /*Widget getTextField(String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      padding: new EdgeInsets.only(top: 2.0, bottom: 2.0, right: 10.0),
      decoration: new BoxDecoration(
          color: Colors.transparent,
          border: new Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: new BorderRadius.circular(8.0)),
      child: new TextField(
        controller: controller,
        style: TextThemes.blackTextFieldNormal,
        keyboardType: textInputType,
        decoration: new InputDecoration(
          border: InputBorder.none,
          contentPadding: new EdgeInsets.only(top: 15.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14.0),
            child: new Image.asset(
              svgPicture,
              width: 20.0,
              height: 20.0,
            ),
          ),
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }*/


  Widget getTextField(String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      height: Constants.textFieldHeight,
      child: new TextField(
        controller: controller,
        style: TextThemes.blackTextFieldNormal,
        keyboardType: textInputType,
        decoration: new InputDecoration(
          enabledBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
              borderRadius: new BorderRadius.circular(8)),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: AppColors.colorCyanPrimary,

              ),
              borderRadius: new BorderRadius.circular(8)


          ),
          contentPadding: new EdgeInsets.only(top: 10.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14.0),
            child: new Image.asset(
              svgPicture,
              width: 20.0,
              height: 20.0,
            ),
          ),
          suffixIcon: new Container(width: 1,),
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
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
      }
      catch (e) {

      }
    }


    UpdateProfileRequest loginRequest = new UpdateProfileRequest(
        phone: _PhoneController.text,
        location: _LocationController.text,
        country_code: _selected.phoneCode,
        lat: lat,
        long: long);
    var response = await provider.updateProfile(loginRequest, context);

    if (response is UpdateProfileResponse) {
      provider.hideLoader();

      print(response);
      try {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new OtoVerification(
              phoneNumber: _PhoneController.text,
              type: 0,
              countryCode: _selected.phoneCode,
            );
          }),
        );
        /*  showInSnackBar(response.data);
        Navigator.pop(context);
        Navigator.pop(context);*/
      } catch (ex) {

      }
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery
        .of(context)
        .size;
    provider = Provider.of<AuthProvider>(context);
    return Material(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Scaffold(
              appBar: getAppBarNew(context),
              key: _scaffoldKeys,
              backgroundColor: Colors.white,
              body: new SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  width: screensize.width,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new SizedBox(
                        height: Constants.backIconsSpace,
                      ),
                      Container(
                          margin: new EdgeInsets.only(left: 20.0),
                          child: new Text(
                            ResString().get('phone_number'),
                            style: TextThemes.extraBold,
                          )),
                      Container(
                        margin: new EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 6),
                        child: new Text(
                          ResString().get('enter_ur_location'),
                          style: TextThemes.grayNormal,
                        ),
                      ),
                      space(),
                      new SizedBox(
                        height: 15.0,
                      ),
                      /* getTextField(
                        "Location",
                        _LocationController,
                        _LocationField,
                        _PhoneField,
                        TextInputType.text,
                        AssetStrings.location,
                      ),*/
                      getLocation(_LocationController, context,
                        _streamControllerShowLoader,
                        _LatLongController,
                        iconData: AssetStrings.location,
                      ),

                      new SizedBox(
                        height: 18.0,
                      ),
                      getTextFieldPhone(
                        ResString().get('phone_number'),
                        _PhoneController,
                        _PhoneField,
                        _PhoneField,
                        TextInputType.phone,
                        AssetStrings.phone,
                      ),
                      new SizedBox(
                        height: 25.0,
                      ),
                      Container(
                          child:
                          getSetupButtonNew(
                              callback, ResString().get('verify_number'), 20)),
                      new SizedBox(
                        height: 25.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            new Center(
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

  void callback() {
    var location = _LocationController.text;
    var phonenumber = _PhoneController.text;

    if (location.isEmpty || location
        .trim()
        .length == 0) {
      showInSnackBar(ResString().get('enter_location'));
      return;
    }
    else if (phonenumber.isEmpty || phonenumber.length == 0) {
      showInSnackBar(ResString().get('enter_phone_number'));
      return;
    }

    hitApi();
  }
}
