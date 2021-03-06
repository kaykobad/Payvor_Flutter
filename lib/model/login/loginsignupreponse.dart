class LoginSignupResponse {
  Status status;
  String data;
  AppUser user;
  bool isnew;

  LoginSignupResponse({this.status, this.data, this.user, this.isnew});

  LoginSignupResponse.fromJson(Map<String, dynamic> json) {
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
    data = json['data'];
    user = json['user'] != null ? new AppUser.fromJson(json['user']) : null;
    isnew = json['isnew'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    data['data'] = this.data;
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

class AppUser {
  int id;
  String name;
  String email;
  String phone;
  dynamic otp;
  String type;
  String countryCode;
  String lat;
  String long;
  int userType;
  int isActive;
  String snsId;
  String profilePic;
  String location;
  String createdAt;
  String updatedAt;
  int is_password;
  int is_location;
  num ratingAvg;
  num ratingCount;
  num perc;
  num is_email_verified;
  num is_ph_verified;
  num payment_method;
  num profile_pic_type;
  num disable_push;
  String device_id;

  AppUser({
    this.id,
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
    this.snsId,
    this.profilePic,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.is_password,
    this.is_location,
    this.ratingAvg,
    this.ratingCount,
    this.perc,
    this.is_email_verified,
    this.is_ph_verified,
    this.payment_method,
    this.profile_pic_type,
    this.disable_push,
    this.device_id,
  });

  AppUser.fromJson(Map<String, dynamic> json) {
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
    snsId = json['snsId'];
    profilePic = json['profile_pic'];
    location = json['location'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    is_password = json['is_password'];
    is_location = json['is_location'];
    ratingAvg = json['rating_avg'];
    ratingCount = json['rating_count'];
    perc = json['perc'];
    is_email_verified = json['is_email_verified'];
    is_ph_verified = json['is_ph_verified'];
    payment_method = json['payment_method'];
    profile_pic_type = json['profile_pic_type'];
    disable_push = json['disable_push'];
    device_id = json['device_id'];
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
    data['snsId'] = this.snsId;
    data['profile_pic'] = this.profilePic;
    data['location'] = this.location;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_password'] = this.is_password;
    data['is_location'] = this.is_location;
    data['rating_avg'] = this.ratingAvg;
    data['rating_count'] = this.ratingCount;
    data['perc'] = this.perc;
    data['is_email_verified'] = this.is_email_verified;
    data['is_ph_verified'] = this.is_ph_verified;
    data['payment_method'] = this.payment_method;
    data['profile_pic_type'] = this.profile_pic_type;
    data['is_password'] = this.is_password;
    data['is_location'] = this.is_location;
    data['device_id'] = this.device_id;
    return data;
  }
}