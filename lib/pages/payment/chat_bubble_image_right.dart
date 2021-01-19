import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/chat/chat_profile.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';

import 'image_full_screen.dart';

class ChatBubbleImageRight extends StatelessWidget {
  final String content;
  final num timeStamp;
  final String profilePic;

  ChatBubbleImageRight(
      {@required this.content,
      @required this.timeStamp,
      @required this.profilePic});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(top: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CupertinoActivityIndicator(
                          radius: Constants.LOADER_RADIUS,
                        ),
                        width: 200.0,
                        height: 200.0,
                        padding: EdgeInsets.all(70.0),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryBlue,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Material(
                        child: Image.asset(
                          'images/img_not_available.jpeg',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                      imageUrl: content,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: AppColors.kPrimaryBlue,
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                SizedBox(
                  width: 10,
                ),
                ChatProfilePic(profilePic),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 70.0),
              child: Text(
                readTimestamp(timeStamp.toString()),
                style: TextStyle(
                    color: AppColors.kGrey, fontFamily: "RobotoRegular"),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      onTap: () {
        moveToImageFullScreen(content, context);
      },
    );
  }

  void moveToImageFullScreen(String imageUrl, BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            ImageFullScreen(imageUrl)));
  }
}
