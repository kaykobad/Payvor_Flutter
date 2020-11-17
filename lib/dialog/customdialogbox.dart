
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:payvor/utils/constants.dart';
class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text;
  final PickedFile img;

  const CustomDialogBox({Key key, this.title, this.descriptions, this.text, this.img}) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _previewImage(),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text(widget.text,style: TextStyle(fontSize: 18),)),
              ),
            ],
          ),
        ),
//        Positioned(
//          left: Constants.padding,
//          right: Constants.padding,
//          child: CircleAvatar(
//            backgroundColor: Colors.transparent,
//            radius: Constants.avatarRadius,
//            child: ClipRRect(
//                borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
//                child: Image.asset("assets/model.jpeg")
//            ),
//          ),
//        ),
      ],
    );
  }

  Widget _previewImage() {
    return Container(
        width: double.infinity,
        height: 260,
        child: Image.file(File(widget.img.path),fit:BoxFit.cover));
  }
}