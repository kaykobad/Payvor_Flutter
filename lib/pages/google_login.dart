import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;

class SocialLogin extends StatelessWidget {
  bool isLoggedIn = false;
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<dynamic> initiateFacebookLogin() async {
    var data;
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);
    print(facebookLoginResult.errorMessage);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        data = null;
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        data = null;
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,picture.height(200),birthday,gender,last_name,email&access_token=${facebookLoginResult.accessToken.token}');

        Map profile = json.decode(graphResponse.body);

        print(profile.toString());
        data = profile;
        break;
    }
    return data;
  }

  Future<dynamic> twitterLogin() async {
    /*  var twitterLogin = new TwitterLogin(
     consumerKey: '<your consumer key>',
     consumerSecret: '<your consumer secret>',
   );

   final TwitterLoginResult result = await twitterLogin.authorize();

   switch (result.status) {
     case TwitterLoginStatus.loggedIn:
       var session = result.session;
       _sendTokenAndSecretToServer(session.token, session.secret);
       break;
     case TwitterLoginStatus.cancelledByUser:
   //    _showCancelMessage();
       break;
     case TwitterLoginStatus.error:
      // _showErrorMessage(result.error);
       break;
   }*/
  }

  Future<Token> getToken(String appId, String appSecret) async {
    Stream<String> onCode = await _server();
    String url =
        "https://api.instagram.com/oauth/authorize?client_id=$appId&redirect_uri=http://localhost&response_type=code";
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.launch(url);
    final String code = await onCode.first;
    print("code getting");
    print("code + $code");
    final http.Response response =
        await http.post("https://api.instagram.com/oauth/access_token", body: {
      "client_id": appId,
      "redirect_uri": "http://localhost",
      "client_secret": appSecret,
      "code": code,
      "grant_type": "authorization_code"
    });
    flutterWebviewPlugin.close();
    return new Token.fromMap(json.decode(response.body));
  }

  @Deprecated("Use loopbackIPv4 instead")
  Future<Stream<String>> _server() async {
    final StreamController<String> onCode = new StreamController();
    HttpServer server = await HttpServer.bind(
        InternetAddress.LOOPBACK_IP_V4, 8585,
        shared: true);
    server.listen((HttpRequest request) async {
      final String code = request.uri.queryParameters["code"];
      request.response
        ..statusCode = 200
        ..headers.set("Content-Type", ContentType.HTML.mimeType)
        ..write("<html><h1>You can now close this window</h1></html>");
      await request.response.close();
      await server.close(force: true);
      onCode.add(code);

      print("onCode $code");

      await onCode.close();
    });
    return onCode.stream;
  }
}

class Token {
  String access;
  String id;
  String username;
  String full_name;
  String profile_picture;

  Token.fromMap(Map json) {
    access = json['access_token'];
    id = json['user']['id'];
    username = json['user']['username'];
    full_name = json['user']['full_name'];
    profile_picture = json['user']['profile_picture'];
  }
}
