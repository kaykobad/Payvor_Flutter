import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';

class AppIntroDiscoverPage extends StatefulWidget {
  @override
  _AppIntroDiscoverPageState createState() => _AppIntroDiscoverPageState();
}

class _AppIntroDiscoverPageState extends State<AppIntroDiscoverPage> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kAppIntroBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0),
              child: backIcon(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0),
              child: TopViewWidget(),
            ),

            Flexible(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                    child: LeftWidget(),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      children: [
                        SwipeCard(),
                        SwipeCard(),
                        SwipeCard(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                    child: RightWidget(),
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: BottomView(),
            ),
            Container(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

Widget backIcon() {
  return Icon(
    Icons.arrow_back,
    color: Colors.black,
    size: 32.0,
  );
}

class LeftWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 35,
      decoration: BoxDecoration(
          color: AppColors.kAppIntroLeftRightStand,
          border: Border.all(
            color: AppColors.kAppIntroLeftRightStand,
          ),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
    );
  }
}

class RightWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 35,
      decoration: BoxDecoration(
          color: AppColors.kAppIntroLeftRightStand,
          border: Border.all(
            color: AppColors.kAppIntroLeftRightStand,
          ),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
    );
  }
}

class TopViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBarLogo(),
        Text(
          "Select Preferences",
          style: TextStyle(
              fontSize: 19,
              fontFamily: AssetStrings.gilorySemiBoldStyle,
              color: AppColors.kAppIntroPreferenceColor),
        ),
        SizedBox(
          height: 10,
        ),
        Text("Lorum ipsum Lorum ipsum Lorum ipsum Lorum ipsum Lorum ipsum?",
            style: TextStyle(
                fontSize: 21, fontFamily: AssetStrings.giloryExteraBoldStyle)),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }
}

class AppBarLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetStrings.logoIcon1,
      width: 140,
      height: 100,
    );
  }
}

class BottomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            AssetStrings.swipeIcon,
            semanticsLabel: 'Acme Logo',
            width: 50,
            height: 50,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Swipe and Select",
            style: TextStyle(
                fontSize: 18,
                fontFamily: AssetStrings.gilorySemiBoldStyle,
                color: Color(0xFFC0CCDA)),
          )
        ],
      ),
    );
  }
}

class SwipeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetStrings.slideSolo,
              semanticsLabel: 'Acme Logo',
              width: 150,
              height: 150,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Solo",
              style: TextStyle(
                  fontSize: 24, fontFamily: AssetStrings.giloryExteraBoldStyle),
            )
          ],
        ),
      ),
    );
  }
}



