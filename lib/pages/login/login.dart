import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginrequest.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/otp/sample_webview.dart';
import 'package:payvor/model/signup/signup_social_request.dart';
import 'package:payvor/pages/chat/payvor_firebase_user.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/forgot_password/forgot_password.dart';
import 'package:payvor/pages/join_community/join_community.dart';
import 'package:payvor/pages/phone_number_add/phone_number_add.dart';
import 'package:payvor/pages/reset_password/reset_password.dart';
import 'package:payvor/pages/social_login.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/ValidatorFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreenNew extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenNew> {
  TextEditingController _EmailController = new TextEditingController();
  TextEditingController _PasswordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  FocusNode _EmailField = new FocusNode();
  FocusNode _PasswordField = new FocusNode();
  IconData icon = Icons.visibility_off;
  bool obsecureText = true;
  bool boolCheckBox = false;
  FirebaseProvider firebaseProvider;
  AuthProvider provider;

  String name = "";
  String email = "";
  String snsId = "";
  String type = "";
  String profilePic = "";

  Widget space() {
    return new SizedBox(
      height: 30.0,
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  Widget getView() {
    return new Container(
      height: 1.0,
      color: Colors.grey.withOpacity(0.7),
    );
  }

  Widget getTextField(
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      {bool obsectextType}) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      height: Constants.textFieldHeight,
      child: new TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        obscureText: obsectextType ? obsecureText : false,
        focusNode: focusNodeCurrent,
        onSubmitted: (String value) {
          if (focusNodeCurrent == _PasswordField) {
            _PasswordField.unfocus();
          } else {
            FocusScope.of(context).autofocus(focusNodeNext);
          }
        },
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
          contentPadding: new EdgeInsets.only(top: 10.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
                left: 14.0, right: 14.0, bottom: 14, top: 14.0),
            child: new Image.asset(
              svgPicture,
              width: 20.0,
              height: 20.0,
            ),
          ),
          suffixIcon: obsectextType
              ? Offstage(
                  offstage: !obsectextType,
                  child: InkWell(
                    onTap: () {
                      obsecureText = !obsecureText;
                      setState(() {});
                    },
                    child: Container(
                      width: 30.0,
                      margin: new EdgeInsets.only(right: 10.0, bottom: 4),
                      alignment: Alignment.centerRight,
                      child: new Text(
                        obsecureText ? "show" : "hide",
                        style: TextThemes.blackTextSmallNormal,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 1.0,
                ),
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  hitApi(int typse) async {
    provider.setLoading();

    var response;

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

    if (typse == 0) {
      LoginRequest loginRequest = new LoginRequest(
          password: _PasswordController.text, email: _EmailController.text);
      response = await provider.login(loginRequest, context);
      MemoryManagement.socialMediaStatus("0");
    } else {
      var types = "";

      switch (type) {
        case "0":
          {
            types = "Re";
          }
          break;
        case "1":
          {
            types = "Fb";
          }
          break;

        case "2":
          {
            types = "tw";
          }
          break;

        case "3":
          {
            types = "In";
          }
          break;
        case "4":
          {
            types = "ap";
          }
      }
      SignUpSocialRequest loginRequest = new SignUpSocialRequest(
          name: name,
          profile_pic: profilePic,
          email: email,
          type: types,
          snsId: snsId);

      response = await provider.socialSignup(loginRequest, context);
      MemoryManagement.socialMediaStatus("1");
    }

    if (response is LoginSignupResponse) {
      provider.setLoading();

      LoginSignupResponse loginSignupResponse = response;
      MemoryManagement.setAccessToken(accessToken: loginSignupResponse.data);
      MemoryManagement.setUserInfo(userInfo: json.encode(response));

      var email = _EmailController.text;

      try {
        switch (type) {
          case "1":
            {
              email = "fb_$snsId@facebook.com";
            }
            break;

          case "2":
            {
              email = "tw_$snsId@twitter.com";
            }
            break;

          case "3":
            {
              email = "in_$snsId@instagram.com";
            }
            break;
          case "4":
            {
              email = "ap_$snsId@apple.com";
            }
        }
        print("email $email");
        //firebase login
        var firebaseId = await firebaseProvider.signIn(
            email, Constants.FIREBASE_USER_PASSWORD);
        //update user info to fire store user collection
        await firebaseProvider
            .updateFirebaseUser(getUser(response, firebaseId, email));
      } catch (ex) {
        print("error ${ex.toString()}");
        //for old filmshape users
        //firebase signup for later use in chat
        var firebaseId = await firebaseProvider.signUp(
            email, Constants.FIREBASE_USER_PASSWORD);
        //save user info to fire store user collection
        var user = getUser(response, firebaseId, email);
        user.created = DateTime.now()
            .toIso8601String(); //if user is not registered with firebase
        await firebaseProvider.createFirebaseUser(user);
      }

      provider.hideLoader();

      if (type == "0") {
        if (response?.user != null && response?.user?.is_location == 0) {
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return new PhoneNumberAdd();
            }),
          );

          return;
        } else if (response?.user != null && response?.user.is_password == 0) {
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return new ResetPassword();
            }),
          );

          return;
        }
      } else {
        if (response?.user != null && response?.user.is_location == 0) {
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return new PhoneNumberAdd();
            }),
          );
          return;
        }
      }

      MemoryManagement.setUserLoggedIn(isUserLoggedin: true);
      if ((loginSignupResponse.isnew == null || loginSignupResponse.isnew) &&
          typse != 0) {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new PhoneNumberAdd();
          }),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return DashBoardScreen();
          }),
          (route) => false,
        );
      }
    } else {
      firebaseProvider.hideLoader();
      APIError apiError = response;
      // print(apiError.error);
      showInSnackBar(apiError.error ?? Messages.unAuthorizedError);
    }
  }

  PayvorFirebaseUser getUser(
      LoginSignupResponse signupResponse, String firebaseId, String email) {
    return new PayvorFirebaseUser(
        fullName: signupResponse.user.name,
        email: email,
        location: signupResponse.user.location,
        updated: DateTime.now().toIso8601String(),
        created: DateTime.now().toIso8601String(),
        filmShapeId: signupResponse.user.id,
        firebaseId: firebaseId,
        isOnline: true,
        thumbnailUrl: signupResponse.user.profilePic);
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    var screensize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: getAppBarNew(context),
      backgroundColor: Colors.white,
      key: _scaffoldKeys,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: new SingleChildScrollView(
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
                           "Login Perimity",
                          style: TextThemes.extraBold,
                        )),
                    Container(
                      margin:
                          new EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                      child: new Text(
                        ResString().get('to_continuew_plz'),
                        style: TextThemes.grayNormal,
                      ),
                    ),
                    space(),
                    new SizedBox(
                      height: 15.0,
                    ),
                    getTextField(
                        ResString().get('email_address'),
                        _EmailController,
                        _EmailField,
                        _PasswordField,
                        TextInputType.emailAddress,
                        AssetStrings.emailPng,
                        obsectextType: false),
                    new SizedBox(
                      height: 18.0,
                    ),
                    getTextField(
                        ResString().get('password'),
                        _PasswordController,
                        _PasswordField,
                        _PasswordField,
                        TextInputType.text,
                        AssetStrings.passPng,
                        obsectextType: true),
                    new SizedBox(
                      height: 24.0,
                    ),
                    new Container(
                      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        children: <Widget>[
                          /* InkWell(
                            onTap: () {
                              boolCheckBox = !boolCheckBox;
                              setState(() {});
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: boolCheckBox
                                    ? Icon(
                                  Icons.check_box,
                                  size: 22.0,
                                  color: Colors.lightBlueAccent,
                                )
                                    : Icon(
                                  Icons.check_box_outline_blank,
                                  size: 22.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),*/

                          Container(
                            child: InkWell(
                              onTap: () {
                                boolCheckBox = !boolCheckBox;
                                setState(() {});
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: boolCheckBox
                                      ? new SvgPicture.asset(
                                          AssetStrings.tick,
                                        )
                                      : new Container(),
                                ),
                              ),
                            ),
                            decoration: boolCheckBox
                                ? new BoxDecoration(
                                    borderRadius:
                                        new BorderRadius.circular(4.0),
                                    color: AppColors.colorCyanPrimary)
                                : new BoxDecoration(
                                    borderRadius:
                                        new BorderRadius.circular(4.0),
                                    border: new Border.all(
                                        color: Colors.grey.withOpacity(0.6),
                                        width: 1.6)),
                            width: 20,
                            height: 20,
                          ),
                          new SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                              child: InkWell(
                                  onTap: () {
                                    boolCheckBox = !boolCheckBox;
                                    setState(() {});
                                  },
                                  child: new Text(
                                      ResString().get('remember_me'),
                                      style: TextThemes.blackTextSmallMedium))),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                new CupertinoPageRoute(
                                    builder: (BuildContext context) {
                                  return new ForgotPassword(
                                    type: 1,
                                  );
                                }),
                              );
                            },
                            child: new Text(
                              ResString().get('forgot_pass'),
                              style: TextThemes.redTextSmallMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 25.0,
                    ),
                    Container(
                        child: getSetupButtonNew(
                            callback, ResString().get('login'), 20)),
                    new Container(
                      margin:
                          new EdgeInsets.only(left: 20.0, right: 20.0, top: 32),
                      child: new Row(
                        children: [
                          Expanded(
                            child: new Container(
                              height: 1.0,
                              color: AppColors.colorGray,
                            ),
                          ),
                          new Container(
                            margin: new EdgeInsets.only(left: 8, right: 8),
                            child: new Text(
                              "OR LOGIN WITH",
                              style: new TextStyle(
                                  color: AppColors.lightGrayNew, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: new Container(
                              height: 1.0,
                              color: AppColors.colorGray,
                            ),
                          )
                        ],
                      ),
                    ),
                    space(),
                    Container(
                      alignment: Alignment.center,
                      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          (Platform.isIOS)
                              ? InkWell(
                                  onTap: () {
                                    _doAppleLogin();
                                  },
                                  child: new SvgPicture.asset(
                                    AssetStrings.appleLogin,
                                    height: 48,
                                    width: 48,
                                  ),
                                )
                              : Container(),
                          (Platform.isIOS)
                              ? new SizedBox(
                                  width: 16.0,
                                )
                              : Container(),
                          InkWell(
                            onTap: () {
                              getFacebookUserInfo();
                            },
                            child: new SvgPicture.asset(
                              AssetStrings.facebook,
                              height: 48,
                              width: 48,
                            ),
                          ),
                          new SizedBox(
                            width: 16.0,
                          ),
                          InkWell(
                            onTap: () {
                              getTwitterInfo();
                            },
                            child: new SvgPicture.asset(
                              AssetStrings.twitter,
                              height: 48,
                              width: 48,
                            ),
                          ),
                          new SizedBox(
                            width: 16.0,
                          ),
                          InkWell(
                            onTap: () {
                              getInstaUserInfo();
                            },
                            child: new Image.asset(
                              AssetStrings.insta,
                              height: 48,
                              width: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                    space(),
                    new SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: new RichText(
                          textAlign: TextAlign.center,
                          text: new TextSpan(
                            text: ResString().get('dont_have_account'),
                            style: TextThemes.greyDarkTextFieldMedium,
                            children: <TextSpan>[
                              new TextSpan(
                                text: ResString().get('signup_cap_button'),
                                style: TextThemes.redTextSmallMedium,
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      new CupertinoPageRoute(
                                          builder: (BuildContext context) {
                                        return new JoinCommunityNew();
                                      }),
                                    );
                                  },
                              ),
                            ],
                          )),
                    ),
                    new SizedBox(
                      height: 17.0,
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
    );
  }

  void callback() {
    var email = _EmailController.text;
    var password = _PasswordController.text;
    if (_EmailController.text.isEmpty ||
        _EmailController.text.trim().length == 0) {
      showInSnackBar(ResString().get('enter_email'));
      return;
    } else if (!isEmailFormatValid(email.trim())) {
      showInSnackBar(ResString().get('enter_valid_email'));
      return;
    } else if (password.isEmpty || password.length == 0) {
      showInSnackBar(ResString().get('enter_password'));
      return;
    }

    hitApi(0);
  }

  Future<ValueSetter> voidCallBackLike(Token token) async {
    {
      email = token.id.toString() + "_" + "@instagram.com";
      name = token.username ?? "";
      type = "3";
      snsId = token.id.toString();
      hitApi(1);
    }
  }

  void getInstaUserInfo() async {
    await Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(
          child: new WebviewInsta(
            callback: voidCallBackLike,
          ),
        );
      }),
    );
  }

  void getTwitterInfo() async {
    var socialLogin = new SocialLogin();
    var result = (Platform.isIOS)
        ? await socialLogin.twitterLogin()
        : await socialLogin.twitterLoginAndroid();

    if (result != null && result.login) {
      email = (result.email != null)
          ? (result.id + "_" + result.email)
          : "${result.id}@twitter.com";

      name = result.username;
      type = "2";
      snsId = result.id;
      profilePic = result.image;
      hitApi(1);
    } else {
      showInSnackBar(Messages.someAuthIssue);
    }
  }

  void getFacebookUserInfo() async {
    var facebookSignInAccount = await new SocialLogin().initiateFacebookLogin();

    if (facebookSignInAccount != null && facebookSignInAccount is Map) {
      var nameUser = facebookSignInAccount["name"];
      var id = facebookSignInAccount["id"];
      var fbEmail = facebookSignInAccount["email"];
      var photodata = facebookSignInAccount["picture"];
      var photourl = photodata["data"];

      var photo = photourl["url"];

      email = (fbEmail != null) ? (id + "_" + fbEmail) : ("$id@facebook.com");
      name = nameUser;
      type = "1";
      snsId = id;
      profilePic = photo;
      hitApi(1);
    } else {
      showInSnackBar(Messages.genericError);
    }
  }

  void _doAppleLogin() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      snsId = credential?.userIdentifier ?? "";
      var userEmail = credential?.email;
      email =
          (userEmail != null) ? (snsId + "_" + userEmail) : "$snsId@apple.com";
      name = credential?.givenName ?? "";
      type = "4";
      profilePic = "";
      hitApi(1);
    } catch (ex) {
      showInSnackBar(Messages.genericError + ex.toString());
    }
  }
}
