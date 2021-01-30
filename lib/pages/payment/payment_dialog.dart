import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/pages/post_details/cardformatter.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';

class PaymentDialog extends StatefulWidget {
  ValueSetter<int> voidcallback;

  PaymentDialog({this.voidcallback});

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GlobalKey<FormState> _fieldKey = new GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Container(
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26.0),
                topRight: Radius.circular(26.0)),
          ),
          height: MediaQuery.of(context).size.height,
          child: ClipRRect(
            // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
            borderRadius: new BorderRadius.circular(10.0),
            child: Form(
              key: _fieldKey,
              child: new ListView(
                children: [
                  Container(
                    margin: new EdgeInsets.only(top: 48, left: 24, right: 24),
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
                                AssetStrings.cross,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: new Container(
                            alignment: Alignment.center,
                            child: new Text(
                              "Payment Details",
                              style: new TextStyle(
                                  fontFamily: AssetStrings.circulerBoldStyle,
                                  fontSize: 20,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      margin: new EdgeInsets.only(top: 16),
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
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
                  new SizedBox(
                    height: 24.0,
                  ),
                  getTextField(
                      validatorCard,
                      ResString().get('card_number'),
                      _AccountController,
                      _AccountField,
                      _NameField,
                      0,
                      mCardEmpty,
                      listCardNumber,
                      TextInputType.number),
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
                  getTextField(
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
                      : Container(),
                  new Container(
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
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 24, left: 16, right: 16),
                    child: getSetupButtonNew(callback, "Pay Now", 0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  new Container(
                    height: 24,
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 24, left: 16, right: 16),
                    child: getSetupButtonNew(callback, "Pay with Paypal", 0,imagePath: AssetStrings.paypal),
                  ),
                  Container(
                    height: 26,
                  )
                ],
              ),
            ),
          )),
    );
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
                color: AppColors.colorCyanPrimary,
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
    var name = _NameController.text;
    var month = _MonthController.text;
    var cvv = _CvvController.text;

    print(account.trim().length);
    setState(() {
      if (account.isEmpty || account.trim().length == 0) {
        mCardEmpty = true;
        textAccount = "Please enter card number ";
        return false;
      }
      if (account.trim().length != 22) {
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
        Navigator.pop(context);

        widget.voidcallback(2);

        return true;
      }
    });
  }

  void showInSnackBar(String value) {
    //  ;
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
