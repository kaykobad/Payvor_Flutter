class HomeRequest {
  num lat;
  num lng;

  HomeRequest({this.lat,this.lng});

  HomeRequest.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['long'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['long'] = this.lng;

    return data;
  }
}
