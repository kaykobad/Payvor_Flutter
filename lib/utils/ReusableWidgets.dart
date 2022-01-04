import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/places/suggestion.dart';
import 'package:payvor/pages/location_response/location_response.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/autocomplete_text_field.dart';

import 'AppColors.dart';
import 'AssetStrings.dart';
import 'constants.dart';

List<Predictions> list = List();

Widget getItemDivider() {
  return Padding(
      padding: const EdgeInsets.only(left: 40, top: 3, bottom: 3),
      child: Container(
        height: 1.0,
        color: AppColors.kGrey,
      ));
}

// Returns app bar
Widget getAppbar(String title) {
  return AppBar(
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
  );
}

getChatWidget({@required int count, @required Function onClick}) {
  return Stack(
    children: <Widget>[
      Center(
          child: InkWell(
        onTap: () {
          onClick();
        },
        child: Icon(Icons.chat, size: 25.0, color: Colors.black87),
      )),
      Align(
        alignment: Alignment.topRight,
        child: getNotificationCount(count),
      )
    ],
  );
}

getNotificationCount(int count) {
  return (count > 0)
      ? ClipOval(
          child: Container(
            color: Colors.red,
            height: 22.0, // height of the button
            width: 22.0, // width of the button
            child: Center(
              child: Text(
                (count < 10) ? "$count" : "9+",
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        )
      : Container();
}

Widget appLogo() {
  return SvgPicture.asset(
    AssetStrings.logo,
    height: 100,
    width: 100,
  );
}

Widget _loader(StreamController<bool> _streamControllerShowLoader) {
  return StreamBuilder<bool>(
      stream: _streamControllerShowLoader.stream,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool status = snapshot.data;
        return status
            ? Center(child: CupertinoActivityIndicator(radius: 10))
            : Container();
      });
}

Widget getSetupButtonNewBorder(
    VoidCallback callback, String text, double margin,
    {Color newColor}) {
  return Container(
    height: 54.0,
    margin: EdgeInsets.only(left: margin, right: margin),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: Material(
      borderRadius: BorderRadius.circular(6.0),
      child: Ink(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: Colors.transparent,
            border: Border.all(color: AppColors.colorDarkCyan, width: 1.5)),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          splashColor:
              (newColor == null) ? Colors.transparent : Colors.transparent,
          onTap: () {
            callback();
          },
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                fontSize: 16,
                color: AppColors.colorDarkCyan,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getLocationNew(
    TextEditingController controller,
    BuildContext context,
    StreamController<bool> _streamControllerShowLoader,
    bool isBackground,
    TextEditingController controllers, {
    String iconData,
    bool colorAlert,
    Function onTap,
    double iconPadding = 0,
    }) {
  return Container(
    alignment: Alignment.center,
    margin: !isBackground
        ? EdgeInsets.only(left: 20, right: 20)
        : EdgeInsets.only(left: 0, right: 0),
    child: Stack(
      children: <Widget>[
        AutoCompleteTextView(
          isLocation: true,
          defaultPadding: 10,
          svgicon: iconData,
          hintText: "Location",
          hintTheme: colorAlert,
          backgroundShow: isBackground,
          suggestionsApiFetchDelay: 100,
          focusGained: () {},
          onTapCallback: (String text) async {
            var id = "";

            for (var data in list) {
              if (text == data.description) {
                id = data.place_id;
                print("select ${data.description}");
                print("selectid ${data.place_id}");
                break;
              }
            }
            Dio dio = Dio();

            if (id.length > 0) {
              var response = await dio
                  .get(
                      "https://maps.googleapis.com/maps/api/geocode/json?place_id=$id&key=AIzaSyDYkqk9oyoiRqLpupcXOuwvokvonNgdA1M")
                  .timeout(timeoutDuration);

              LatLongResponse locationList =
                  LatLongResponse.fromJson(response.data);

              if (locationList.results != null &&
                  locationList.results.length > 0) {
                var data = locationList.results[0];

                print("data ${data.geometry?.location?.lat}");

                controllers.text = data?.geometry?.location?.lat?.toString() +
                    "," +
                    data?.geometry?.location?.lng?.toString();

                if (onTap != null) {
                  onTap();
                  closeKeyboard();
                }
              }
            }

            // addData(text);
            print(text);
          },
          focusLost: () {
            print("focust lost");
          },
          onValueChanged: (String text) {
            print("called $text");
          },
          controller: controller,
          suggestionStyle: Theme.of(context).textTheme.bodyText1,
          getSuggestionsMethod: getLocationSuggestionsList,
          tfTextAlign: TextAlign.left,
          tfTextDecoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Location",
          ),
        ),
        Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: _loader(_streamControllerShowLoader))
      ],
    ),
  );
}

Widget getSetupButtonNew(VoidCallback callback, String text, double margin,
    {Color newColor, String imagePath}) {
  return Container(
    height: 54.0,
    margin: EdgeInsets.only(left: margin, right: margin),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
    child: Material(
      borderRadius: BorderRadius.circular(4.0),
      child: Ink(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: (newColor == null)
                ? AppColors.kPrimaryBlue
                : AppColors.colorDarkCyan),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          splashColor: (newColor == null)
              ? AppColors.kPrimaryBlue
              : AppColors.colorDarkCyan,
          onTap: () {
            callback();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (imagePath!=null) ? Image.asset(imagePath,width: 18,height: 18) : Container(),
              (imagePath!=null) ? SizedBox(width: 5) : Container(),
              Text(
                text,
                style: TextStyle(
                  fontFamily: AssetStrings.circulerMedium,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget getSetupButtonNewCustom(
    VoidCallback callback, String text, double margin,
    {Color newColor, String imagePath, Color textColor}) {
  return Container(
    height: 54.0,
    margin: EdgeInsets.only(left: margin, right: margin),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: Material(
      borderRadius: BorderRadius.circular(6.0),
      child: Ink(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: (newColor != null) ? newColor : AppColors.colorDarkCyan),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          splashColor: (newColor != null) ? newColor : AppColors.colorDarkCyan,
          onTap: () {
            callback();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (imagePath != null)
                  ? Image.asset(
                      imagePath,
                      width: 20,
                      height: 20,
                    )
                  : Container(),
              (imagePath != null)
                  ? SizedBox(
                width: 10,
                    )
                  : Container(),
              Text(
                text,
                style: TextStyle(
                  fontFamily: AssetStrings.circulerNormal,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget getSetupButtonColor(VoidCallback callback, String text, double margin,
    {Color newColor=AppColors.kPrimaryBlue}) {
  return Container(
    height: 54.0,
    margin: EdgeInsets.only(left: margin, right: margin),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
    child: Material(
      borderRadius: BorderRadius.circular(4.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: newColor,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          splashColor: newColor,
          onTap: () {
            callback();
          },
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getSetupButtonNewRow(VoidCallback callback, String text, double margin,
    {Color newColor}) {
  return Container(
    height: 48.0,
    margin: EdgeInsets.only(left: margin, right: margin),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Material(
      borderRadius: BorderRadius.circular(8.0),
      child: Ink(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: (newColor == null)
                ? AppColors.kPrimaryBlue
                : AppColors.colorDarkCyan),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          splashColor: (newColor == null)
              ? AppColors.kPrimaryBlue
              : AppColors.colorDarkCyan,
          onTap: () {
            callback();
          },
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AssetStrings.imageMessage,
                  width: 16,
                  height: 16,
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: AssetStrings.circulerMedium,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getSetupButtonBorderNew(VoidCallback callback, String text, double margin, {Color newColor=AppColors.kPrimaryBlue, Color textColor=Colors.white, Color border=Colors.black}) {
  return Container(
    height: 54.0,
    margin: EdgeInsets.only(left: margin, right: margin),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4.0),
    ),
    child: Material(
      borderRadius: BorderRadius.circular(4.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: border),
          color: newColor,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          splashColor: newColor,
          onTap: () {
            callback();
          },
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AssetStrings.circulerMedium,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getAppBarNew(BuildContext context) {
  return PreferredSize(
      preferredSize: Size.fromHeight(80.0),
      child: Material(
        color: Colors.white,
        child: Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(left: 17.0, top: 47),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SvgPicture.asset(
                AssetStrings.back,
                width: 21.0,
                height: 21.0,
              ),
            ),
          ),
        ),
      ));
}


Widget getSetupDecoratorButtonNew(
    VoidCallback callback, String text, double margin,
    {Color newColor, Color textColor=AppColors.kPrimaryBlue}) {
  return Container(
    height: 54.0,
    margin: EdgeInsets.only(left: margin, right: margin),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
    child: Material(
      borderRadius: BorderRadius.circular(4.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(width: 1, color: AppColors.kPrimaryBlue),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: () {
            callback();
          },
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AssetStrings.circulerNormal,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getLocation(
    TextEditingController controller,
    BuildContext context,
    StreamController<bool> _streamControllerShowLoader,
    bool isBackground,
    TextEditingController controllers,
    {String iconData,
    bool colorAlert,
    double iconPadding = 0}) {
  return Container(
    margin: !isBackground
        ? EdgeInsets.only(left: 20, right: 20)
        : EdgeInsets.only(left: 0, right: 0),
    child: Stack(
      children: <Widget>[
        AutoCompleteTextView(
          isLocation: true,
          defaultPadding: iconPadding,
          svgicon: iconData,
          hintText: "Location",
          hintTheme: colorAlert,

          backgroundShow: isBackground,
          suggestionsApiFetchDelay: 100,
          focusGained: () {},
          onTapCallback: (String text) async {
            var id = "";

            for (var data in list) {
              if (text == data.description) {
                id = data.place_id;
                //print("select ${data.description}");
                //print("selectid ${data.place_id}");
                break;
              }
            }
            Dio dio = Dio();


            if (id.length > 0) {
              //print("latlong https://maps.googleapis.com/maps/api/geocode/json?place_id=$id&key=${Constants.GOOGLE_PLACES_API}");
              var response = await dio.get(
                  "https://maps.googleapis.com/maps/api/geocode/json?place_id=$id&key=${Constants.GOOGLE_PLACES_API}")
                  .timeout(timeoutDuration);

              LatLongResponse locationList = LatLongResponse.fromJson(
                  response.data);

              if (locationList.results != null &&
                  locationList.results.length > 0) {
                var data = locationList.results[0];

                //print("data ${data.geometry?.location?.lat}");

                controllers.text = data?.geometry?.location?.lat?.toString() +
                    "," +
                    data?.geometry?.location?.lng?.toString();
              }
            }

            closeKeyboard();
            FocusScope.of(context).unfocus();
            // addData(text);
            //print(text);
          },
          focusLost: () {
            //print("focust lost");
          },
          onValueChanged: (String text) {
            //print("called $text");
          },
          controller: controller,
          suggestionStyle: Theme.of(context).textTheme.bodyText1,
          getSuggestionsMethod: getLocationSuggestionsList,
          tfTextAlign: TextAlign.left,
          tfTextDecoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Location",
          ),
        ),
        Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: _loader(_streamControllerShowLoader))
      ],
    ),
  );
}

Future<List<String>> getLocationSuggestionsList(String locationText) async {
  Dio dio = Dio();
  CancelToken _requestToken;

  //if search text length is greater than 0 than return blank array
  if (locationText.length == 0) return List();

  List<String> suggestionList = List();
  list.clear();

  try {
    //print("url  https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationText&key=${Constants.GOOGLE_PLACES_API}");
    if (_requestToken != null)
      _requestToken.cancel(); //cancel the previous on going request
    _requestToken = CancelToken(); //generate token for request
    //call the apoi
    var response = await dio.get(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationText&key=${Constants.GOOGLE_PLACES_API}",
        cancelToken: _requestToken)
        .timeout(timeoutDuration);
    //get the suggestion list
    var locationList = SuggestedLocation.fromJson(response.data);
    //print("ress $response");

    //get description list and add to string list
    for (var data in locationList.predictions) {
      list.addAll(locationList.predictions);
      suggestionList.add(data.description);
    }
  } on DioError catch (e) {} catch (e) {}

  return suggestionList;
}

//bool isCurrentUser(String userId) {
//  var currentUserId = MemoryManagement.getuserId();
//  return (currentUserId == userId);
//}

//Widget getBackButton(String userId, BuildContext context, bool showit) {
//  return (!isCurrentUser(userId) && showit)
//      ? Positioned(
//          top: 6,
//          left: 15,
//          child: InkWell(
//            onTap: () {
//              Navigator.pop(context);
//            },
//            child: Icon(
//              Icons.arrow_back,
//              color: Colors.black,
//            ),
//          ),
//        )
//      : Container();
//}

//for youtube auth in native
TargetPlatform platform;
const platformType = const MethodChannel('flutter.native/helper');
