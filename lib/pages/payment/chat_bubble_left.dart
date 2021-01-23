import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';

class ChatBubbleLeft extends StatelessWidget {
  final String message;
  final String userName;
  final String profilePic;
  final String time;

  ChatBubbleLeft(
      {@required this.message,
      @required this.userName,
      @required this.profilePic,
      @required this.time});


  @override
  Widget build(BuildContext context) {
    // firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Material(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20.0, top: 25),
        color: Colors.white,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Column(
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
                Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                        left: 50.0,
                        right: 3.0,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(230, 230, 230, 1),
                        border: new Border.all(
                          color: Color.fromRGBO(151, 151, 151, 0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12)),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /*    Linkify(
                                    text: widget.userName ?? "",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.kBlack,
                                        fontFamily: AssetStrings.circulerBoldStyle)),
                                SizedBox(
                                  height: 6.0,
                                ),*/
                                Linkify(
                                    onOpen: (link) async {
                                      /* if (await canLaunch(link.url)) {
                                        await launch(link.url);
                                      } else {
                                        throw 'Could not launch $link';
                                      }*/
                                    },
                                    text:message??"",
                                    linkStyle: TextStyle(color: Colors.blue),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromRGBO(23, 23, 23, 1),
                                        fontFamily:
                                        AssetStrings.circulerNormal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


}
