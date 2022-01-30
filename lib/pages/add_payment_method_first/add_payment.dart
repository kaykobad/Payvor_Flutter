import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/model/add_paypal/add_paypal_request.dart';
import 'package:payvor/model/add_paypal/get_paypal_data.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/common_response/common_success_response.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/Messages.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/ValidatorFunctions.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class AddPaymentMethodFirst extends StatefulWidget {


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<AddPaymentMethodFirst> with AutomaticKeepAliveClientMixin<AddPaymentMethodFirst> {
  var screenSize;
  AuthProvider provider;
  FirebaseProvider firebaseProvider;
  List<Data> dataList = [];
  TextEditingController _emailController1 = TextEditingController();
  TextEditingController _emailController2 = TextEditingController();
  bool _isButtonActive = false;

  @override
  void dispose() {
    super.dispose();
    _emailController1.dispose();
    _emailController2.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(content: new Text(value ?? Messages.genericError)));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      hitAddApi();
    });
  }

  hitAddApi() async {
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

    provider.setLoading();

    var response = await provider.getPaypalMethod(context);

    if (response is GetPaypalData) {
      provider.hideLoader();

      if (response?.data != null) {
        MemoryManagement.setPaymentStatus(status: true);
        dataList.add(response?.data);
      } else {
        MemoryManagement.setPaymentStatus(status: false);
      }

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  hitDeleteApi(int index, String id) async {
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

    provider.setLoading();

    var response = await provider.deletePaypalMethod(context, id);

    if (response is CommonSuccessResponse) {
      MemoryManagement.setPaymentStatus(status: false);
      provider.hideLoader();
      showInSnackBar("Payment method deleted successfully");

      dataList?.removeAt(index);

      print(response);
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  Future<bool> _addPaypal() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    var account = _emailController1.text;

    if (account.isEmpty || account.trim().length == 0 || !isEmailFormatValid(account)) {
      showInSnackBar('Please enter a valid email');
      return false;
    }

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
      return false;
    }

    provider.setLoading();

    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);

    PayPalAddRequest _request = new PayPalAddRequest(
      paypal_id: _emailController1.text.trim(),
      user_id: userinfo?.user?.id?.toString(),
    );

    var response = await provider.addPaypalMethod(_request, context);

    if (response is ReportResponse) {
      provider.hideLoader();

      print("res $response");

      if (response != null && response.status.code == 200) {
        await hitAddApi();
        showInSnackBar("Payment method added successfully");
        MemoryManagement.setPaymentStatus(status: true);
        _emailController1.clear();
        _emailController2.clear();
      }
      setState(() {});
      return true;
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    firebaseProvider = Provider.of<FirebaseProvider>(context);
    provider = Provider.of<AuthProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF23137D),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFE5E5E5),
        body: SafeArea(
          child: Stack(
            children: [
              _background(),
              _backButton(),
              _body(),
            ],
          ),
        ),
      )
    );

    // screenSize = MediaQuery.of(context).size;
    // provider = Provider.of<AuthProvider>(context);
    // firebaseProvider = Provider.of<FirebaseProvider>(context);
    // return Scaffold(
    //   key: _scaffoldKey,
    //   appBar: getAppBarNew(context),
    //   backgroundColor: AppColors.whiteGray,
    //   body: Stack(
    //     children: <Widget>[
    //       SingleChildScrollView(
    //         child: new Container(
    //           color: AppColors.whiteGray,
    //           child: new Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             textBaseline: TextBaseline.ideographic,
    //             children: <Widget>[
    //               dataList?.length == 0
    //                   ? Container(
    //                       margin: new EdgeInsets.only(
    //                           top: 11, bottom: 11, left: 16, right: 16),
    //                       child: new Row(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Image.asset(
    //                             AssetStrings.info_users,
    //                             height: 20,
    //                             width: 20,
    //                           ),
    //                           Expanded(
    //                             child: new Container(
    //                               margin: new EdgeInsets.only(left: 7),
    //                               child: new Text(
    //                                   "You are adding this payment method to recieve the payment automatically paid by Favor owner ending a favor.",
    //                                   style: TextThemes.greyTextFieldNormalNew),
    //                             ),
    //                           )
    //                         ],
    //                       ),
    //                     )
    //                   : Container(),
    //               dataList?.length == 0 ? buildItemItemAddCard() : Container(),
    //               dataList?.length > 0
    //                   ? Container(
    //                       margin: new EdgeInsets.only(
    //                           left: 16, top: 12, bottom: 12),
    //                       child: new Text(
    //                         "Default Method",
    //                         style: new TextStyle(
    //                           color: Colors.black,
    //                           fontFamily: AssetStrings.circulerMedium,
    //                           fontSize: 18,
    //                         ),
    //                         textAlign: TextAlign.left,
    //                         overflow: TextOverflow.ellipsis,
    //                         maxLines: 1,
    //                       ),
    //                     )
    //                   : Container(),
    //               buildContestListSearch(),
    //               new Container(
    //                 height: 6,
    //               ),
    //               /*  buildItemRecentSearch(
    //                   2, "**** **** **** 8787", AssetStrings.addCard),*/
    //             ],
    //           ),
    //         ),
    //       ),
    //       Container(
    //         child: new Center(
    //           child: getHalfScreenLoader(
    //             status: provider.getLoading(),
    //             context: context,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Future<void> showDeletePaypal(int index, String id) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Remove PayPal Account?'),
            content: Text('Do you want to remove this account?'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  hitDeleteApi(index, id?.toString());
                },
              ),
            ],
          );
        },
      ) ??
      false;
  }

  // Widget getAppBarNew(BuildContext context) {
  //   return PreferredSize(
  //       preferredSize: Size.fromHeight(53.0),
  //       child: Container(
  //         color: Colors.white,
  //         child: Column(
  //           children: [
  //             new SizedBox(
  //               height: 20,
  //             ),
  //             Material(
  //               color: Colors.white,
  //               child: Container(
  //                 margin: new EdgeInsets.only(top: 15),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //
  //                   children: [
  //                     Container(
  //                       alignment: Alignment.topLeft,
  //                       margin: new EdgeInsets.only(left: 17.0, top: 10),
  //                       child: InkWell(
  //                         onTap: () {
  //                           Navigator.pop(context);
  //                         },
  //                         child: new Padding(
  //                           padding: const EdgeInsets.all(3.0),
  //                           child: new SvgPicture.asset(
  //                             AssetStrings.back,
  //                             width: 16.0,
  //                             height: 16.0,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: Container(
  //                         alignment: Alignment.center,
  //                         margin: new EdgeInsets.only(right: 25.0, top: 10),
  //                         width: getScreenSize(context: context).width,
  //                         child: new Text(
  //                           "Payment Method",
  //                           style: new TextStyle(
  //                               fontFamily: AssetStrings.circulerMedium,
  //                               fontSize: 19,
  //                               color: Colors.black),
  //                         ),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ));
  // }

  // buildContestListSearch() {
  //   return Container(
  //     color: Colors.white,
  //     child: new ListView.builder(
  //       padding: new EdgeInsets.all(0.0),
  //       shrinkWrap: true,
  //       physics: const NeverScrollableScrollPhysics(),
  //       itemBuilder: (BuildContext context, int index) {
  //         return buildItemRecentSearch(index, dataList[index]);
  //       },
  //       itemCount: dataList.length,
  //     ),
  //   );
  // }

  // void callbackDone() async {}

  @override
  bool get wantKeepAlive => true;

  // Widget buildItemItemAddCard() {
  //   return InkWell(
  //     onTap: () {
  //       firebaseProvider.changeScreen(Material(child: new AddPaymentMethod()));
  //     },
  //     child: Container(
  //       color: Colors.white,
  //       padding:
  //           new EdgeInsets.only(left: 16.0, right: 16.0, top: 15, bottom: 15),
  //       child: Container(
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             new Container(
  //               width: 43,
  //               height: 43,
  //               padding: new EdgeInsets.all(12),
  //               decoration: new BoxDecoration(
  //                   color: Color.fromRGBO(221, 242, 255, 1),
  //                   shape: BoxShape.circle),
  //               child: new Image.asset(AssetStrings.addPayment),
  //             ),
  //             new SizedBox(
  //               width: 12,
  //             ),
  //             Expanded(
  //               child: Container(
  //                 child: new Text(
  //                   "Add Payment Method",
  //                   style: new TextStyle(
  //                     color: AppColors.colorDarkCyan,
  //                     fontFamily: AssetStrings.circulerMedium,
  //                     fontSize: 16,
  //                   ),
  //                   textAlign: TextAlign.left,
  //                   overflow: TextOverflow.ellipsis,
  //                   maxLines: 1,
  //                 ),
  //               ),
  //             ),
  //             new SizedBox(
  //               width: 8,
  //             ),
  //             Container(
  //               margin: new EdgeInsets.only(left: 7.0),
  //               child: new Icon(
  //                 Icons.arrow_forward_ios,
  //                 size: 12,
  //                 color: Color.fromRGBO(183, 183, 183, 1),
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget buildItemRecentSearch(int index, Data data) {
  //   return InkWell(
  //     onTap: () {},
  //     child: Container(
  //       color: Colors.white,
  //       padding:
  //           new EdgeInsets.only(left: 16.0, right: 16.0, top: 15, bottom: 15),
  //       child: Container(
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             new Container(
  //               width: 43,
  //               height: 43,
  //               padding: new EdgeInsets.all(9),
  //               decoration: new BoxDecoration(
  //                   color: Color.fromRGBO(238, 238, 238, 1),
  //                   shape: BoxShape.circle),
  //               child: new Image.asset(
  //                 AssetStrings.addPaypal,
  //                 width: 18,
  //                 height: 18,
  //               ),
  //             ),
  //             new SizedBox(
  //               width: 12,
  //             ),
  //             Expanded(
  //               child: Container(
  //                 child: new Text(
  //                   data?.paypalId?.toString() ?? "",
  //                   style: new TextStyle(
  //                     color: Colors.black,
  //                     fontFamily: AssetStrings.circulerMedium,
  //                     fontSize: 16,
  //                   ),
  //                   textAlign: TextAlign.left,
  //                   overflow: TextOverflow.ellipsis,
  //                   maxLines: 1,
  //                 ),
  //               ),
  //             ),
  //             new SizedBox(
  //               width: 8,
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 showDeletePaypal(index, data?.id?.toString());
  //               },
  //               child: Container(
  //                 padding:
  //                     new EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
  //                 decoration: new BoxDecoration(
  //                     color: Color.fromRGBO(255, 237, 237, 1),
  //                     borderRadius: new BorderRadius.circular(2)),
  //                 child: new Container(
  //                   margin: new EdgeInsets.only(left: 6),
  //                   child: new Text(
  //                     "Remove",
  //                     style: new TextStyle(
  //                         fontSize: 16,
  //                         color: Color.fromRGBO(255, 107, 102, 1),
  //                         fontFamily: AssetStrings.circulerMedium),
  //                   ),
  //                 ),
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _background() {
    return Column(
      children: [
        Container(
          color: Color(0xFF23137D),
          padding: EdgeInsets.fromLTRB(40, 40, 40, 70),
          height: MediaQuery.of(context).size.height/2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/png/payment_card.png', height: 114),
              SizedBox(height: 36),
              Text(
                "Get Instant Payment",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AssetStrings.circulerMedium,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "You need to add paypal to receive the payment paid by the post owner",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD5D5D5),
                  fontFamily: AssetStrings.circulerNormal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Container(color: Colors.transparent)),
      ],
    );
  }

  Widget _backButton() {
    return Positioned(
      top: 8,
      left: 4,
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget _body() {
    // Card Height = 330
    // Card head = 70
    Size _size = MediaQuery.of(context).size;
    double _keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    double _visibleHeight = _size.height - _keyBoardHeight;
    double _externalContainerHeight = 330.0 + 40.0;
    if (_keyBoardHeight == 0) {
      _externalContainerHeight += (_size.height/2 - 70);
    } else {
      _externalContainerHeight = _visibleHeight;
    }

    return SingleChildScrollView(
      child: Container(
        color: Colors.transparent,
        height: _externalContainerHeight,
        padding: EdgeInsets.only(bottom: 25.0, top: (_externalContainerHeight - 330.0 - 40.0)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
          ),
          margin: EdgeInsets.symmetric(horizontal: 12.0),
          width: _size.width - 24.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _cardHeaderText(),
              _cardSubHeaderText((dataList?.length == 0) ? "We’ll keep your payment details safe" : "You’ll receive all payments in this account"),
              Container(color: Color(0xFFD8D8D8), height: 1, width: double.maxFinite),
              SizedBox(height: 24.0),
              if (dataList?.length == 0) _inputField(_emailController1),
              if (dataList?.length == 0) SizedBox(height: 16.0),
              if (dataList?.length == 0) _inputField(_emailController2),
              if ((dataList?.length ?? 0) > 0) _emailBox(),
              SizedBox(height: 27.0),
              Container(
                child: getSetupButtonColor(
                  dataList.length == 0
                      ? (){
                        if(_isButtonActive) _addPaypal();
                      }
                      : () {
                        showDeletePaypal(0, dataList.first.id.toString());
                      },
                  dataList?.length  == 0 ? "Add PayPal" : "Remove",
                  20,
                  newColor: dataList?.length  == 0
                      ? (_isButtonActive ? AppColors.kAppBlue : AppColors.grayDark)
                      : AppColors.orange,
                ),
              ),
              SizedBox(height: 26.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardHeaderText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        "Setup PayPal",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontFamily: AssetStrings.circulerBoldStyle,
        ),
      ),
    );
  }

  Widget _cardSubHeaderText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFF72757A),
          fontSize: 16,
          fontFamily: AssetStrings.circulerNormal,
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE7E7E7)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE7E7E7)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE7E7E7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE7E7E7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE7E7E7)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE7E7E7)),
          ),
          hintText: 'Enter a search term',
          hintStyle: TextStyle(
            fontFamily: AssetStrings.circulerNormal,
            fontSize: 16,
            color: Color(0xEEB7B7B7),
          ),
        ),
        onChanged: (value) {
          if(_emailController1.text.trim().length > 0 && _emailController2.text.trim().length > 0 && _emailController1.text.trim() == _emailController2.text.trim()) {
            _isButtonActive = true;
          } else {
            _isButtonActive = false;
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _emailBox() {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 20.0),
      padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        dataList.first.paypalId,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: AssetStrings.circulerNormal,
        ),
      ),
    );
  }
}
