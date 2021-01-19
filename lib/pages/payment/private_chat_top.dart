import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';

class PrivateChatTopWidget extends StatelessWidget {
  final String userName;
  final String profilePic;
  final String desc;
  final bool isOnline;

  PrivateChatTopWidget({
    @required this.userName,
    @required this.profilePic,
    @required this.desc,
    @required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    //print("video thumbnail $videoThumbNail");
    return Container(
      color: AppColors.kWhite,
      margin: new EdgeInsets.only(top: 10.0, left: 15.0, right: 15),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: IntrinsicHeight(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          new Container(
                              width: 35.0,
                              height: 35.0,
                              margin:
                                  new EdgeInsets.only(right: 0, bottom: 1.0),
                              decoration: new BoxDecoration(
                                border: new Border.all(
                                    color: Colors.transparent, width: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: getCachedNetworkImage(
                                    url: profilePic ?? "", fit: BoxFit.cover),
                              )),
                          Positioned(
                            bottom: 0.0,
                            right: 0.0,
                            child: new Container(
                              width: 12.0,
                              height: 12.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isOnline ?? false)
                                      ? Colors.greenAccent
                                      : Colors.grey,
                                  border: new Border.all(
                                      color: Colors.white, width: 1.2)),
                            ),
                          ),
                        ],
                      ),
                      new SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          padding: new EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                userName ?? "",
                                style: TextThemes.blackCirculerMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              new SizedBox(
                                height: 5.0,
                              ),
                              Expanded(
                                child: Container(
                                  padding: new EdgeInsets.only(right: 35.0),
                                  child: new Text(
                                    desc ?? "",
                                    style: new TextStyle(
                                        color: Colors.black54,
                                        fontFamily: AssetStrings.circulerNormal,
                                        fontSize: 12.0),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
//                      new Container(
//                        height: double.infinity,
//                        child: new Icon(Icons.person_add, size: 22.0),
//                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
