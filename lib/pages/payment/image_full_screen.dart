import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/constants.dart';

// todo: disposal
//import 'package:disposal/Utils/AppColors.dart';
//import 'package:disposal/Utils/Constants/Const.dart';

class ImageFullScreen extends StatelessWidget {
  final String imageUrl;

  ImageFullScreen(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Stack(children: <Widget>[
        _fullScreenImageWidget(imageUrl, width, height),
        Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, right: 16),
              child: _closeButton(context),
            ))
      ]),
    );
  }
}

Widget _closeButton(BuildContext context) {
  return InkWell(
    child: new Icon(Icons.cancel, color: AppColors.kWhite),
    onTap: () {
      Navigator.pop(context);
    },
  );
}

Widget _fullScreenImageWidget(String content, double width, double height) {
  return Center(
    child: CachedNetworkImage(
      placeholder: (context, url) => Container(
        child: CupertinoActivityIndicator(
          radius: Constants.LOADER_RADIUS,
        ),
        width: 200.0,
        height: 200.0,
        padding: EdgeInsets.all(70.0),
        decoration: BoxDecoration(
          color: AppColors.kGrey,
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
      width: (width * 80) / 100,
      height: (height * 90) / 100,
      fit: BoxFit.contain,
    ),
  );
}
