class SignupResponse {
  Status status;

  User user;
  bool isnew;

  SignupResponse({this.status,  this.user, this.isnew});

  SignupResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json
        ['status']) : null;

    //data = json['data'];
    user = json['data'] != null ? new User.fromJson(json['data']) : null;
    isnew = json['isnew'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }

    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['isnew'] = this.isnew;
    return data;
  }
}

class Status {
  bool status;
  String message;
  int code;

  Status({this.status, this.message, this.code});

  Status.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['code'] = this.code;
    return data;
  }
}

class User {
  int id;
  String name;
  String email;
  String phone;
  int otp;
  String type;
  String countryCode;
  num lat;
  num long;
  int userType;
  int isActive;
  String location;
  String createdAt;
  String updatedAt;

  User(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.otp,
      this.type,
      this.countryCode,
      this.lat,
      this.long,
      this.userType,
      this.isActive,
      this.location,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    otp = json['otp'];
    type = json['type'];
    countryCode = json['country_code'];
    lat = json['lat'];
    long = json['long'];
    userType = json['user_type'];
    isActive = json['is_active'];
    location = json['location'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['otp'] = this.otp;
    data['type'] = this.type;
    data['country_code'] = this.countryCode;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['user_type'] = this.userType;
    data['is_active'] = this.isActive;
    data['location'] = this.location;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
