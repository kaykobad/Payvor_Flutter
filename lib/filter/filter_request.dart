import 'package:payvor/filter/data.dart';

class FilterRequest {
  String location;
  String latlongData;
  int minAmount;
  int maxAmount;
  int distance;
  List<DataModel> list;

  FilterRequest(
      {this.location,
      this.latlongData,
      this.minAmount,
      this.maxAmount,
      this.distance,
      this.list});
}
