class UpdateProfileRequest {
  String phone;
  String country_code;
  String location;
  String lat;
  String long;
  String password;

  UpdateProfileRequest(
      {this.phone,
      this.country_code,
      this.location,
      this.lat,
      this.long,
      this.password});

  UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    country_code = json['country_code'];
    location = json['location'];
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.phone != null) data['phone'] = this.phone;
    if (this.country_code != null) data['country_code'] = this.country_code;
    if (this.location != null) data['location'] = this.location;
    if (this.lat != null) data['lat'] = this.lat;
    if (this.long != null) data['long'] = this.long;
    if (this.password != null) data['password'] = this.password;
    return data;
  }
}
