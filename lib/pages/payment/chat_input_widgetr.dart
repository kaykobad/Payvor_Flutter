import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';

class ChatInputWidget extends StatelessWidget {
  final ValueChanged<int> callBack;
  final TextEditingController messageFieldController;

  ChatInputWidget(this.callBack, this.messageFieldController);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // Returns write Message field bar
    return new Container(
      width: getScreenSize(context: context).width,
      decoration: new BoxDecoration(
        color: Colors.white,
        border: new Border(
          top: new BorderSide(
              width: 0.3, color: AppColors.dividerColor.withOpacity(0.8)),
        ),
      ),
      padding:
          new EdgeInsets.only(bottom: 5.0, left: 12.0, right: 12.0, top: 16.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              constraints: const BoxConstraints(
                maxHeight: 100.0,
              ),
              child: new TextField(
                controller: messageFieldController,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
                maxLines: null,
                decoration: new InputDecoration(
                  enabledBorder: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: Color.fromRGBO(227, 227, 227, 1),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  focusedBorder: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: AppColors.colorDarkCyan,
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
                      fontSize: 15.0,
                      fontFamily: AssetStrings.circulerNormal,
                      color: Color.fromRGBO(183, 183, 183, 1)),

                ),
              ),
            ),
          ),
          /*  new IconButton(
            icon: new Icon(
              Icons.send,
              color: AppColors.bluePrimary,
            ),
            onPressed: () {
              callBack(1);
            },
          ),*/


          Stack(
            children: [
              Container(
                margin: new EdgeInsets.only(left: 12),
                child: InkWell(
                  onTap: () {
                    callBack(1);
                  },
                  child: new Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: new Image.asset(
                      AssetStrings.chatSend,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0.0,
                right: 0.0,
                child: InkWell(
                  onTap: () {
                    callBack(1);
                  },
                  child: new Container(
                    margin: const EdgeInsets.only(top: 14, left: 10),
                    child: new Image.asset(
                      AssetStrings.chatSendButton,
                      width: 27,
                      height: 27,
                      color: Colors.white,
                    ),
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
