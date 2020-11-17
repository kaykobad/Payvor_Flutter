import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GridViewShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                        crossAxisCount: 3),
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
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Stack(
        children: [
          ClipRRect(
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
        ],
      ),
    );
  }
}
