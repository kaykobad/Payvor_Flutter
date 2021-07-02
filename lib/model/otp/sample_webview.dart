import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:payvor/model/login/media_request.dart';
import 'package:payvor/pages/social_login.dart';

class WebviewInsta extends StatefulWidget {
  ValueChanged<Token> callback;

  WebviewInsta({this.callback});

  @override
  _WebviewInstaState createState() => _WebviewInstaState();
}

class _WebviewInstaState extends State<WebviewInsta> {
  String appId = "671655060202677";
  String appSecret = "015b739c9f1a115c79f0b7c7288c9cd2";

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  String url = "";

  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
        }),
  ].toSet();

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    url =
        "https://api.instagram.com/oauth/authorize?client_id=$appId&redirect_uri=https://github.com/login&scope=user_profile,user_media&response_type=code";

    flutterWebViewPlugin.onUrlChanged.listen((String url) async {
      print("url + $url"); // IF SUCCESS LOGIN
      if (url.contains("https://github.com/login?code=")) {
        var codes = await url
            .replaceAll("https://github.com/login?code=", '')
            .replaceAll('#_', "");

        final http.Response response = await http
            .post("https://api.instagram.com/oauth/access_token", body: {
          "client_id": appId,
          "redirect_uri": "https://github.com/login",
          "client_secret": appSecret,
          "code": codes,
          "grant_type": "authorization_code"
        });
        https: //api.instagram.com/v1/users/{user-id}/?access_token=ACCESS-TOKEN

        var token = new Token.fromMap(json.decode(response.body));

        if (token.access != null) {
          final http.Response response = await http.get(
              "https://graph.instagram.com/${token.id}?fields=id,username,media&access_token=${token.access}");

          var url =
              "https://graph.instagram.com/${token.id}?fields=id,username,media&access_token=${token.access}";
          print(url);
          print(response.statusCode);

          try {
            if (response.statusCode == 200) {
              var tokenName =
                  new MediaResponse.fromJson(json.decode(response.body));
              token.username = tokenName.username;

              if (tokenName.media != null && tokenName.media.data.length > 0) {
                var mediaId = tokenName.media.data[0].id;

                final http.Response response = await http.get(
                    "https://graph.instagram.com/$mediaId?fields=media_type,media_url&access_token=${token.access}");

                if (response.statusCode == 200) {
                  var media = new MediaNew.fromMap(json.decode(response.body));

                  token.image = media.media_url;
                }
              }
            }
          } catch (e) {}

          /*   https://graph.instagram.com/17870837731992331?fields=media_type,media_url&

          final http.Response response = await http.get("https://graph.instagram.com/${token.id}?fields=id,username&access_token=${token.access}");
*/

          //  print("token not null");
          //print(json.decode(response.body));
          flutterWebViewPlugin.close();
          widget.callback(token);
          Navigator.pop(context);
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebviewScaffold(
        url: url,
        javascriptChannels: jsChannels,
        mediaPlaybackRequiresUserGesture: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: InkWell(
            onTap: () {
              flutterWebViewPlugin.close();
              Navigator.pop(context);
            },
            child: new Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 28.0,
            ),
          ),
        ),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(
          color: Colors.white,
          child: const Center(
            child: Text('Loading.....'),
          ),
        ),
      ),
    );
    ;
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.

    flutterWebViewPlugin.dispose();

    super.dispose();
  }
}

class MediaNew {
  String media_url;
  int id;
  String media_type;

  MediaNew.fromMap(Map json) {
    media_url = json['media_url'];
    id = json['user_id'];
    media_type = json['media_type'];
  }
}
