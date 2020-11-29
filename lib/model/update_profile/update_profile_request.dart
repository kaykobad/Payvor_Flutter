class UpdateProfileRequest {
  String phone;
  String country_code;
  String location;
  String lat;
  String long;

  UpdateProfileRequest(
      {this.phone, this.country_code, this.location, this.lat, this.long});

  UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    country_code = json['country_code'];
    location = json['location'];
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['country_code'] = this.country_code;
    data['location'] = this.location;
    data['lat'] = this.lat;
    data['long'] = this.long;
    return data;
  }
}
