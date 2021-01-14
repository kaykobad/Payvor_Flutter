import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';

class ChatBubbleRight extends StatefulWidget {
  final String message;
  final String userName;
  final String profilePic;
  final String time;
  final String chatId;
  final String messageId;
  bool isLiked;
  final bool isGroup;

  ChatBubbleRight(
      {@required this.message,
      @required this.userName,
      @required this.profilePic,
      @required this.time,
      @required this.isLiked,
      @required this.chatId,
      @required this.messageId,
      @required this.isGroup});

  @override
  _ChatBubbleLeftState createState() => _ChatBubbleLeftState();
}

class _ChatBubbleLeftState extends State<ChatBubbleRight>
    with AutomaticKeepAliveClientMixin<ChatBubbleRight> {
//  FirebaseProvider firebaseProvider;

  void _likeUnlike() async {
    print("called ${widget.isGroup}");
    //  var userId = MemoryManagement.getuserId();
    /*   if (widget.isGroup)
      widget.isLiked = await firebaseProvider.groupChatMessageChatLikedUnliked(
          widget.isLiked, widget.chatId, widget.messageId, int.parse(userId));
    else
      widget.isLiked = await firebaseProvider.privateChatLikedUnliked(
          widget.isLiked, widget.chatId, widget.messageId, int.parse(userId));
*/
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Material(
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
                  padding: const EdgeInsets.all(16),
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
                              text:
                                  "I’m free now, can you send me your location? I’ll be at yours in a few. hiudhsiuhfishaiofhioashfiohaiohfihasiofhioashfoihasiohfioashioashnfikhasnikfnhs :)",
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
