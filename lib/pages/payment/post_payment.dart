import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvor/filter/data_payment.dart';
import 'package:payvor/model/promotion/promotion_response.dart';
import 'package:payvor/pages/payment/payment_dialog.dart';
import 'package:payvor/pages/post_details/cardformatter.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/ReusableWidgets.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:flutter_svg/svg.dart';

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
    var data1 = DataPromotion(
        id: 1,
        type: "Bese value",
        title: "first title",
        validity: "5 days",
        createdAt: "",
        updatedAt: "",
        isSelect: false);
    var data2 = DataPromotion(
        id: 1,
        type: "Bese value",
        title: "first title",
        validity: "5 days",
        createdAt: "",
        updatedAt: "",
        isSelect: false);
    var data3 = DataPromotion(
        id: 1,
        type: "Bese value",
        title: "first title",
        validity: "5 days",
        createdAt: "",
        updatedAt: "",
        isSelect: false);

    list.add(data1);
    list.add(data2);
    list.add(data3);

    /*   if(widget.data!=null){

       list.addAll(widget.data.data);
     }*/

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
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height - 50,
          child: ClipRRect(
            // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
            borderRadius: new BorderRadius.circular(10.0),
            child: Form(
              key: _fieldKey,
              child: Expanded(
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
                            fontFamily: AssetStrings.circulerMedium,
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
        margin: new EdgeInsets.only(top: 15, left: 24, right: 24),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(10.0),
            border: new Border.all(color: Color.fromRGBO(227, 227, 227, 1)),
            color: payment.isSelect ? AppColors.bluePrimary : Colors.white),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              backgroundColor: payment.isSelect
                  ? AppColors.colorDarkCyan
                  : Color.fromRGBO(227, 227, 227, 1),
              radius: 13,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.check,
                  size: 17,
                ),
                color: Colors.white,
                onPressed: () {},
              ),
            ),
            new Container(
              margin: new EdgeInsets.only(
                top: 9,
              ),
              alignment: Alignment.center,
              child: new Text(
                payment.price ?? "",
                style: new TextStyle(
                    fontFamily: AssetStrings.circulerMedium,
                    fontSize: 20,
                    color: payment.isSelect ? Colors.white : Colors.black),
              ),
            ),
            new Container(
              width: 80,
              margin: new EdgeInsets.only(
                top: 9,
              ),
              alignment: Alignment.center,
              child: new Text(
                payment.validity ?? "",
                style: new TextStyle(
                    fontFamily: AssetStrings.circulerNormal,
                    fontSize: 14,
                    color: payment.isSelect
                        ? Color.fromRGBO(255, 255, 255, 1)
                        : Color.fromRGBO(103, 99, 99, 1)),
              ),
            ),
            payment.isSelect
                ? new Container(
                    margin: new EdgeInsets.only(
                      top: 9,
                    ),
                    width: 83,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                        color: Color.fromRGBO(255, 107, 102, 1),
                        borderRadius: new BorderRadius.circular(15.0)),
                    child: new Text(
                      payment?.type ?? "",
                      style: new TextStyle(
                          fontFamily: AssetStrings.circulerNormal,
                          fontSize: 12,
                          color: Colors.white),
                    ),
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

  Future<bool> callback() async {
    Navigator.pop(context);
    widget.voidcallback(1);
  }

  void showInSnackBar(String value) {
    //  ;
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
