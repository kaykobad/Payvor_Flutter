import 'package:payvor/filter/data.dart';

class FilterRequest {
  String location;
  String latlongData;
  int minprice;
  int maxprice;
  int distance;
  List<DataModel> list;
  List<String> listCategory;

  FilterRequest(
      {this.location,
      this.latlongData,
      this.minprice,
      this.maxprice,
      this.distance,
      this.list,
      this.listCategory});
}
