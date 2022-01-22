import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/model/add_receiver/add_receiver_response.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/get_account/get_acccount_response.dart';
import 'package:payvor/model/rating_list/rating_list.dart';
import 'package:payvor/pages/privacypolicy/webview_page.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class AddBankDetails extends StatefulWidget {
  @override
  _AddBankDetailsScreenState createState() => _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetails> {
  TextEditingController _AccountNameController = new TextEditingController();
  TextEditingController _AccountNumberController = new TextEditingController();
  TextEditingController _AccountCountryController = new TextEditingController();
  TextEditingController _AccountRoutingNumberController =
      new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKeys = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _fieldKey = new GlobalKey<FormState>();

  FocusNode _AccountNameField = new FocusNode();
  FocusNode _AccountNumberField = new FocusNode();
  FocusNode _AccountCountryField = new FocusNode();
  FocusNode _AccountRoutingNumberField = new FocusNode();

  AuthProvider provider;
  String _appBarTitle = "Add Bank Details";
  bool _isBankAdded = false;

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

  @override
  void initState() {
    // StripePayment.setOptions(StripeOptions(
    //     publishableKey:
    //         "pk_test_51IGZpGBWL8vL5RdKb9vByUN7q9V0nv46coA9Ngo7sceVBBIlJM9SFtZ0nPv1VW3XhSoyiecsrcy0u7uS7JDQ4v2500Heb148HL",
    //     merchantId: "Test",
    //     androidPayMode: 'test'));

    Timer(Duration(milliseconds: 500), () {
      _hitBankDetailApi();
    });

    super.initState();
  }

  Widget getTextField(
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      TextInputType textInputType,
      String svgPicture,
      {bool obsectextType,
      bool isEnabled = true}) {
    return Container(
      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
      height: Constants.textFieldHeight,
      child: new TextField(
        enabled: isEnabled,
        controller: controller,
        keyboardType: textInputType,
        style: TextThemes.blackTextFieldNormal,
        focusNode: focusNodeCurrent,
        onSubmitted: (String value) {
          if (focusNodeCurrent == _AccountCountryField) {
            _AccountCountryField.unfocus();
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
          contentPadding: new EdgeInsets.only(top: 10.0, left: 15),
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
    // var screensize = MediaQuery.of(context).size;
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
        appBar: AppBarwithTitle(context, _appBarTitle),
        backgroundColor: AppColors.whiteGray,
        key: _scaffoldKeys,
        body: _body());
  }

  Widget _body() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          _inputForm(),
          new Center(
              child: getHalfScreenLoader(
            status: provider?.getLoading(),
            context: context,
          )),
        ],
      ),
    );
  }

  // Widget _getAccountNumberView() {
  //   return Container(
  //     margin: const EdgeInsets.only(left: 20.0, right: 20.0),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Icons.favorite,
  //           color: Colors.pink,
  //           size: 24.0,
  //           semanticLabel: 'Text to announce in accessibility modes',
  //         ),
  //         new SizedBox(
  //           width: 24,
  //         ),
  //         Expanded(
  //           child: Container(
  //             child: new Text(
  //               "XXXXXXXXX$_acNo",
  //               style: new TextStyle(
  //                 color: Colors.black,
  //                 fontFamily: AssetStrings.circulerMedium,
  //                 fontSize: 16,
  //               ),
  //               textAlign: TextAlign.left,
  //               overflow: TextOverflow.ellipsis,
  //               maxLines: 1,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _inputForm() {
    return Form(
      key: _fieldKey,
      child: Container(
        color: Colors.white,
        // width: screensize.width,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            space(),
            getTextField(
                "Account Name",
                _AccountNameController,
                _AccountNameField,
                _AccountNumberField,
                TextInputType.text,
                AssetStrings.fullname,
                obsectextType: false,
                isEnabled: !_isBankAdded),
            new SizedBox(
              height: 18.0,
            ),
            getTextField(
                "Account Number",
                _AccountNumberController,
                _AccountNumberField,
                _AccountRoutingNumberField,
                TextInputType.name,
                AssetStrings.emailPng,
                obsectextType: false,
                isEnabled: !_isBankAdded),
            new SizedBox(
              height: 18.0,
            ),
            getTextField(
                "Country Code",
                _AccountCountryController,
                _AccountCountryField,
                _AccountCountryField,
                TextInputType.text,
                AssetStrings.passPng,
                obsectextType: false,
                isEnabled: !_isBankAdded),
            new SizedBox(
              height: 18.0,
            ),
            space(),
            new SizedBox(
              height: 27.0,
            ),
            _isBankAdded
                ? Container()
                : Container(
                    child: getSetupButtonNew(callback, "Save Account", 20)),
          ],
        ),
      ),
    );
  }

  _hitBankDetailApi() async {
    provider.setLoading();
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

    var response = await provider.getAccountInfo(context);

    if (response is GetAccountResponse) {
      if (response.customer.individual.verification.status.toLowerCase() !=
          "verified") {
        awesomeErrorDialog(
            "Account not verified. Please add your bank detail and verify",
            context);
      } else {
        if (response.customer.externalAccounts.data.isNotEmpty) {
          var bankInfo = response.customer.externalAccounts.data.first;
          _AccountNameController.text = bankInfo.accountHolderName;
          _AccountNumberController.text = "XXXXXXX${bankInfo.last4}";
          _AccountCountryController.text = bankInfo.country;
          _isBankAdded = true;
          _appBarTitle = "Added Bank Details";
        }
      }
      // print(response);
      // print(response.customer.individual.verification.toJson());
    } else {
      APIError apiError = response;
      print(apiError.error);
      showInSnackBar(apiError.error);
    }
  }

  addAccountApi() async {
    provider.setLoading();
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

    BankAccountRequest request = BankAccountRequest(
        account_holder_name: _AccountNameController.text,
        account_number: _AccountNumberController.text,
        country: _AccountCountryController.text);

    var response = await provider.addReceiver(context, request);
    if (response is AddReceiverResponse) {
      _moveToVerifyScreen(response.data.url);
    } else {
      APIError apiError = response;
      print(apiError.error);
      showInSnackBar(apiError.error);
    }
  }

  _moveToVerifyScreen(String url) async {
    var data = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new WebViewPages(
                  heading: "",
                  url: url,
                )));
    if (data != null) {
      _hitBankDetailApi();
      awesomeSuccessDialog("Account verified successfully", context);
    }
  }

  void setError(dynamic error) {
    provider.hideLoader();
    showInSnackBar(error.toString());
  }

  void callback() {
    var name = _AccountNameController.text;
    var number = _AccountNumberController.text;
    var country = _AccountCountryController.text;

    if (name.isEmpty || name.trim().length == 0) {
      showInSnackBar("Please enter account holder name");
      return;
    } else if (number.isEmpty || number.trim().length == 0) {
      showInSnackBar("Please enter account number");
      return;
    } else if (country.isEmpty || country.length == 0) {
      showInSnackBar("Please enter counrty code");
      return;
    }

    addAccountApi();
  }
}
