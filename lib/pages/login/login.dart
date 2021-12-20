// import 'dart:io';
// import 'package:payvor/model/otp/sample_webview.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginrequest.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/signup/signup_social_request.dart';
import 'package:payvor/pages/chat/payvor_firebase_user.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/forgot_password/forgot_password.dart';
import 'package:payvor/pages/join_community/join_community.dart';
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

class LoginScreenNew extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenNew> {
  TextEditingController _EmailController = TextEditingController();
  TextEditingController _PasswordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeys = GlobalKey<ScaffoldState>();
  FocusNode _EmailField = FocusNode();
  FocusNode _PasswordField = FocusNode();
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

  Widget space() => SizedBox(height: 30.0);
  Widget getView() => Container(height: 1.0, color: Colors.grey.withOpacity(0.7));

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  Widget getTextField(
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      {bool obsectextType=false}) {
    return Container(
      margin: EdgeInsets.only(left: 20.0, right: 20.0),
      height: Constants.textFieldHeight,
      child: TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        obscureText: obsectextType,
        focusNode: focusNodeCurrent,
        onSubmitted: (String value) {
          if (focusNodeCurrent == _PasswordField) {
            _PasswordField.unfocus();
          } else {
            FocusScope.of(context).autofocus(focusNodeNext);
          }
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.colorCyanPrimary),
            borderRadius: BorderRadius.circular(4),
          ),
          contentPadding: EdgeInsets.only(top: 10.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Image.asset(
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
                      margin: EdgeInsets.only(right: 10.0, bottom: 4),
                      alignment: Alignment.centerRight,
                      child: Text(
                        obsecureText ? "show" : "hide",
                        style: TextThemes.blackTextSmallNormal,
                      ),
                    ),
                  ),
                )
              : Container(width: 1.0),
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
      LoginRequest loginRequest = LoginRequest(
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
      SignUpSocialRequest loginRequest = SignUpSocialRequest(
        name: name,
        profile_pic: profilePic,
        email: email,
        type: types,
        snsId: snsId,
      );

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
      MemoryManagement.setUserLoggedIn(isUserLoggedin: true);
      MemoryManagement.setGuestUser(type: false);
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (BuildContext context) {
          return DashBoardScreen();
        }),
      );

      /* if (response?.user != null && response?.user.is_password == 0) {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (BuildContext context) {
              return ResetPassword();
            }),
          );

          return;
        }
      else {
        MemoryManagement.setUserLoggedIn(isUserLoggedin: true);

          Navigator.push(
            context,
            CupertinoPageRoute(builder: (BuildContext context) {
              return DashBoardScreen();
            }),
          );
          return;
      }*/

    } else {
      firebaseProvider.hideLoader();
      APIError apiError = response;
      // print(apiError.error);
      showInSnackBar(apiError.error ?? Messages.unAuthorizedError);
    }
  }

  PayvorFirebaseUser getUser(LoginSignupResponse signupResponse, String firebaseId, String email) {
    return PayvorFirebaseUser(
      fullName: signupResponse.user.name,
      email: email,
      location: signupResponse.user.location,
      updated: DateTime.now().toIso8601String(),
      created: DateTime.now().toIso8601String(),
      filmShapeId: signupResponse.user.id,
      firebaseId: firebaseId,
      isOnline: true,
      thumbnailUrl: signupResponse.user.profilePic,
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(SnackBar(content: Text(value)));
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
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                width: screensize.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: Constants.backIconsSpace),
                    Container(
                      margin: EdgeInsets.only(left: 20.0),
                      child: Text("Welcome Back", style: TextThemes.extraBold),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: ResString().get('dont_have_account'),
                          style: TextStyle(
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 16,
                            color: AppColors.darkgrey,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: ResString().get('create_account_button'),
                              style: TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.redLight,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (BuildContext context) {
                                        return JoinCommunityNew();
                                      },
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
                    //   child: Text(
                    //     ResString().get('to_continuew_plz'),
                    //     style: TextThemes.grayNormal,
                    //   ),
                    // ),
                    space(),
                    SizedBox(height: 15.0),
                    getTextField(
                      ResString().get('email_address'),
                      _EmailController,
                      _EmailField,
                      _PasswordField,
                      TextInputType.emailAddress,
                      AssetStrings.emailPng,
                      obsectextType: false,
                    ),
                    SizedBox(height: 18.0),
                    getTextField(
                      ResString().get('password'),
                      _PasswordController,
                      _PasswordField,
                      _PasswordField,
                      TextInputType.text,
                      AssetStrings.passPng,
                      obsectextType: true,
                    ),
                    SizedBox(height: 24.0),
                    Container(
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),
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
                                      ? SvgPicture.asset(AssetStrings.tick)
                                      : Container(),
                                ),
                              ),
                            ),
                            decoration: boolCheckBox
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: AppColors.colorCyanPrimary)
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.6),
                                      width: 1.6,
                                    )),
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                boolCheckBox = !boolCheckBox;
                                setState(() {});
                              },
                              child: Text(
                                ResString().get('remember_me'),
                                style: TextThemes.blackTextSmallMedium,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                    return ForgotPassword(type: 1);
                                  },
                                ),
                              );
                            },
                            child: Text(
                              ResString().get('forgot_pass'),
                              style: TextThemes.redTextSmallMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60.0),
                    Container(
                      child: getSetupButtonNew(callback, ResString().get('login'), 20),
                    ),

                    // Social Login Starts here
                    // Container(
                    //   margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 32),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Container(
                    //           height: 1.0,
                    //           color: AppColors.colorGray,
                    //         ),
                    //       ),
                    //       Container(
                    //         margin: EdgeInsets.only(left: 8, right: 8),
                    //         child: Text(
                    //           "OR LOGIN WITH",
                    //           style: TextStyle(
                    //               color: AppColors.lightGrayNew, fontSize: 12),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Container(
                    //           height: 1.0,
                    //           color: AppColors.colorGray,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // space(),
                    // Container(
                    //   alignment: Alignment.center,
                    //   margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       (Platform.isIOS)
                    //           ? InkWell(
                    //               onTap: () {
                    //                 _doAppleLogin();
                    //               },
                    //               child: SvgPicture.asset(
                    //                 AssetStrings.appleLogin,
                    //                 height: 48,
                    //                 width: 48,
                    //               ),
                    //             )
                    //           : Container(),
                    //       (Platform.isIOS)
                    //           ? SizedBox(
                    //               width: 16.0,
                    //             )
                    //           : Container(),
                    //       InkWell(
                    //         onTap: () {
                    //           getFacebookUserInfo();
                    //         },
                    //         child: SvgPicture.asset(
                    //           AssetStrings.facebook,
                    //           height: 48,
                    //           width: 48,
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 16.0,
                    //       ),
                    //       InkWell(
                    //         onTap: () {
                    //           getTwitterInfo();
                    //         },
                    //         child: SvgPicture.asset(
                    //           AssetStrings.twitter,
                    //           height: 48,
                    //           width: 48,
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 16.0,
                    //       ),
                    //       InkWell(
                    //         onTap: () {
                    //           getInstaUserInfo();
                    //         },
                    //         child: Image.asset(
                    //           AssetStrings.insta,
                    //           height: 48,
                    //           width: 48,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // space(),
                    // SizedBox(
                    //   height: 40.0,
                    // ),
                    SizedBox(height: 17.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
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

  // Social Login Functionality
  // void getInstaUserInfo() async {
  //   await Navigator.push(
  //     context,
  //     CupertinoPageRoute(builder: (BuildContext context) {
  //       return Material(
  //         child: WebviewInsta(
  //           callback: voidCallBackLike,
  //         ),
  //       );
  //     }),
  //   );
  // }
  //
  // void getTwitterInfo() async {
  //   var socialLogin = SocialLogin();
  //   var result = (Platform.isIOS)
  //       ? await socialLogin.twitterLogin()
  //       : await socialLogin.twitterLoginAndroid();
  //
  //   if (result != null && result.login) {
  //     email = (result.email != null)
  //         ? (result.id + "_" + result.email)
  //         : "${result.id}@twitter.com";
  //
  //     name = result.username;
  //     type = "2";
  //     snsId = result.id;
  //     profilePic = result.image;
  //     hitApi(1);
  //   } else {
  //     showInSnackBar(Messages.someAuthIssue);
  //   }
  // }
  //
  // void getFacebookUserInfo() async {
  //   var facebookSignInAccount = await SocialLogin().initiateFacebookLogin();
  //
  //   if (facebookSignInAccount != null && facebookSignInAccount is Map) {
  //     var nameUser = facebookSignInAccount["name"];
  //     var id = facebookSignInAccount["id"];
  //     var fbEmail = facebookSignInAccount["email"];
  //     var photodata = facebookSignInAccount["picture"];
  //     var photourl = photodata["data"];
  //
  //     var photo = photourl["url"];
  //
  //     email = (fbEmail != null) ? (id + "_" + fbEmail) : ("$id@facebook.com");
  //     name = nameUser;
  //     type = "1";
  //     snsId = id;
  //     profilePic = photo;
  //     hitApi(1);
  //   } else {
  //     showInSnackBar(Messages.genericError);
  //   }
  // }
  //
  // void _doAppleLogin() async {
  //   try {
  //     final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );
  //
  //     snsId = credential?.userIdentifier ?? "";
  //     var userEmail = credential?.email;
  //     email =
  //         (userEmail != null) ? (snsId + "_" + userEmail) : "$snsId@apple.com";
  //     name = credential?.givenName ?? "";
  //     type = "4";
  //     profilePic = "";
  //     hitApi(1);
  //   } catch (ex) {
  //     showInSnackBar(Messages.genericError + ex.toString());
  //   }
  // }
}
