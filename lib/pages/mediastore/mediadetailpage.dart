import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/shimmers/media_grid_shimmer.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/viewmodel/home_view_model.dart';

import 'package:provider/provider.dart';

class MediaDetailPage extends StatefulWidget {
  final List<String> imagesList;
  final int pos;

  MediaDetailPage({@required this.imagesList, @required this.pos});

  @override
  _MediaDetailPageState createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  HomeViewModel _homeViewModel;
  var _ITEMHEIGHT = 350.0;
  var _ITEMHEIGHT2 = 500.0;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      var posDiff =
          ((widget.pos) / 2 * _ITEMHEIGHT) + ((widget.pos) / 2 * _ITEMHEIGHT2);
      _scrollController.animateTo(
        (posDiff - 150),
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
      );
    });
  }

  VoidCallback backButtonPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _homeViewModel = Provider.of<HomeViewModel>(context);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: AppColors.kBackgroundColor,
        appBar: commonAppBar(callback: backButtonPressed,title: "Wineglass Bay"),
        body: Stack(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 2.0, right: 2.0, top: 8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.imagesList.length,
                      itemBuilder: (context, index) {
                        var itemHeight =
                            (index % 2 != 0) ? _ITEMHEIGHT : _ITEMHEIGHT2;
                        return _getItem(widget.imagesList[index], itemHeight);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
                visible: _homeViewModel.getLoading(),
                child: Center(
                  child: GridViewShimmer(),
                ))
          ],
        ));
  }

  Widget _getItem(String url, double itemHeight) {
    return Container(
      height: itemHeight,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        child: Stack(
          children: [
            getCachedNetworkImage(
                url: url, fit: BoxFit.cover, height: double.infinity),
            Positioned(
              child: _dateTime(),
              bottom: 20,
              left: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _dateTime() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "20 November 2020",
          style: TextStyle(
              color: Colors.white, fontFamily: AssetStrings.giloryBoldStyle,fontSize: 16),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
            decoration: BoxDecoration(
                color: AppColors.kBlack.withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, right: 16.0, left: 16.0),
              child: Text(
                "8.00 pm",
                style: TextStyle(color: AppColors.kWhite,fontSize: 12,fontFamily: AssetStrings.gilorySemiBoldStyle),
              ),
            )),
      ],
    );
  }
}
