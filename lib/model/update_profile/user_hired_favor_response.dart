import 'package:payvor/model/login/loginsignupreponse.dart';

class UserProfileFavorResponse {
  Status status;
  Data data;
  AppUser user;

  UserProfileFavorResponse({this.status, this.data, this.user});

  UserProfileFavorResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    user = json['user'] != null ? new AppUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user.toJson();
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
  int currentPage;
  List<DataUserFavour> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  String nextPageUrl;
  String path;
  int perPage;
  String prevPageUrl;
  int to;
  int total;

  Data({this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = new List<DataUserFavour>();
      json['data'].forEach((v) {
        data.add(new DataUserFavour.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class DataUserFavour {
  int id;
  int userId;
  int isActive;
  int isDeleted;
  int hiredUserId;
  int status;
  num perc;
  String title;
  String price;
  String description;
  String lat;
  String long;
  String location;
  String image;
  String createdAt;
  String updatedAt;

  DataUserFavour(
      {this.id,
      this.userId,
      this.isActive,
      this.isDeleted,
      this.hiredUserId,
      this.status,
      this.title,
      this.price,
      this.perc,
      this.description,
      this.lat,
      this.long,
      this.location,
      this.image,
      this.createdAt,
      this.updatedAt});

  DataUserFavour.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    isActive = json['is_active'];
    isDeleted = json['is_deleted'];
    hiredUserId = json['hired_user_id'];
    status = json['status'];
    title = json['title'];
    price = json['price'];
    perc = json['perc'];
    description = json['description'];
    lat = json['lat'];
    long = json['long'];
    location = json['location'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['is_active'] = this.isActive;
    data['is_deleted'] = this.isDeleted;
    data['hired_user_id'] = this.hiredUserId;
    data['status'] = this.status;
    data['title'] = this.title;
    data['price'] = this.price;
    data['perc'] = this.perc;
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['location'] = this.location;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
/*
class User {
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
  String createdAt;
  String updatedAt;
  num ratingAvg;
  num ratingCount;
  num perc;
  num is_email_verified;
  num is_ph_verified;
  num payment_method;
  num profile_pic_type;
  num is_password;
  num is_location;

  User({this.id,
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
    this.ratingAvg,
    this.ratingCount,
    this.perc,
    this.is_email_verified,
    this.is_ph_verified,
    this.payment_method,
    this.profile_pic_type,
    this.is_password,
    this.is_location,

  });

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
    snsId = json['snsId'];
    profilePic = json['profile_pic'];
    location = json['location'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    ratingAvg = json['rating_avg'];
    ratingCount = json['rating_count'];
    perc = json['perc'];
    is_email_verified = json['is_email_verified'];
    is_ph_verified = json['is_ph_verified'];
    payment_method = json['payment_method'];
    profile_pic_type = json['profile_pic_type'];
    is_password = json['is_password'];
    is_location = json['is_location'];
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
    data['rating_avg'] = this.ratingAvg;
    data['rating_count'] = this.ratingCount;
    data['perc'] = this.perc;
    data['is_email_verified'] = this.is_email_verified;
    data['is_ph_verified'] = this.is_ph_verified;
    data['payment_method'] = this.payment_method;
    data['profile_pic_type'] = this.profile_pic_type;
    data['is_password'] = this.is_password;
    data['is_location'] = this.is_location;
    return data;
  }*/
