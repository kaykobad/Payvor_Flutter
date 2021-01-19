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
        border: new Border(
          top: new BorderSide(width: 0.8, color: AppColors.dividerColor),
        ),
      ),
      padding: new EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 12.0,
      ),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              margin: new EdgeInsets.only(left: 15.0, right: 15.0),
              constraints: const BoxConstraints(
                maxHeight: 90.0,
              ),
              child: new TextField(
                controller: messageFieldController,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.greyProfile,
                  fontFamily: AssetStrings.circulerNormal,
                ),
                maxLines: null,
                decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  enabledBorder: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: AppColors.dividerColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  focusedBorder: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: AppColors.dividerColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  contentPadding: new EdgeInsets.only(
                      left: 20.0, right: 20, top: 10, bottom: 0),
                  fillColor: AppColors.dividerColor,
                  filled: true,
                  hintText: "Write a message...",
                  hintStyle: new TextStyle(
                      fontSize: 14.0,
                      fontFamily: AssetStrings.circulerNormal,
                      color: AppColors.kBlack),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
//                      new InkWell(
//                        child: Padding(
//                          padding: const EdgeInsets.all(8.0),
//                          child: new Icon(
//                            Icons.image,
//                            size: 18,
//                            color: AppColors.kAppBlack,
//                          ),
//                        ),
//                        onTap: () {
//                          callBack(2); //for image
//                        },
//                      ),
                      new InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Icon(
                            Icons.send,
                            color: AppColors.kPrimaryBlue,
                            size: 18,
                          ),
                        ),
                        onTap: () {
                          callBack(1); // for chat
                        },
                      ),
                      new SizedBox(
                        width: 11.0,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          /* new IconButton(
              icon: new Icon(Icons.image,size: 18),
              //onPressed: _imagePicker,
              color: AppColors.kAppBlack,

            ),*/
        ],
      ),
    );
  }
}
