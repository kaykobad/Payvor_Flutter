import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:url_launcher/url_launcher.dart';

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
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 20.0, top: 25),
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Column(
                  children: [
                    new Container(
                        width: Constants.CHAT_PROFILE_PIC_SIZE,
                        height: Constants.CHAT_PROFILE_PIC_SIZE,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: getCachedNetworkImageWithurl(
                              url: profilePic ?? "", size: Constants.CHAT_PROFILE_PIC_SIZE),
                        )),
                    Container(
                        margin: const EdgeInsets.only(top: 4.0),
                        child: new Text(
                          time,
                          style: TextThemes.chatMessageTimeStyle,
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
                        color: AppColors.colorCyanPrimary,
                        border: new Border.all(
                          color: Color.fromRGBO(151, 151, 151, 0.2),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12)),
                      ),
                      child: Linkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            } else {
                              throw 'Could not launch $link';
                            }
                          },
                          text: message ?? "",
                          linkStyle: TextStyle(color: AppColors.kWhite),
                          style: TextThemes.chatMessageLeft),
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
