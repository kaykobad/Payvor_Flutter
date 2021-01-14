import 'package:flutter/material.dart';
import 'package:payvor/utils/UniversalFunctions.dart';

class ChatProfilePic extends StatelessWidget {
  final String profilePic;

  ChatProfilePic(this.profilePic);

  @override
  Widget build(BuildContext context) {
    return new Container(
        width: 32.0,
        height: 32.0,
        decoration: new BoxDecoration(
          color: Colors.grey,
          border: new Border.all(color: Colors.white, width: 0.3),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: getCachedNetworkImageWithurl(url: profilePic ?? "", size: 32),
        ));
  }
}
