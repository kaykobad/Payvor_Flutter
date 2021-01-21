import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';

class ChatBubbleLeft extends StatefulWidget {
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
  _ChatBubbleLeftState createState() => _ChatBubbleLeftState();
}

class _ChatBubbleLeftState extends State<ChatBubbleLeft>
    with AutomaticKeepAliveClientMixin<ChatBubbleLeft> {
//  FirebaseProvider firebaseProvider;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Material(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20.0, top: 25),
        color: Colors.white,
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
                              url: widget.profilePic ?? "", size: 38),
                        )),
                    Container(
                        margin: const EdgeInsets.only(top: 4.0),
                        child: new Text(
                          "16:38",
                          style: new TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(103, 99, 99, 1)),
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
                                    text:widget.message??"",
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
