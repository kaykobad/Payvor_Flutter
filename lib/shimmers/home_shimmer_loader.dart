import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: ShimmerFavourItem(),
              ),
              itemCount: 4,
            )),
          ],
        ),
      ),
    );
  }
}

class ShimmerFavourItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200],
      highlightColor: Colors.grey[400],
      child: Container(

        child: Column(
          children: <Widget>[
            buildItem(),
            Opacity(
              opacity: 0.12,
              child: new Container(
                height: 1.0,
                margin: new EdgeInsets.only(
                    left: 17.0, right: 17.0, top: 16.0),
                color: AppColors.dividerColor,
              ),
            ),

            new Container(
              height: 147,
              width: double.infinity,
              color: Colors.white,
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 11.0),
              child: ClipRRect(
                // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),
                borderRadius: new BorderRadius.circular(10.0),
              ),
            ),

            Container(
                width: double.infinity,
                color: Colors.white,
                margin: new EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 7.0),
                alignment: Alignment.centerLeft,
                child: new Text(
                  "",
                  style: TextThemes.blackCirculerMediumHeight,
                )),
            Container(
              margin: new EdgeInsets.only(left: 16.0, right: 16.0, top: 7.0),
              width: double.infinity,
              color: Colors.white,
              child: Text(
                  ""
              ),
            ),


            new SizedBox(
              height: 15.0,
            )
          ],
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
          decoration: BoxDecoration(

              shape: BoxShape.circle,
              color: Colors.white
          ),
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
              width: 30,
              child: new Text(
                "",
                style: TextThemes.blackDarkHeaderSub,
              ),
            )),
      ],
    ),
  );
}