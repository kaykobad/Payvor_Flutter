import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/resources/class%20ResString.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerDetails extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ShimmerDetails> {
  var screenSize;

  @override
  void initState() {
    super.initState();
  }

  Widget buildItem() {
    return Container(
      padding:
          new EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenSize.width - 140,
                  height: 20,
                  color: Colors.white,
                ),
                new SizedBox(
                  height: 5,
                ),
                Container(
                  width: 140,
                  height: 20,
                  color: Colors.white,
                )
              ],
            ),
          ),
          new Container(
            width: 50,
            height: 20,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget getBottomText(String icon, String text, double size) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: new SvgPicture.asset(
                icon,
                width: size,
                height: size,
              ),
            ),
          ),
          new SizedBox(
            width: 20.0,
          ),
          Container(
            child: new Text(
              text,
              style: TextThemes.darkBlackMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemRating(int type, String first) {
    return Container(
      padding:
          new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
      color: Colors.white,
      margin: new EdgeInsets.only(top: 4),
      child: Row(
        children: <Widget>[
          new Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 107, 102, 0.17),
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: new SvgPicture.asset(
              type == 1 ? AssetStrings.shape : AssetStrings.referIcon,
              height: 18,
              width: 18,
            ),
          ),
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                  child: new Text(
                    first,
                    style: TextThemes.blackCirculerMedium,
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                  child: type == 1
                      ? Row(
                          children: [
                            new SvgPicture.asset(
                              AssetStrings.star,
                            ),
                            new SizedBox(
                              width: 3,
                            ),
                            Container(
                                child: new Text(
                              "",
                              style: TextThemes.greyTextFieldNormalNw,
                            )),
                            Container(
                              width: 3,
                              height: 3,
                              margin: new EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.darkgrey,
                              ),
                            ),
                            Container(
                                child: new Text(
                              "",
                              style: TextThemes.greyTextFieldNormalNw,
                            )),
                          ],
                        )
                      : Container(
                          child: new Text(
                          "",
                          style: TextThemes.greyTextFieldNormalNw,
                        )),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color.fromRGBO(183, 183, 183, 1.0),
                size: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getRowsPayment(String firstText, String amount, double tops) {
    return new Container(
      margin: new EdgeInsets.only(top: 8),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Container(
            margin: new EdgeInsets.only(left: 17.0, right: 17.0),
            color: Colors.white,
            width: 130,
            height: 20,
          ),
          new Container(
            margin: new EdgeInsets.only(left: 17.0, right: 17.0),
            color: Colors.white,
            width: 80,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget buildItemUser() {
    return Container(
      padding:
          new EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
      margin: new EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 50.0,
            height: 50.0,
            alignment: Alignment.center,
            decoration:
                new BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          Expanded(
            child: new Column(
              children: [
                Container(
                    margin: new EdgeInsets.only(left: 10.0, right: 50.0),
                    color: Colors.white,
                    width: double.infinity,
                    height: 20),
                Container(
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 50.0, top: 3),
                    color: Colors.white,
                    width: double.infinity,
                    height: 20),
              ],
            ),
          ),
          Container(
              margin: new EdgeInsets.only(right: 10.0),
              color: Colors.white,
              width: 30,
              height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: Colors.grey[200],
        highlightColor: Colors.grey[400],
        child: Stack(
          children: <Widget>[
            new Container(
                height: screenSize.height,
                child: SingleChildScrollView(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        height: 214,
                        width: double.infinity,
                        child: ClipRRect(
                          // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                          borderRadius: new BorderRadius.circular(0.0),
                        ),
                      ),
                      buildItem(),
                      Opacity(
                        opacity: 1,
                        child: new Container(
                          height: 1.0,
                          margin: new EdgeInsets.only(left: 17.0, right: 17.0),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: new EdgeInsets.only(
                            left: 17.0, right: 17.0, top: 20),
                        color: Colors.white,
                        width: 180,
                        height: 20,
                      ),
                      Container(
                        child: Container(
                          margin: new EdgeInsets.only(
                              left: 17.0, right: 17.0, top: 10),
                          color: Colors.white,
                          width: double.infinity,
                          height: 50,
                        ),
                      ),
                      Opacity(
                        opacity: 1,
                        child: new Container(
                          height: 4.0,
                          margin: new EdgeInsets.only(top: 17.0),
                          color: Colors.white,
                        ),
                      ),
                      buildItemUser(),
                      Opacity(
                        opacity: 1,
                        child: new Container(
                          height: 4.0,
                          margin: new EdgeInsets.only(top: 5.0),
                          color: Colors.white,
                        ),
                      ),
                      buildItemUser(),
                      Opacity(
                        opacity: 1,
                        child: new Container(
                          height: 4.0,
                          margin: new EdgeInsets.only(top: 5.0),
                          color: Colors.white,
                        ),
                      ),
                      buildItemUser(),
                      Opacity(
                        opacity: 1,
                        child: new Container(
                          height: 4.0,
                          margin: new EdgeInsets.only(top: 5.0),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        margin: new EdgeInsets.only(
                            left: 17.0, right: 17.0, top: 20),
                        width: screenSize.width / 2,
                        height: 20,
                      ),
                      new Container(
                        height: 15,
                      ),
                      getRowsPayment(
                          ResString().get('job_payment'), "€50", 23.0),
                      getRowsPayment(
                          ResString().get('payvor_service_fee'), "€50", 9.0),
                      new Container(
                        height: 13,
                      ),
                      Opacity(
                        opacity: 1,
                        child: new Container(
                          height: 1.0,
                          margin: new EdgeInsets.only(left: 17.0, right: 17.0),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        child: Container(
                          margin: new EdgeInsets.only(
                              left: 17.0, right: 17.0, top: 10),
                          width: double.infinity,
                          height: 10,
                        ),
                      ),
                      getRowsPayment(
                          ResString().get('payvor_service_fee'), "€50", 9.0),
                      new SizedBox(
                        height: 50.0,
                      ),
                    ],
                  ),
                )),
            Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  margin: new EdgeInsets.only(top: 35, left: 16, right: 5),
                  child: new Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Container(
                          width: 30.0,
                          height: 30.0,
                          color: Colors.white,
                        ),
                        new Container(
                          width: 30.0,
                          height: 30.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )),

            /* Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                   height: 100,
                  color: Colors.white,
                )),
*/
          ],
        ),
      ),
    );
  }
}
