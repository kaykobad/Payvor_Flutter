class FavourDetailsResponse {
  Status status;
  Data data;

  FavourDetailsResponse({this.status, this.data});

  FavourDetailsResponse.fromJson(Map<String, dynamic> json) {
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
  int userId;
  int isActive;
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
  User user;
  List<Rating> rating;
  num ratingCount;
  num ratingAvg;
  num service_fee;
  num receiving;
  num service_perc;
  int is_user_applied;

  Data(
      {this.id,
      this.userId,
      this.isActive,
      this.title,
      this.perc,
      this.price,
      this.description,
      this.lat,
      this.long,
      this.location,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.rating,
      this.ratingCount,
    this.ratingAvg,
    this.service_fee,
    this.receiving,
    this.service_perc,
    this.is_user_applied});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    isActive = json['is_active'];
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
    service_fee = json['service_fee'];
    service_perc = json['service_perc'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['rating'] != null) {
      rating = new List<Rating>();
      json['rating'].forEach((v) {
        rating.add(new Rating.fromJson(v));
      });
    }
    ratingCount = json['rating_count'];
    ratingAvg = json['rating_avg'];
    service_fee = json['service_fee'];
    receiving = json['receiving'];
    service_perc = json['service_perc'];
    is_user_applied = json['is_user_applied'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['is_active'] = this.isActive;
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
    data['service_fee'] = this.service_fee;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.rating != null) {
      data['rating'] = this.rating.map((v) => v.toJson()).toList();
    }
    data['rating_count'] = this.ratingCount;
    data['service_perc'] = this.service_perc;
    data['rating_avg'] = this.ratingAvg;
    data['receiving'] = this.receiving;
    data['is_user_applied'] = this.is_user_applied;
    return data;
  }
}

class User {
  int id;
  String name;
  String email;
  String phone;
  Object otp;
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
      this.snsId,
      this.profilePic,
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
    snsId = json['snsId'];
    profilePic = json['profile_pic'];
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
    data['snsId'] = this.snsId;
    data['profile_pic'] = this.profilePic;
    data['location'] = this.location;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Rating {
  int id;
  int userId;
  num rating;
  String description;
  int isActive;
  String createdAt;
  String updatedAt;

  Rating({this.id,
    this.userId,
    this.rating,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt});

  Rating.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    rating = json['rating'];
    description = json['description'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['rating'] = this.rating;
    data['description'] = this.description;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}