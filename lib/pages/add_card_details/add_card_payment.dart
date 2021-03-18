import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/add_paypal/add_paypal_request.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/pages/post_details/cardformatter.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/ValidatorFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';

class AddCardDetails extends StatefulWidget {
  ValueSetter<int> voidcallback;
  int type;

  AddCardDetails({this.voidcallback, this.type});

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<AddCardDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GlobalKey<FormState> _fieldKey = new GlobalKey<FormState>();
 // PaymentMethod _paymentMethod;

  TextEditingController _AccountController = new TextEditingController();
  TextEditingController _NameController = new TextEditingController();
  TextEditingController _CvvController = new TextEditingController();
  TextEditingController _MonthController = new TextEditingController();

  FocusNode _AccountField = new FocusNode();
  FocusNode _NameField = new FocusNode();
  FocusNode _CvvField = new FocusNode();
  FocusNode _MonthField = new FocusNode();

  var mCardEmpty = false;
  var mCvvEmpty = false;
  var mMonthEmpty = false;
  var mNameEmpty = false;

  String textAccount = "";
  String textName = "";
  String textMonth = "";
  String textCvv = "";
 // Token _paymentToken;
  AuthProvider provider;

  List<TextInputFormatter> listCardNumber = new List<TextInputFormatter>();
  List<TextInputFormatter> listExpDate = new List<TextInputFormatter>();
  List<TextInputFormatter> listcvv = new List<TextInputFormatter>();
  List<TextInputFormatter> listNormalText = new List<TextInputFormatter>();

  String validatorCard(String value) {
    if (value.isEmpty) {
      return 'Please enter your card number';
    }
  }

