import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:payvor/model/login/media_request.dart';
import 'package:twitter_login/twitter_login.dart';

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
        await facebookLogin.logIn(['email']);
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
    var twitterLogin = new TwitterLogin(
        apiKey: 'NjhbcYuBWb8RZAOnbd2nlbYD0',
        apiSecretKey: 'rqXzFc5wPl7UnyvDjTSH4aaPHRB39i3BE6FjaDgJ3nFalp04dl',
        redirectURI: "twitterkit-NjhbcYuBWb8RZAOnbd2nlbYD0://");

    print(twitterLogin.apiKey);

    final authResult = await twitterLogin.login();

    print(authResult.errorMessage);

    switch (authResult.status) {
      case TwitterLoginStatus.loggedIn:
        //  var session = authResult.session;
        print(authResult.authToken);
        print(authResult.user.screenName);
        print(authResult.user);
        break;
      case TwitterLoginStatus.cancelledByUser:
        //    _showCancelMessage();
        break;
      case TwitterLoginStatus.error:
        // _showErrorMessage(result.error);
        break;
    }

    return authResult;
  }


  Future<Token> getToken(String appId, String appSecret,
      ValueChanged<Token> callbackLikeUnlikeProject) async {
    // Stream<String> onCode = await _server();
    String url =
        "https://api.instagram.com/oauth/authorize?client_id=$appId&redirect_uri=https://github.com/login&scope=user_profile,user_media&response_type=code";
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.launch(url);
    // LISTEN CHANGES
    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      print("url + $url"); // IF SUCCESS LOGIN
      if (url.contains("https://github.com/login?code=")) {
        var codes = await url
            .replaceAll("https://github.com/login?code=", '')
            .replaceAll('#_', "");
        print("urll + $codes"); // IF SUCCESS LOGIN

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
                  var media = new Media.fromMap(json.decode(response.body));

                  token.image = media.media_url;
                }
              }
            }
          } catch (e) {}

          /*   https://graph.instagram.com/17870837731992331?fields=media_type,media_url&

          final http.Response response = await http.get("https://graph.instagram.com/${token.id}?fields=id,username&access_token=${token.access}");
*/

          print("token not null");
          print(json.decode(response.body));
          flutterWebviewPlugin.close();
          callbackLikeUnlikeProject(token);
        }
      }
    });

  }

  @Deprecated("Use loopbackIPv4 instead")
  Future<Stream<String>> _server() async {
    final StreamController<String> onCode = new StreamController();
    HttpServer server = await HttpServer.bind(
        InternetAddress.LOOPBACK_IP_V4, 8585, shared: true);
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
  int id;
  String username;
  String image;


  Token.fromMap(Map json) {
    access = json['access_token'];
    id = json['user_id'];
    username = json['username'];
    image = json['image'];
  }
}

class Media {
  String media_url;
  int id;
  String media_type;


  Media.fromMap(Map json) {
    media_url = json['media_url'];
    id = json['user_id'];
    media_type = json['media_type'];
  }
}
