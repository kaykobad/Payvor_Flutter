import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_twitter/flutter_twitter.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/signup/signup_social_request.dart';
import 'package:payvor/model/signup/signuprequest.dart';
import 'package:payvor/model/signup/signupresponse.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/pages/google_login.dart';
import 'package:payvor/pages/login/login.dart';
import 'package:payvor/pages/phone_number_add/phone_number_add.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/ValidatorFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

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

  var twitterLogin = new TwitterLogin(
    consumerKey: 'NjhbcYuBWb8RZAOnbd2nlbYD0',
    consumerSecret: 'rqXzFc5wPl7UnyvDjTSH4aaPHRB39i3BE6FjaDgJ3nFalp04dl',
  );

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
  }

  void showInSnackBar(String value) {
    _scaffoldKeys.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    return SafeArea(
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
                        height: 36.0,
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
                          "Enter your details to create an account",
                          style: TextThemes.grayNormal,
                        ),
                      ),
                      space(),
                      new SizedBox(
                        height: 15.0,
                      ),
                      getTextField(
                          "Email Address",
                          _EmailController,
                          _EmailField,
                          __FullNameField,
                          TextInputType.emailAddress,
                          AssetStrings.emailPng),
                      new SizedBox(
                        height: 18.0,
                      ),
                      getTextField(
                          "Full Name",
                          _FullNameController,
                          __FullNameField,
                          __FullNameField,
                          TextInputType.text,
                          AssetStrings.fullname),
                      new SizedBox(
                        height: 54.0,
                      ),
                      Container(
                          child: getSetupButtonNew(callback, "Sign Up", 20)),
                      Container(
                        alignment: Alignment.center,
                        margin: new EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 98),
                        child: new Text("or signup with",
                            style: TextThemes.greyTextFieldMedium),
                      ),
                      space(),
                      Container(
                        alignment: Alignment.center,
                        margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
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
                              text: "Already have an account? ",
                              style: TextThemes.greyDarkTextFieldMedium,
                              children: <TextSpan>[
                                new TextSpan(
                                  text: "LOGIN",
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

  Future<ValueSetter> voidCallBackLike(Token tokem) async {
    {
      print("tokenss get ${tokem.access}");
      print("id get ${tokem.id}");
      print("name get ${tokem.username}");

      email = "";
      name = "";
      type = "3";
      snsId = tokem.id.toString();
      hitApi();
    }
  }

  void getInstaUserInfo() async {
    var googleSignInAccount = await new SocialLogin().getToken(
        "671655060202677",
        "015b739c9f1a115c79f0b7c7288c9cd2",
        voidCallBackLike);
  }

  void getTwitterInfo() async {
    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        var session = result.session;
        print(session.token);
        print(session.username);
        print(session.userId);
        email = "";
        name = session.username;
        type = "2";
        snsId = session.userId;
        hitApi();

        break;
      case TwitterLoginStatus.cancelledByUser:
        //    _showCancelMessage();
        break;
      case TwitterLoginStatus.error:
        // _showErrorMessage(result.error);
        break;
    }
  }

  void getFacebookUserInfo() async {
    var googleSignInAccount = await new SocialLogin().initiateFacebookLogin();

    if (googleSignInAccount != null && googleSignInAccount is Map) {
      var nameUser = googleSignInAccount["name"];
      var id = googleSignInAccount["id"];
      var emails = googleSignInAccount["email"];
      var photodata = googleSignInAccount["picture"];
      var photourl = photodata["data"];
      // MemoryManagement.setuserName(username: nameUser);

      var photo = photourl["url"];

      print("$nameUser");
      print("$email");
      print("$photodata");
      print("$photourl");
      print("$photo");

      email = emails;
      name = nameUser;
      type = "1";
      snsId = id;
      profilePic = photo;
      hitApi();
    } else {
      showInSnackBar(
          "There are some authenticate issues.Please try again later.");
    }
  }

  hitApi() async {
    provider.setLoading();
    var response;

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
          types = "Go";
        }
        break;

      case "3":
        {
          types = "In";
        }
    }

    if (type == "0") {
      SignUpRequest loginRequest = new SignUpRequest(
          name: name, password: "123", email: email, type: types);
      response = await provider.signup(loginRequest, context);

      MemoryManagement.socialMediaStatus("0");
      MemoryManagement.setUserEmail(email);
      MemoryManagement.setuserName(username: name);
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
    provider.hideLoader();
    if (response is LoginSignupResponse) {
      if (response.isnew == null || response.isnew) {
        MemoryManagement.setAccessToken(accessToken: response.data);

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
      showInSnackBar("Please enter email address.");
      return;
    } else if (!isEmailFormatValid(email.trim())) {
      showInSnackBar('Please enter a valid email address.');
      return;
    } else if (name.isEmpty || name.length == 0) {
      showInSnackBar('Please enter full name.');
      return;
    }

    hitApi();

    //  goToAddPhone();
  }
}
