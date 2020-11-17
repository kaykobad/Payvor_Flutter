import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PlacesGridViewShimmer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 250) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 1.0, right: 1.0, top: 8.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: (itemWidth / itemHeight)),
                    physics: BouncingScrollPhysics(),
                    // Generate 100 widgets that display their index in the List.
                    itemCount: 30,
                    itemBuilder: (BuildContext context, int index) {
                      return ItemGrid();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(15),
      )),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: (MediaQuery.of(context).size.width / 2),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[200],
                  highlightColor: Colors.grey[400],
                  child: Container(
                    width: double.infinity,
                    height: 8.0,
                    color: Colors.yellow,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
