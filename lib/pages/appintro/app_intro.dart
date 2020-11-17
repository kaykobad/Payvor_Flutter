import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvor/pages/privacypolicy/webview_page.dart';
import 'package:payvor/resources/class%20ResString.dart';

import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/constants.dart';

class AppIntroPage extends StatefulWidget {
  @override
  _AppIntroPageState createState() => _AppIntroPageState();
}

class _AppIntroPageState extends State<AppIntroPage> {
  PageController _pagercontroller;

  final controller = PageController(viewportFraction: 0.8);
  var _height;
  var _currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pagercontroller = new PageController();
  }

  @override
  void dispose() {
    _pagercontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Column(
          children: [
            _topView(),
            Flexible(
              child: PageView(
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                  //  print(page);
                },
                controller: _pagercontroller,
                children: [
                  SwipeCard(
                    heading: ResString().get('appIntroHeadng1'),
                    subHeading: ResString().get('appIntroSubHeading1'),
                    imagePath: AssetStrings.appIntroPage2,
                  ),
                  SwipeCard(
                      heading: ResString().get('appIntroHeadng2'),
                      subHeading: ResString().get('appIntroSubHeading2'),
                      imagePath: AssetStrings.appIntroPage3),
                  SwipeCard(
                      heading: ResString().get('appIntroHeadng3'),
                      subHeading: ResString().get('appIntroSubHeading3'),
                      imagePath: AssetStrings.appIntroPage4),
                ],
              ),
            ),
            Container(
                height: _height * 0.15,
                width: double.infinity,
                child: (_currentPage == 2) ? _bottomWidget2() : _bottomWidget())
          ],
        ),
      ),
    );
  }

  Widget _bottomWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0, left: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_tabIndicator(), _nextWidget()],
      ),
    );
  }

  _redirect({@required String heading, @required String url}) async {
    //Navigator.of(context).pushNamed(Routes.nearpost);
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new WebViewPages(
                  heading: heading,
                  url: url,
                )));
  }

  Widget _bottomWidget2() {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0, left: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 8,
              ),
              Icon(
                Icons.check_circle_outline,
                color: Colors.black,
              ),
              SizedBox(
                width: 8,
              ),
              RichText(
                text: TextSpan(
                  text: 'Agree, ',
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontFamily: AssetStrings.gilorySemiBoldStyle),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('Privacy Policy"');
                            _redirect(
                                heading: ResString().get('privacy_policy'),
                                url: Constants.privacyPolicy);
                          }),
                    TextSpan(
                        text: ' and ',
                        style: TextStyle(
                            fontFamily: AssetStrings.giloryRegularStyle)),
                    TextSpan(
                        text: 'Terms of use.',
                        style: TextStyle(
                            fontFamily: AssetStrings.gilorySemiBoldStyle,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _redirect(
                                heading: ResString().get('term_of_uses'),
                                url: Constants.TermOfUses);
                            print('Term of use');
                          }),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: InkWell(
                onTap: () {
                  _goToHome();
                },
                child: _button()),
          )
        ],
      ),
    );
  }

  Widget _button() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        gradient: LinearGradient(
          colors: [
            AppColors.kFirstGradientColor,
            AppColors.kSecondGradientColor.withOpacity(0.9),
            AppColors.kSecondGradientColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
//      decoration: new BoxDecoration(
//        gradient: new SweepGradient(
//
//          colors: [
//            Colors.blue.withOpacity(0.5),
//            Colors.green.withOpacity(0.4),
//            Colors.green.withOpacity(0.5)
//          ],
//        ),
//        borderRadius: BorderRadius.all(Radius.circular(100)),
//      ),
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Get Started",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: AssetStrings.gilorySemiBoldStyle,
                  color: AppColors.kWhite),
            ),
            SizedBox(
              width: 10,
            ),
            SvgPicture.asset(
              AssetStrings.nextArrowIcon,
              semanticsLabel: 'Acme Logo',
              width: 14,
              height: 14,
              color: AppColors.kWhite,
            ),
          ],
        ),
      )),
    );
  }

  void nextPage() {
    _pagercontroller.animateToPage(_pagercontroller.page.toInt() + 1,
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  void _lastPage() {
    _pagercontroller.animateToPage(2,
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  Widget _nextWidget() {
    return InkWell(
      onTap: () {
        nextPage();
      },
      child: Row(
        children: [
          Text(
            "Next",
            style: TextStyle(
                fontSize: 20, fontFamily: AssetStrings.gilorySemiBoldStyle),
          ),
          SizedBox(
            width: 10,
          ),
          SvgPicture.asset(
            AssetStrings.nextArrowIcon,
            semanticsLabel: 'Acme Logo',
            width: 18,
            height: 18,
          ),
        ],
      ),
    );
  }

  _goToHome() {
    Navigator.pushNamed(context, '/home');
  }

  Widget _topView() {
    return Container(
      color: Colors.white,
      height: _height * 0.10,
      width: double.infinity,
      child: Stack(
        children: [
          Visibility(
            visible: _currentPage != 2,
            child: Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: () {
                    _lastPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: AssetStrings.giloryRegularStyle),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _tabIndicator() {
    return Row(
      children: [
        (_currentPage == 0) ? TabSelected() : TabNotSelected(),
        SizedBox(
          width: 8,
        ),
        (_currentPage == 1) ? TabSelected() : TabNotSelected(),
        SizedBox(
          width: 8,
        ),
        (_currentPage == 2) ? TabSelected() : TabNotSelected(),
      ],
    );
  }
}

class SwipeCard extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String imagePath;

  SwipeCard(
      {@required this.heading,
      @required this.subHeading,
      @required this.imagePath});

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    return Container(
      color: AppColors.kWhite,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Center(
                child: Container(
                  color: AppColors.kWhite,
                  height: _height * 0.45,
                  width: double.infinity,
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100.0,
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.kWhite.withOpacity(0.0),
                        AppColors.kGrey.withOpacity(0.1),
                        AppColors.kGrey.withOpacity(0.1)
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(
                            MediaQuery.of(context).size.width, 70.0)),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: _height * 0.20,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    heading,
                    style: TextStyle(
                        fontSize: 21,
                        color: AppColors.kAppIntroHeadingColor,
                        fontFamily: AssetStrings.giloryExteraBoldStyle),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Text(
                      subHeading,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: AppColors.kAppIntroSubHeadingColor,
                          fontFamily: AssetStrings.giloryRegularStyle),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TabSelected extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12.0,
      height: 12.0,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: AppColors.kFirstGradientColor, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(100.0)),
          color: Colors.white),
    );
  }
}

class TabNotSelected extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.0,
      height: 6,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(100.0)),
          color: Colors.grey),
    );
  }
}
