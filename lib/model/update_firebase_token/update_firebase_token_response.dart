class UpdateTokenResponse {
  Status status;
  Data data;

  UpdateTokenResponse({this.status, this.data});

  UpdateTokenResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
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

class Data {
  int id;
  String name;
  String email;
  String phone;
  int otp;
  String type;
  String countryCode;
  String lat;
  String long;
  int userType;
  int isActive;
  String snsId;
  String profilePic;
  String location;
  int isLocation;
  int isPhVerified;
  int isEmailVerified;
  int paymentMethod;
  int profilePicType;
  int isPassword;
  String deviceId;
  String createdAt;
  String updatedAt;

  Data(
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
      this.snsId,
      this.profilePic,
      this.location,
      this.isLocation,
      this.isPhVerified,
      this.isEmailVerified,
      this.paymentMethod,
      this.profilePicType,
      this.isPassword,
      this.deviceId,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
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
    isLocation = json['is_location'];
    isPhVerified = json['is_ph_verified'];
    isEmailVerified = json['is_email_verified'];
    paymentMethod = json['payment_method'];
    profilePicType = json['profile_pic_type'];
    isPassword = json['is_password'];
    deviceId = json['device_id'];
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
    data['snsId'] = this.snsId;
    data['profile_pic'] = this.profilePic;
    data['location'] = this.location;
    data['is_location'] = this.isLocation;
    data['is_ph_verified'] = this.isPhVerified;
    data['is_email_verified'] = this.isEmailVerified;
    data['payment_method'] = this.paymentMethod;
    data['profile_pic_type'] = this.profilePicType;
    data['is_password'] = this.isPassword;
    data['device_id'] = this.deviceId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
