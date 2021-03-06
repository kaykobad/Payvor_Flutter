import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/model/promotion/promotion_response.dart';
import 'package:payvor/paypalpayment/webviewpayment.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';

class PaymentDialogPost extends StatefulWidget {
  final PropmoteDataResponse data;
  ValueSetter<int> voidcallback;

  PaymentDialogPost({this.data, this.voidcallback});

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialogPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GlobalKey<FormState> _fieldKey = new GlobalKey<FormState>();

  List<DataPromotion> list = List<DataPromotion>();

  @override
  void initState() {
    if (widget.data != null) {
      list.addAll(widget.data.data);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Container(
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26.0),
                topRight: Radius.circular(26.0)),
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height - 50,
          child: ClipRRect(
            // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
            borderRadius: new BorderRadius.circular(10.0),
            child: Form(
              key: _fieldKey,
              child: new ListView(
                children: [
                  Container(
                    margin: new EdgeInsets.only(top: 32, left: 24),
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
                  new Container(
                    margin: new EdgeInsets.only(top: 9, left: 24, right: 24),
                    alignment: Alignment.center,
                    child: new Text(
                      "Promote your Post",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerBoldStyle,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 5, left: 24, right: 24),
                    alignment: Alignment.center,
                    child: new Text(
                      "Buy a Package to promote your post to be appeared higher up in the feed",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        height: 1.5,
                        color: Color.fromRGBO(103, 99, 99, 1),
                      ),
                    ),
                  ),
                  Container(
                    height: 280,
                    margin: new EdgeInsets.only(top: 25),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: getData(list[index]),
                      ),
                      itemCount: list.length,
                    ),
                  ),
                  new SizedBox(
                    height: 24.0,
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 24, left: 24, right: 24),
                    child: getSetupButtonNew(callback, "Try Now", 0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  new Container(
                    height: 24,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget getData(DataPromotion payment) {
    return InkWell(
      onTap: () {
        for (int i = 0; i < list.length; i++) {
          list[i].isSelect = false;
        }
        payment.isSelect = true;
        setState(() {});
      },
      child: Container(
        height: 78,
        margin: new EdgeInsets.only(top: 10, left: 24, right: 24),
        padding: new EdgeInsets.only(left: 16, right: 16),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(10.0),
            border: new Border.all(color: Color.fromRGBO(227, 227, 227, 1)),
            color: payment?.isSelect ?? false
                ? AppColors.bluePrimary
                : Colors.white),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: payment?.isSelect ?? false
                    ? Colors.white
                    : Colors.transparent,
              ),
              child: Image.asset(
                AssetStrings.checkTick,
                width: 21,
                height: 21,
                color: payment?.isSelect ?? false
                    ? AppColors.colorDarkCyan
                    : Color.fromRGBO(103, 99, 99, 0.3),
              ),
            ),
            new Container(
              alignment: Alignment.center,
              child: new Text(
                "??? ${payment?.price ?? "0"}",
                style: new TextStyle(
                    fontFamily: AssetStrings.circulerMedium,
                    fontSize: 20,
                    color: payment.isSelect ?? false
                        ? Colors.white
                        : Colors.black),
              ),
            ),
            new Container(
              width: 110,

              alignment: Alignment.center,
              child: new Text(
                payment?.title ?? "",
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                    fontFamily: AssetStrings.circulerNormal,
                    fontSize: 16,
                    color: payment?.isSelect ?? false
                        ? Color.fromRGBO(255, 255, 255, 1)
                        : Color.fromRGBO(103, 99, 99, 1)),
              ),
            ),
            payment?.isSelect ?? false
                ? Wrap(
              children: [
                new Container(

                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      color: Color.fromRGBO(255, 107, 102, 1),
                      borderRadius: new BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.only(left:10.0,right: 10,top: 5,bottom: 5),
                    child: new Text(
                      payment?.type?.toUpperCase() ?? "",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerNormal,
                          fontSize: 11,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
                : new Container(
                margin: new EdgeInsets.only(
                      top: 9,
                    ),
                    width: 83,
                    height: 30)
          ],
        ),
      ),
    );
  }

  Future<bool> callbackSuccessFailed() async {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<bool> callback() async {
    var isSelect = false;
    var itemId = "";

    for (var data in list) {
      if (data?.isSelect != null && data?.isSelect) {
        isSelect = true;
        itemId = data?.id?.toString();
        break;
      }
    }

    if (!isSelect) {
      showInSnackBar("Please select a option");

      return false;
    }

    var getdata = await Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return new WebviewPayment(
          type: "promotion",
          itemId: itemId,
        );
      }),
    );

    print(getdata);

    if (getdata is bool) {
      if (getData != null && getdata == true) {
        showBottomSheet("Successful!", "Payment Successful!.", 1);
        /*Navigator.pop(context);
        widget.voidcallback(1);*/
      } else {
        showBottomSheet("Failed!", "Payment Failed!.", 0);
      }
    }
  }

  void showBottomSheet(String text, String desc, int type) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86.0,
                    height: 86.0,
                    margin: new EdgeInsets.only(top: 38),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: type == 1
                          ? AppColors.greenDark
                          : Color.fromRGBO(255, 107, 102, 1.0),
                      shape: BoxShape.circle,
                    ),
                    child: type == 1
                        ? new SvgPicture.asset(
                            AssetStrings.check,
                            width: 42.0,
                            height: 42.0,
                            color: Colors.white,
                          )
                        : new SvgPicture.asset(
                            AssetStrings.cross,
                            width: 42.0,
                            height: 42.0,
                            color: Colors.white,
                          ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 40),
                    child: new Text(
                      text,
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerMedium,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 10),
                    child: new Text(
                      desc,
                      style: new TextStyle(
                        fontFamily: AssetStrings.circulerNormal,
                        fontSize: 16,
                        color: Color.fromRGBO(114, 117, 112, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: getSetupButtonNew(callbackSuccessFailed, "Ok", 0,
                        newColor: AppColors.colorDarkCyan),
                  ),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }

  void showInSnackBar(String value) {
    //  ;
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
