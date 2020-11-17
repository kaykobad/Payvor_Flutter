import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewPages extends StatefulWidget {
  final String heading;
  final String url;

  WebViewPages({@required this.heading, @required this.url});

  @override
  _WebViewPagesState createState() => _WebViewPagesState();
}

class _WebViewPagesState extends State<WebViewPages> {
  var _showLoader = true;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  VoidCallback callBack() {
    Navigator.pop(context);
  }

  Widget _customAppBar() {
    return PreferredSize(

      preferredSize: Size.fromHeight(120),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16,
            ),
            backButton(callBack),
            SizedBox(
              height: 16,
            ),
            Text(
              widget.heading,
              style: TextStyle(
                  fontSize: 22, fontFamily: AssetStrings.giloryExteraBoldStyle),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
          appBar: _customAppBar(),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left:8.0,right:8,bottom: 8),
                child: WebView(
                  initialUrl: widget.url,
                  javascriptMode: JavascriptMode.unrestricted,

                  // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                  // ignore: prefer_collection_literals
                  javascriptChannels: <JavascriptChannel>[].toSet(),
                  navigationDelegate: (NavigationRequest request) {
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (String url) {
                    print('Page started loading: $url');
                  },
                  onPageFinished: (String url) {
                    setState(() {
                      _showLoader = false;
                    });
                    print('Page finished loading: $url');
                  },
                  gestureNavigationEnabled: true,
                ),
              ),
              Visibility(
                  visible: _showLoader,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ))
            ],
          )),
    );
  }
}
