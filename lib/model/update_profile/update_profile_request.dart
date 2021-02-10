class UpdateProfileRequest {
  String phone;
  String country_code;
  String location;
  String lat;
  String long;
  String password;
  String profile_pic;
  String name;
  String device_id;

  UpdateProfileRequest(
      {this.phone,
      this.country_code,
      this.location,
      this.lat,
      this.long,
      this.password,
      this.profile_pic,
      this.name,
      this.device_id});

  UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    country_code = json['country_code'];
    location = json['location'];
    lat = json['lat'];
    long = json['long'];
    password = json['password'];
    profile_pic = json['profile_pic'];
    name = json['name'];
    device_id = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.phone != null) data['phone'] = this.phone;
    if (this.country_code != null) data['country_code'] = this.country_code;
    if (this.location != null) data['location'] = this.location;
    if (this.lat != null) data['lat'] = this.lat;
    if (this.long != null) data['long'] = this.long;
    if (this.password != null) data['password'] = this.password;
    if (this.profile_pic != null) data['profile_pic'] = this.profile_pic;
    if (this.name != null) data['name'] = this.name;
    if (this.device_id != null) data['device_id'] = this.device_id;
    return data;
  }
}
