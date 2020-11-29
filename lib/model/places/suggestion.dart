class SuggestedLocation {
  String status;
  List<Predictions> predictions;

  SuggestedLocation({this.status, this.predictions});

  SuggestedLocation.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['predictions'] != null) {
      predictions = new List<Predictions>();
      json['predictions'].forEach((v) {
        predictions.add(new Predictions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.predictions != null) {
      data['predictions'] = this.predictions.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Predictions {
  String description;
  int distanceMeters;
  String place_id;

  Predictions({this.description, this.distanceMeters, this.place_id});

  Predictions.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    distanceMeters = json['distance_meters'];
    place_id = json['place_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['distance_meters'] = this.distanceMeters;
    data['place_id'] = this.place_id;
    return data;
  }
}
