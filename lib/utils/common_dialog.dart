import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dialogs {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!

  // Todo: Exit app Pop up
  /// SHOW EXIT APP POP UP
  static void warningDialog(BuildContext context, String message,
      String btn1Txt, String btn2Txt, ValueSetter<int> callback) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert"),
          content: new Text("$message"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(btn1Txt),
              onPressed: () {
                callback(1); //delete confirmation
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(btn2Txt),
              onPressed: () {
                callback(2); //delete confirmation
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Todo: Exit app Pop up
  /// SHOW EXIT APP POP UP
  static void AppAlertDialog(BuildContext context, String message,
      String yesBtn, String noBtn, VoidCallback callback) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert"),
          content: new Text("$message"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("$yesBtn"),
              onPressed: () {
                Navigator.of(context).pop();
                callback(); //delete confirmation
              },
            ),
            new FlatButton(
              child: new Text("$noBtn"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Todo: Exit app Pop up
  /// SHOW EXIT APP POP UP
  static void AppAlertDialogSuccess(BuildContext context, String message,
      String yesBtn, VoidCallback callback) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert"),
          content: new Text("$message"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("$yesBtn"),
              onPressed: () {
                Navigator.of(context).pop();
                if (callback != null) callback(); //delete confirmation
              },
            ),
          ],
        );
      },
    );
  }

  // Show alert dialog
  static showAlert(
      {@required BuildContext context,
      String titleText,
      Widget title,
      String message,
      Widget content,
      Map<String, VoidCallback> actionCallbacks}) {
    Widget titleWidget = titleText == null
        ? title
        : new Text(
            titleText,
            textAlign: TextAlign.center,
            style: new TextStyle(
              //color: dialogContentColor,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          );
    Widget contentWidget = message == null
        ? content != null ? content : new Container()
        : new Text(
            message,
            textAlign: TextAlign.center,
            style: new TextStyle(
//        color: dialogContentColor,
              fontWeight: FontWeight.w400,
//            fontFamily: Constants.contentFontFamily,
            ),
          );
  }

  static showAlertDialog(BuildContext context, String messaage,
      {VoidCallback callback}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert"),
          content: new Text(messaage == null ? "" : messaage),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (callback != null) {
                  callback();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
