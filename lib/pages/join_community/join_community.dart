import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/otp/sample_webview.dart';
import 'package:payvor/model/signup/signup_social_request.dart';
import 'package:payvor/model/signup/signuprequest.dart';
import 'package:payvor/pages/chat/payvor_firebase_user.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/login/login.dart';
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

class JoinCommunityNew extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<JoinCommunityNew> {
  TextEditingController _EmailController = new TextEditingController();
  TextEditingController _FullNameController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _fieldKey = new GlobalKey<FormState>();
  FocusNode _EmailField = new FocusNode();
  FocusNode __FullNameField = new FocusNode();
  String name = "";
  String email = "";
  String snsId = "";
  String type = "";
  String profilePic = "";

  AuthProvider provider;
  FirebaseProvider firebaseProvider;

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

  /* Widget getTextField(String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      {bool obsectextType}) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      padding: new EdgeInsets.only(top: 2.0, bottom: 2.0, right: 10.0),
      decoration: new BoxDecoration(
          color: Colors.transparent,
          border: new Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: new BorderRadius.circular(8.0)),
      child: new TextFormField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        focusNode: focusNodeCurrent,
        onFieldSubmitted: (String value) {
          if (focusNodeCurrent == __FullNameField) {
            __FullNameField.unfocus();
          } else {
            FocusScope.of(context).autofocus(focusNodeNext);
          }
        },
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
      child: new TextFormField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        focusNode: focusNodeCurrent,
        onFieldSubmitted: (String value) {
          if (focusNodeCurrent == __FullNameField) {
            __FullNameField.unfocus();
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
            padding: const EdgeInsets.all(14.0),
            child: new Image.asset(
              svgPicture,
              width: 20.0,
              height: 20.0,
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

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Scaffold(
            appBar: getAppBarNew(context),
            backgroundColor: Colors.white,
            key: _scaffoldKeys,
            body: new SingleChildScrollView(
              child: Form(
                key: _fieldKey,
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
                            "Join the community here!",
                            style: TextThemes.extraBold,
                          )),
                      Container(
                        margin: new EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 6),
                        child: new Text(
                          ResString().get('enter_your_details'),
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
                          __FullNameField,
                          TextInputType.emailAddress,
                          AssetStrings.emailPng),
                      new SizedBox(
                        height: 18.0,
                      ),
                      getTextField(
                          ResString().get('full_name'),
                          _FullNameController,
                          __FullNameField,
                          __FullNameField,
                          TextInputType.text,
                          AssetStrings.fullname),
                      new SizedBox(
                        height: 54.0,
                      ),
                      Container(
                          child: getSetupButtonNew(callback,
                              ResString().get('sign_up_button'), 20)),
                      Container(
                        alignment: Alignment.center,
                        margin: new EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 98),
                        child: new Text(ResString().get('or_signup_with'),
                            style: TextThemes.greyTextFieldMedium),
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
                                )),
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
                                )),
                          ],
                        ),
                      ),
                      space(),
                      new SizedBox(
                        height: 27.0,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: new RichText(
                            textAlign: TextAlign.center,
                            text: new TextSpan(
                              text: ResString().get('already_have_Account'),
                              style: TextThemes.greyDarkTextFieldMedium,
                              children: <TextSpan>[
                                new TextSpan(
                                  text: ResString().get('login_button'),
                                  style: TextThemes.redTextSmallMedium,
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        new CupertinoPageRoute(
                                            builder: (BuildContext context) {
                                          return new LoginScreenNew();
                                        }),
                                      );
                                    },
                                ),
                              ],
                            )),
                      ),
                      new SizedBox(
                        height: 15.0,
                      ),
                   //   termAndConditionView
                    ],
                  ),
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

  var _valueC = false;

  void onChecked(bool value) {
    setState(() {
      _valueC = value;
      print('value: $value');
    });
  }

  get termAndConditionView => Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: new Row(
          children: <Widget>[
            new Checkbox(
              value: _valueC,
              onChanged: onChecked,
            ),
            privacyPolicyLinkAndTermsOfService()
          ],
        ),
      );

  Widget privacyPolicyLinkAndTermsOfService() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text.rich(TextSpan(
            text: 'By continuing, you agree to our ',
            style: TextStyle(fontSize: 12, color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // code to open / launch terms of service link here
                    }),
              TextSpan(
                  text: ' and ',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // code to open / launch privacy policy link here
                          })
                  ])
            ])),
      ),
    );
  }

  Future<ValueSetter> voidCallBackLike(Token tokem) async {
    {
      email = tokem.id.toString() + "_";
      name = tokem.username ?? "";
      type = "3";
      snsId = tokem.id.toString();
      profilePic = tokem.image ?? "";
      hitApi();
    }
  }

  void getInstaUserInfo() async {
    /*var googleSignInAccount = await new SocialLogin().getToken(
        "671655060202677",
        "015b739c9f1a115c79f0b7c7288c9cd2",
        voidCallBackLike);*/

