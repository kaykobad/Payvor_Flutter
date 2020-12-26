class ReferRequest {
  String lat;
  String long;
  String name;

  ReferRequest({this.lat, this.long, this.name});

  ReferRequest.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    long = json['long'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['name'] = this.name;

    return data;
  }
}

class ReferRequestNew {
  String lat;
  String long;

  ReferRequestNew({
    this.lat,
    this.long,
  });

  ReferRequestNew.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['long'] = this.long;

    return data;
  }
}
