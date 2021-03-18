import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:twitter_login/twitter_login.dart';
//import 'package:flutter_twitter/flutter_twitter.dart' as androidTwitter;
class SocialLogin extends StatelessWidget {
  bool isLoggedIn = false;
  final FacebookLogin facebookSignIn = new FacebookLogin();
  final String _twitterApiKey = 'NjhbcYuBWb8RZAOnbd2nlbYD0';
  final String _twitterApiSecretKey =
      'rqXzFc5wPl7UnyvDjTSH4aaPHRB39i3BE6FjaDgJ3nFalp04dl';

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<dynamic> initiateFacebookLogin() async {
    try {
      var data;
      var facebookLogin = FacebookLogin();
      var facebookLoginResult = await facebookLogin.logIn(['email']);
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
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,picture.height(200),birthday,gender,last_name,email&access_token=${facebookLoginResult
                  .accessToken.token}');

          Map profile = json.decode(graphResponse.body);

          print(profile.toString());
          data = profile;
          break;
      }
      return data;
    }catch(ex)
    {
      print("fb error");
    }
  }

  Future<TwitterAuthResult> twitterLogin() async {
    TwitterAuthResult twitterAuthResult = new TwitterAuthResult();

    try {
      var twitterLogin = new TwitterLogin(
          apiKey: _twitterApiKey,
          apiSecretKey: _twitterApiSecretKey,
          redirectURI: "twitterkit-NjhbcYuBWb8RZAOnbd2nlbYD0://");

      final authResult = await twitterLogin.login();

      print(authResult.errorMessage);

      switch (authResult.status) {
        case TwitterLoginStatus.loggedIn:
          twitterAuthResult.image = authResult.user.thumbnailImage;
          twitterAuthResult.username = authResult.user.name;
          twitterAuthResult.email = authResult.user.email;
          twitterAuthResult.authToken = authResult.authToken;
          twitterAuthResult.authSecToken = authResult.authTokenSecret;
          twitterAuthResult.login = true;
          twitterAuthResult.id = authResult.user.id;
          twitterAuthResult.msg = "Login Successfully";
          break;
        case TwitterLoginStatus.cancelledByUser:
          twitterAuthResult.login = false;
          twitterAuthResult.msg = authResult.errorMessage;
          //    _showCancelMessage();
          break;
        case TwitterLoginStatus.error:
          twitterAuthResult.login = false;
          twitterAuthResult.msg = authResult.errorMessage;
          // _showErrorMessage(result.error);
          break;
      }
      print("twitter id ${authResult.user.id}");
      return twitterAuthResult;
    }catch(ex)
    {
      twitterAuthResult.login = false;
      twitterAuthResult.msg = ex.toString();
      print("twitter_error ${ex.toString()}");
      return twitterAuthResult;
    }

  }

  Future<dynamic> twitterLoginAndroid() async {
//    var twitterLogin = new androidTwitter.TwitterLogin(
//      consumerKey: _twitterApiKey,
//      consumerSecret: _twitterApiSecretKey,
//    );
//
//    TwitterAuthResult twitterAuthResult = new TwitterAuthResult();
//
//    final androidTwitter.TwitterLoginResult result = await twitterLogin.authorize();
//
//    print("status ${result.status}");
//    switch (result.status) {
//      case androidTwitter.TwitterLoginStatus.loggedIn:
//        var session = result.session;
//        twitterAuthResult.email = session.email;
//        twitterAuthResult.username = session.username;
//        twitterAuthResult.id = session.userId;
//        twitterAuthResult.image = "";
//        twitterAuthResult.login = true;
//        twitterAuthResult.msg = "Login Successfully";
//
//        break;
//      case androidTwitter.TwitterLoginStatus.cancelledByUser:
//        twitterAuthResult.login = false;
//        twitterAuthResult.msg = "There are some authenticate issues.Please try again later.";
//        break;
//      case androidTwitter.TwitterLoginStatus.error:
//        twitterAuthResult.login = false;
//        twitterAuthResult.msg = "There are some authenticate issues.Please try again later.";
//        break;
//    }
//      return twitterAuthResult;
  }

/*
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

          */ /*   https://graph.instagram.com/17870837731992331?fields=media_type,media_url&

          final http.Response response = await http.get("https://graph.instagram.com/${token.id}?fields=id,username&access_token=${token.access}");
*/ /*

          print("token not null");
          print(json.decode(response.body));
          flutterWebviewPlugin.close();
          callbackLikeUnlikeProject(token);
        }
      }
    });

  }*/

/*  @Deprecated("Use loopbackIPv4 instead")
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
  }*/
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

class TwitterAuthResult {
  String authToken;
  String authSecToken;
  String id;
  String username;
  String image;
  bool login;
  String msg;
  String email;

  TwitterAuthResult(
      {this.authToken,
      this.authSecToken,
      this.id,
      this.username,
      this.image,
      this.login,
      this.msg,
      this.email});

  TwitterAuthResult.fromMap(Map json) {
    authToken = json['authToken'];
    authSecToken = json['authSecToken'];
    id = json['user_id'];
    username = json['username'];
    image = json['image'];
    login = json['login'];
    msg = json['msg'];
    email = json['email'];
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
