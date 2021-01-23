import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';

class ChatBubbleRight extends StatelessWidget {
  final String message;
  final String userName;
  final String profilePic;
  final String time;

  ChatBubbleRight({
    @required this.message,
    @required this.userName,
    @required this.profilePic,
    @required this.time,
  });



  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20.0, top: 25),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    right: 50.0,
                    left: 3.0,
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    border: new Border.all(
                      color: Color.fromRGBO(151, 151, 151, 0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Linkify(
                              onOpen: (link) async {
                                /* if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  throw 'Could not launch $link';
                                }*/
                              },
                              text: message ?? "",
                              linkStyle: TextStyle(color: Colors.blue),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(23, 23, 23, 1),
                                  fontFamily: AssetStrings.circulerNormal)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: Column(
                    children: [
                      new Container(
                          width: 38.0,
                          height: 38.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: getCachedNetworkImageWithurl(
                                url: profilePic ?? "", size: 38),
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          child: new Text(
                            time,
                            style: TextThemes.chatTimeStampblackTextSmallNormal,
                          ))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
