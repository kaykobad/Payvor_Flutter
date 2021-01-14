import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/UniversalFunctions.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Controllers
  final TextEditingController _newMessageFieldController =
      new TextEditingController();

  // Getters
  get _getAppbar {
    return new AppBar(
      title: new Text(
        "Chat",
        style: new TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      backgroundColor: Colors.white,
      leading: new IconButton(
        icon: new Icon(
          Icons.keyboard_backspace,
          color: Colors.black,
          size: 25.0,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
    );
  }

  // Returns message list
  get _getMessageList {
    return new ListView();
  }

  // Returns write Message field bar
  get _getWriteMessageFieldBar {
    return new Container(
      width: getScreenSize(context: context).width,
      decoration: new BoxDecoration(
        color: Colors.white,
        border: new Border(
          top: new BorderSide(width: 0.8, color: Colors.grey),
        ),
      ),
      padding: new EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              constraints: const BoxConstraints(
                maxHeight: 100.0,
              ),
              child: new TextField(
                controller: _newMessageFieldController,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
                maxLines: null,
                decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: Color.fromRGBO(227, 227, 227, 1),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                  fillColor: Color.fromRGBO(248, 248, 250, 1),
                  filled: true,
                  hintText: "Write a message..",
                  hintStyle: new TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: new IconButton(
                    icon: new Icon(Icons.image),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
          new IconButton(
            icon: new Icon(
              Icons.send,
              color: AppColors.bluePrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // builds screen
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        closeKeyboard();
      },
      child: new Scaffold(
        appBar: _getAppbar,
        body: new SafeArea(
          top: false,
          child: new Column(
            children: <Widget>[
              new Expanded(
                child: _getMessageList,
              ),
              _getWriteMessageFieldBar,
            ],
          ),
        ),
      ),
    );
  }
}

////////
class CardCustomClipper extends StatefulWidget {
  @override
  _CardCustomClipperState createState() => _CardCustomClipperState();
}

class _CardCustomClipperState extends State<CardCustomClipper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipPath(
          child: Container(
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          clipper: MyClipper(),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final path = new Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * .9 - 25, size.height);
    path.quadraticBezierTo(size.width * .9 - 10, size.height,
        size.width * .9 - 10, size.height - 15);
    path.lineTo(size.width * .9 - 10, size.height * .2);
    path.lineTo(size.width - 10, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
