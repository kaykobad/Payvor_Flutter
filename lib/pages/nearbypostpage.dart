import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/home/homerequest.dart';
import 'package:payvor/model/places/placeitem.dart';
import 'package:payvor/shimmers/places_grid_shimmer.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:payvor/viewmodel/home_view_model.dart';

import 'package:provider/provider.dart';

import 'mediastore/mediastroepage.dart';

class NearByPostPage extends StatefulWidget {
  @override
  _NearByPostPageState createState() => _NearByPostPageState();
}

class _NearByPostPageState extends State<NearByPostPage> {


  HomeViewModel _homeViewModel;
  var _placeList=List<PlacesItem>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      fetchData();
    });
  }
  void fetchData() async {
    _homeViewModel.setLoading();
    var response = await _homeViewModel.getPlacesData(HomeRequest(), context);
    if (response is APIError) {
    } else {
      _placeList.addAll(response);
    }
  }
  VoidCallback backButtonPressed()
  {
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    _homeViewModel = Provider.of<HomeViewModel>(context);

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 250) / 2;
    final double itemWidth = size.width / 2;

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: AppColors.kBackgroundColor,
        appBar:  commonAppBar(callback:backButtonPressed,title: "Wineglass Bay"),
        body: Stack(
          children: [
            GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: (itemWidth / itemHeight)),
                physics: ScrollPhysics(),
                itemCount: _placeList.length,
                itemBuilder: (BuildContext context, int index) {
                  return _getItem(_placeList[index]);
                }),
            Visibility(
                visible: _homeViewModel.getLoading(),
                child: Center(
                  child: PlacesGridViewShimmer(),
                ))
          ],
        ));
  }
  redirect() async {

    //Navigator.of(context).pushNamed(Routes.nearpost);
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => new MediaStorePage())
    );
  }

  Widget _getItem(PlacesItem placesItem) {
    return InkWell(
      onTap:redirect ,
      child: Container(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(15),
          )),
          child: Container(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: getCachedNetworkImage(
                          url: placesItem.imageUrl,
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10.0),
                        width: double.infinity,
                        child: Text(
                          placesItem.title,
                          style: TextThemes.headline4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