  String validatorCvv(String value) {
    if (value.isEmpty) {
      return 'Please enter your cvv';
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    /*  StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_aSaULNS8cJU6Tvo20VAXy6rp",
        merchantId: "Test",
        androidPayMode: 'test'));*/

    listCardNumber.addAll([
      WhitelistingTextInputFormatter.digitsOnly,
      new LengthLimitingTextInputFormatter(16),
      new CardNumberInputFormatter()
    ]);

    listExpDate.addAll([
      WhitelistingTextInputFormatter.digitsOnly,
      new LengthLimitingTextInputFormatter(4),
      new CardMonthInputFormatter()
    ]);
    listcvv.addAll([
      WhitelistingTextInputFormatter.digitsOnly,
      new LengthLimitingTextInputFormatter(4)
    ]);

    super.initState();
  }


  Widget getAppBarNew(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(53.0),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              new SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.white,
                child: Container(
                  margin: new EdgeInsets.only(top: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: new EdgeInsets.only(left: 17.0, top: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: new Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: new SvgPicture.asset(
                              AssetStrings.back,
                              width: 16.0,
                              height: 16.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: new EdgeInsets.only(right: 25.0, top: 10),
                          width: getScreenSize(context: context).width,
                          child: new Text(
                            "Payment Method",
                            style: new TextStyle(
                                fontFamily: AssetStrings.circulerMedium,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: getAppBarNew(context),
      backgroundColor: Colors.white,
      body: Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26.0),
                topRight: Radius.circular(26.0)),
          ),
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: ClipRRect(
            // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
            borderRadius: new BorderRadius.circular(10.0),
            child: Stack(
              children: [
                Form(
                  key: _fieldKey,
                  child: new ListView(
                    children: [
                      /*Container(
                        margin: new EdgeInsets.only(top: 20, left: 16, right: 16),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: new Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: new SvgPicture.asset(
                                    AssetStrings.back,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: new Container(
                                alignment: Alignment.center,
                                child: new Text(
                                  "Card Details",
                                  style: new TextStyle(
                                      fontFamily: AssetStrings.circulerBoldStyle,
                                      fontSize: 20,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),*/
                      new Container(
                        height: 8.0,
                        color: AppColors.kAppScreenBackGround,
                      ),

                      /*    new Container(
                        margin: new EdgeInsets.only(top: 5),
                        alignment: Alignment.center,
                        child: new Text(
                          "Add a Card details here or Pay with Paypal",
                          style: new TextStyle(
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 16,
                            color: Color.fromRGBO(103, 99, 99, 1),
                          ),
                        ),
                      ),*/

                      new Container(
                        margin: new EdgeInsets.only(left: 16, top: 15),
                        child: new Text(
                          "Add Paypal Account",
                          style: TextThemes.darkBlackMedium,
                        ),
                      ),
                      new Container(
                        margin: new EdgeInsets.only(left: 16, top: 7),
                        child: Row(
                          children: [
                            new Image.asset(
                              AssetStrings.iconTick,
                              width: 18,
                              height: 22,
                            ),
                            new SizedBox(
                              width: 5,
                            ),
                            new Text(
                              "We’ll keep your payment details safe",
                              style: TextThemes.grayNormal,
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: 0.12,
                        child: new Container(
                          height: 1.0,
                          margin:
                              new EdgeInsets.only(top: 15, left: 16, right: 16),
                          color: AppColors.dividerColor,
                        ),
                      ),
                      new SizedBox(
                        height: 24.0,
                      ),
                      getTextField(
                          validatorCard,
                          "Enter Paypal Email",
                          _AccountController,
                          _AccountField,
                          _NameField,
                          0,
                          mCardEmpty,
                          listNormalText,
                          TextInputType.emailAddress),
                      mCardEmpty
                          ? new Container(
                              margin: new EdgeInsets.only(top: 6, left: 24),
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                textAccount,
                                style: new TextStyle(
                                  fontFamily: AssetStrings.circulerNormal,
                                  fontSize: 13,
                                  color: Color.fromRGBO(205, 107, 102, 1),
                                ),
                              ),
                            )
                          : Container(),
                      new SizedBox(
                        height: 16.0,
                      ),
                      /*     getTextField(
                          validatorCvv,
                          ResString().get('card_name'),
                          _NameController,
                          _NameField,
                          _MonthField,
                          0,
                          mNameEmpty,
                          listNormalText,
                          TextInputType.text),
                      mNameEmpty
                          ? new Container(
                        margin: new EdgeInsets.only(top: 6, left: 24),
                        alignment: Alignment.centerLeft,
                        child: new Text(
                          textName,
                          style: new TextStyle(
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 13,
                            color: Color.fromRGBO(205, 107, 102, 1),
                          ),
                        ),
                      )
                          : Container(),*/
                      /*  new Container(
                        height: 58,
                        margin: new EdgeInsets.only(right: 24, left: 24, top: 16),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: getTextField(
                                  validatorCvv,
                                  ResString().get('mm/yy'),
                                  _MonthController,
                                  _MonthField,
                                  _CvvField,
                                  1,
                                  mMonthEmpty,
                                  listExpDate,
                                  TextInputType.number),
                            ),
                            new SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: getTextField(
                                  validatorCvv,
                                  ResString().get('cvv'),
                                  _CvvController,
                                  _CvvField,
                                  _CvvField,
                                  1,
                                  mCvvEmpty,
                                  listcvv,
                                  TextInputType.number),
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: mMonthEmpty
                                  ? new Container(
                                margin:
                                new EdgeInsets.only(top: 16, left: 24),
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                  textMonth,
                                  style: new TextStyle(
                                    fontFamily: AssetStrings.circulerNormal,
                                    fontSize: 13,
                                    color: Color.fromRGBO(205, 107, 102, 1),
                                  ),
                                ),
                              )
                                  : Container(),
                            ),
                            new SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: mCvvEmpty
                                  ? new Container(
                                margin:
                                new EdgeInsets.only(top: 16, right: 24),
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                  textCvv,
                                  style: new TextStyle(
                                    fontFamily: AssetStrings.circulerNormal,
                                    fontSize: 13,
                                    color: Color.fromRGBO(205, 107, 102, 1),
                                  ),
                                ),
                              )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),*/
                      Container(
                        margin:
                            new EdgeInsets.only(top: 120, left: 16, right: 16),
                        child: getSetupButtonNew(callback, "Add Paypal", 0,
                            newColor: AppColors.colorDarkCyan),
                      ),
                      Container(
                        height: 26,
                      )
                    ],
                  ),
                ),
                Container(
                  child: new Center(
                    child: getHalfScreenLoader(
                      status: provider.getLoading(),
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
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

    var infoData = jsonDecode(MemoryManagement.getUserInfo());
    var userinfo = LoginSignupResponse.fromJson(infoData);

    PayPalAddRequest forgotrequest = new PayPalAddRequest(
        paypal_id: _AccountController.text,
        user_id: userinfo?.user?.id?.toString());

    var response = await provider.addPaypalMethod(forgotrequest, context);

    if (response is ReportResponse) {
      provider.hideLoader();

      print("res $response");

      if (response != null && response.status.code == 200) {
        showInSnackBar("Payment method added successfully");
        MemoryManagement.setPaymentStatus(status: true);

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        setState(() {});
      }

      print(response);
      try {} catch (ex) {}
    } else {
      provider.hideLoader();
      APIError apiError = response;
      print(apiError.error);

      showInSnackBar(apiError.error);
    }
  }

  Widget getTextField(
      Function validators,
      String labelText,
      TextEditingController controller,
      FocusNode focusNodeCurrent,
      FocusNode focusNodeNext,
      int type,
      bool card,
      List<TextInputFormatter> inputFormateer,
      TextInputType textInputType) {
    return Container(
      margin: type == 0
          ? new EdgeInsets.only(left: 24.0, right: 24.0)
          : new EdgeInsets.only(left: 0),
      height: Constants.textFieldHeight,
      child: new TextFormField(
        controller: controller,
        keyboardType: textInputType,
        inputFormatters: inputFormateer,
        style: TextThemes.blackTextFieldNormal,
        focusNode: focusNodeCurrent,
        onFieldSubmitted: (String value) {
          if (focusNodeCurrent == _CvvField) {
            _CvvField.unfocus();
          } else {
            FocusScope.of(context).autofocus(focusNodeNext);
          }
        },
        decoration: new InputDecoration(
          enabledBorder: card
              ? new OutlineInputBorder(
              borderSide: new BorderSide(
                color: Colors.red.withOpacity(0.5),
              ),
              borderRadius: new BorderRadius.circular(8))
              : new OutlineInputBorder(
              borderSide: new BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
              borderRadius: new BorderRadius.circular(8)),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(
                color: card
                    ? Colors.red.withOpacity(0.5)
                    : AppColors.colorCyanPrimary,
              ),
              borderRadius: new BorderRadius.circular(8)),
          contentPadding: new EdgeInsets.only(top: 10.0, left: 17),
          suffixIcon: Container(
            width: 1.0,
          ),
          hintText: labelText,
          hintStyle: TextThemes.greyTextFieldHintNormal,
        ),
      ),
    );
  }

  Future<bool> callbackSuccess() async {
    print("success");
  }

  Future<bool> callback() async {
    var account = _AccountController.text;

    if (account.isEmpty || account.trim().length == 0) {
      mCardEmpty = true;
      textAccount = "Please enter paypal email ";
      setState(() {});
      return false;
    } else if (!isEmailFormatValid(account)) {
      mCardEmpty = true;
      textAccount = "Please enter a valid paypal email";
      setState(() {});
      return false;
    }

    mCardEmpty = false;
    setState(() {});

    hitAddApi();

    /*
    var name = _NameController.text;
    var month = _MonthController.text;
    var cvv = _CvvController.text;

    print(account
        .trim()
        .length);
    setState(() {
      if (account.isEmpty || account
          .trim()
          .length == 0) {
        mCardEmpty = true;
        textAccount = "Please enter card number ";
        return false;
      }
      if (account
          .trim()
          .length != 22) {
        mCardEmpty = true;
        textAccount = "Please enter valid card number ";
        return false;
      } else if (name.isEmpty || name.length == 0) {
        mCardEmpty = false;
        mNameEmpty = true;
        textName = "Please enter your name";
        return false;
      } else if (month.isEmpty || month.length == 0) {
        mCardEmpty = false;
        mNameEmpty = false;
        mMonthEmpty = true;
        textMonth = "Please enter expiry date";
        return false;
      } else if (cvv.isEmpty || cvv.length == 0) {
        mCardEmpty = false;
        mNameEmpty = false;
        mMonthEmpty = false;
        mCvvEmpty = true;

        textCvv = "Please enter cvv";

        return false;
      } else {
        mCardEmpty = false;
        mNameEmpty = false;
        mMonthEmpty = false;
        mCvvEmpty = false;

        var monthCard = 0;
        var yearCard = 0;

        var split = month.split("/");

        if (split?.length > 1) {
          try {
            monthCard = int.parse(split[0]);
            yearCard = int.parse(split[1]);
          } catch (e) {}
        } else {
          mCardEmpty = false;
          mNameEmpty = false;
          mMonthEmpty = true;
          mCvvEmpty = false;
          textMonth = "Please enter valid expiry date";
          return false;
        }

        final CreditCard testCard = CreditCard(
            number: account,
            expMonth: monthCard,
            expYear: yearCard,
            cvc: cvv,
            name: name);

        StripePayment.createTokenWithCard(
          testCard,
        ).then((token) {
          showInSnackBar(token?.tokenId);

          _paymentToken = token;
        }).catchError(setError);
*/
    /*  StripePayment.createPaymentMethod(
          PaymentMethodRequest(
            card: CreditCard(
              token: _paymentToken.tokenId,
            ),
          ),
        ).then((paymentMethod) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
          setState(() {
            _paymentMethod = paymentMethod;
          });
        }).catchError(setError);*/

    /*  Navigator.pop(context);

        widget.voidcallback(2);
*/
  }

  void setError(dynamic error) {
    showInSnackBar(error.toString());
  }

  void showInSnackBar(String value) {
    //  ;
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
