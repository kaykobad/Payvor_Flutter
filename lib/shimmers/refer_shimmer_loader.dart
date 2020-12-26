import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerRefer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                child: ListView.builder(
              itemBuilder: (_, index) => ShimmerMyOrderItem(),
              itemCount: 10,
            )),
          ],
        ),
      ),
    );
  }
}

class ShimmerMyOrderItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200],
        highlightColor: Colors.grey[400],
        child: Container(
          child: Column(
            children: <Widget>[

              buildItem(),
              Opacity(
                opacity: 1.0,
                child: new Container(
                  height: 1.0,
                  margin:
                  new EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0),
                  color: AppColors.dividerColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildItem() {
  return Container(
    margin: new EdgeInsets.only(left: 16.0, right: 16.0),
    child: Row(
      children: <Widget>[
        new Container(
          width: 40.0,
          height: 40.0,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
        Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  color: Colors.white,
                  margin: new EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      new Text(
                        "",
                        style: TextThemes.blackCirculerMedium,
                      ),
                      new SizedBox(
                        width: 8,
                      ),
                      new Image.asset(
                        "",
                        width: 16,
                        height: 16,
                      ),
                    ],
                  )),
              Container(
                color: Colors.white,
                margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 4),
                child: Row(
                  children: [
                    new Image.asset(
                      "",
                      width: 11,
                      height: 14,
                    ),
                    new SizedBox(
                      width: 6,
                    ),
                    Expanded(
                        child: new Text(
                      "",
                      style: TextThemes.greyDarkTextHomeLocation,
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.white,
              width: 50,
              child: new Text(
                "",
                style: TextThemes.blackDarkHeaderSub,
              ),
            )),
      ],
    ),
  );
}
