class FavourDetailsResponse {
  Status status;
  String success;
  List<Data> data;

  FavourDetailsResponse({this.status, this.success, this.data});

  FavourDetailsResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    success = json['Success'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    data['Success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
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
  int userId;
  int isActive;
  String title;
  String price;
  String description;
  String lat;
  String long;
  String location;
  String image;
  String createdAt;
  String updatedAt;
  String name;
  String email;
  String phone;
  String otp;
  String type;
  String countryCode;
  String password;
  int userType;
  String snsId;
  String profilePic;
  String rememberToken;

  Data(
      {this.id,
      this.userId,
      this.isActive,
      this.title,
      this.price,
      this.description,
      this.lat,
      this.long,
      this.location,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.name,
      this.email,
      this.phone,
      this.otp,
      this.type,
      this.countryCode,
      this.password,
      this.userType,
      this.snsId,
      this.profilePic,
      this.rememberToken});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    isActive = json['is_active'];
    title = json['title'];
    price = json['price'];
    description = json['description'];
    lat = json['lat'];
    long = json['long'];
    location = json['location'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    otp = json['otp'];
    type = json['type'];
    countryCode = json['country_code'];
    password = json['password'];
    userType = json['user_type'];
    snsId = json['snsId'];
    profilePic = json['profile_pic'];
    rememberToken = json['remember_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['is_active'] = this.isActive;
    data['title'] = this.title;
    data['price'] = this.price;
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['location'] = this.location;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['otp'] = this.otp;
    data['type'] = this.type;
    data['country_code'] = this.countryCode;
    data['password'] = this.password;
    data['user_type'] = this.userType;
    data['snsId'] = this.snsId;
    data['profile_pic'] = this.profilePic;
    data['remember_token'] = this.rememberToken;
    return data;
  }
}
