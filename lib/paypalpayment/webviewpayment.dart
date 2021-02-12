import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/memory_management.dart';

class WebviewPayment extends StatefulWidget {
  final String type;
  final String itemId;

  WebviewPayment({
    @required this.type,
    @required this.itemId,
  });

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<WebviewPayment> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  bool offstage = false;
  String userId;

  var kAndroidUserAgent =
      'Mozilla/5.0 (Linux; Android 4.4.4; One Build/KTU84L.H4) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/28.0.0.20.16;]';

  @override
  void initState() {
    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);

    userId = userinfo?.user?.id?.toString(); //MemoryManagement.getuserId();
    flutterWebviewPlugin.onUrlChanged.listen((state) async {
      print(state);

      /* showdialogPayment("Payment Successful!.", "Back To Home", Colors.green,
          AssetStrings.paypal, 1);*/
      //  showBottomSheet("Failed!","Payment Failed!.",0);

      if (state.contains("http://167.172.40.120/sucess")) {
        print("success");

        Navigator.of(context).pop(true);

        //  showBottomSheet("Successful!","Payment Successful!.",1);
        /*showdialogPayment("Payment Successful!.", "Back To Home", Colors.green,
            AssetStrings.paypal, 1);*/
      } else {
        if (state.contains("http://167.172.40.120/cancel")) {
          print("failed");

          Navigator.of(context).pop(false);
          //  showBottomSheet("Failed!","Payment Failed!.",0);
        }
      }
    });

    super.initState();
  }

/* if (state.type == WebViewState.finishLoad) {
        print(state.url);

        print("aviiiii");

      }*/

  void callback() async {
    Navigator.pop(context);
  }

  void showdialogPayment(
      String text, String buttonText, Color colorMsg, String image, int type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)), //this right here
              child: SingleChildScrollView(
                  child: Padding(
                    padding: new EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Stack(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new SizedBox(
                              height: 30.0,
                            ),
                            new Image.asset(
                              image,
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.fill,
                            ),
                            new SizedBox(
                              height: 20.0,
                            ),
                            new Text(
                              text,
                              style: new TextStyle(color: colorMsg, fontSize: 25.0),
                            ),
                            new SizedBox(
                              height: 20.0,
                            ),
                            InkWell(
                              onTap: () {
                            if (type == 1) {
                              Navigator.of(context).pop(true);
                            } else {
                              Navigator.of(context).pop(false);
                            }
                          },
                              child: new Container(
                                height: 45.0,
                                margin:
                                new EdgeInsets.only(left: 32.0, right: 32.0),
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.circular(25.0),
                                    color: AppColors.colorCyanPrimary),
                                child: new Text(
                                  buttonText,
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            new SizedBox(
                              height: 22.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    http: //167.172.40.120/make-payment/{type}/{user_id}/{item_id}
    //  var url = "http://68.183.154.186/api/payment?account_id=${widget.gameId}&user_id=$userId";

    var url =
        "http://167.172.40.120/make-payment/${widget.type}/$userId/${widget.itemId}";
    print("payment url $url");
    return new WebviewScaffold(
        withJavascript: true,
        // appCacheEnabled: true,
        url: url,
        userAgent: kAndroidUserAgent,
        appBar: new AppBar(
          elevation: 4.0,
          title: new Text(
            "Payment",
            style: new TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
            size: 25.0,
          ),
          centerTitle: true,
        ),
        withZoom: true,
        hidden: true,
        withLocalStorage: true);
  }
}