    try {
      Navigator.push(
        context,
        new CupertinoPageRoute(builder: (BuildContext context) {
          return Material(
            child: new WebviewInsta(
              callback: voidCallBackLike,
            ),
          );
        }),
      );
    } catch (ex) {}
  }

  void getTwitterInfo() async {
    var socialLogin = new SocialLogin();
    var result = (Platform.isIOS)
        ? await socialLogin.twitterLogin()
        : await socialLogin.twitterLoginAndroid();

    if (result != null && result.login) {
      email = result.id + "_" + result.email;
      name = result.username;
      type = "2";
      snsId = result.id;
      profilePic = result.image;
      hitApi();
    } else {
      showInSnackBar(Messages.someAuthIssue);
    }
  }

  void getFacebookUserInfo() async {
    var googleSignInAccount = await new SocialLogin().initiateFacebookLogin();

    if (googleSignInAccount != null && googleSignInAccount is Map) {
      var nameUser = googleSignInAccount["name"];
      var id = googleSignInAccount["id"];
      var emails = id + "_" + googleSignInAccount["email"];
      var photodata = googleSignInAccount["picture"];
      var photourl = photodata["data"];
      // MemoryManagement.setuserName(username: nameUser);

      var photo = photourl["url"];

//      print("$nameUser");
//      print("$email");
//      print("$photodata");
//      print("$photourl");
//      print("$photo");

      email = emails;
      name = nameUser;
      type = "1";
      snsId = id;
      profilePic = photo;
      hitApi();
    } else {
      showInSnackBar(Messages.someAuthIssue);
    }
  }

  hitApi() async {
    provider.setLoading();
    var response;

    var types = "";

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

    if (type == "0") {
      SignUpRequest loginRequest = new SignUpRequest(
          name: name, password: "123", email: email, type: types);
      response = await provider.signup(loginRequest, context);
      MemoryManagement.socialMediaStatus("0");
    } else {
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

      MemoryManagement.setAccessToken(accessToken: response.data);
      MemoryManagement.setUserInfo(userInfo: json.encode(response));

      var email = _EmailController.text;

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

      try {
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
      MemoryManagement.setScreenType(type: "1");

      if (type == "0") {
        if (response?.user != null && response?.user.is_location == 0) {
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

      if (response.isnew == null || response.isnew) {
        Navigator.push(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return new PhoneNumberAdd();
          }),
        );
      } else {
        MemoryManagement.setUserLoggedIn(isUserLoggedin: true);
        Navigator.pushAndRemoveUntil(
          context,
          new CupertinoPageRoute(builder: (BuildContext context) {
            return DashBoardScreen();
          }),
          (route) => false,
        );
      }
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);
      showInSnackBar(apiError.error);
    }
  }

  PayvorFirebaseUser getUser(
      LoginSignupResponse signupResponse, String firebaseId, String email) {
    return new PayvorFirebaseUser(
        fullName: signupResponse?.user?.name,
        email: email,
        location: signupResponse?.user?.location,
        updated: DateTime.now().toIso8601String(),
        created: DateTime.now().toIso8601String(),
        filmShapeId: signupResponse?.user?.id,
        firebaseId: firebaseId,
        isOnline: true);
  }

  static String validatorEmail(String value) {
    String data = emailValidator(email: value);
  }

  void goToAddPhone() {
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new PhoneNumberAdd();
      }),
    );
  }

  void callback() {
    email = _EmailController.text;
    name = _FullNameController.text;
    type = "0";
    snsId = "";

    if (_EmailController.text.isEmpty ||
        _EmailController.text.trim().length == 0) {
      showInSnackBar(ResString().get('enter_email'));
      return;
    } else if (!isEmailFormatValid(email.trim())) {
      showInSnackBar(ResString().get('enter_valid_email'));
      return;
    } else if (name.isEmpty || name.length == 0) {
      showInSnackBar(ResString().get('enter_full_name'));
      return;
    }

    hitApi();

    //  goToAddPhone();
  }

  void _doAppleLogin() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      //  print(credential);

      email = credential?.userIdentifier ?? "" + "_" + credential?.email ?? "";
      name = credential?.givenName ?? "";
      type = "4";
      snsId = credential?.userIdentifier ?? "";
      profilePic = "";
      hitApi();
    } catch (ex) {
      showInSnackBar(Messages.genericError);
    }
  }
}
