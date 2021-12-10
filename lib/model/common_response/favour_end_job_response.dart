class EndedJobFavourResponse {
  Status status;
  Data data;

  EndedJobFavourResponse({this.status, this.data});

  EndedJobFavourResponse.fromJson(Map<String, dynamic> json) {
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
  int isDeleted;
  int hiredUserId;
  int status;
  String title;
  String price;
  String description;
  String lat;
  String long;
  String location;
  String image;
  String paymentType;
  String hireDate;
  String paymentDate;
  String contractEndDate;
  int isUserRat;
  int isHireUserRat;
  String createdAt;
  String updatedAt;
  User user;
  List<Rating> rating;
  int isUserApplied;
  num servicePerc;
  num serviceFee;
  num receiving;
  num ratingAvg;
  int ratingCount;
  Rating jobUserRat;
  Rating postUserRat;
  HiredUser hiredUser;

  Data(
      {this.id,
      this.userId,
      this.isActive,
      this.isDeleted,
      this.hiredUserId,
      this.status,
      this.title,
      this.price,
      this.description,
      this.lat,
      this.long,
      this.location,
      this.image,
      this.paymentType,
      this.hireDate,
      this.paymentDate,
      this.contractEndDate,
      this.isUserRat,
      this.isHireUserRat,
      this.createdAt,
    this.updatedAt,
    this.user,
    this.rating,
    this.isUserApplied,
    this.servicePerc,
    this.serviceFee,
    this.receiving,
    this.ratingAvg,
    this.ratingCount,
    this.jobUserRat,
    this.postUserRat,
    this.hiredUser
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    isActive = json['is_active'];
    isDeleted = json['is_deleted'];
    hiredUserId = json['hired_user_id'];
    status = json['status'];
    title = json['title'];
    price = json['price'];
    description = json['description'];
    lat = json['lat'];
    long = json['long'];
    location = json['location'];
    image = json['image'];
    paymentType = json['payment_type'];
    hireDate = json['hire_date'];
    paymentDate = json['payment_date'];
    contractEndDate = json['contract_end_date'];
    isUserRat = json['is_user_rat'];
    isHireUserRat = json['is_hire_user_rat'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    if (json['rating'] != null) {
      rating = new List<Rating>();
      json['rating'].forEach((v) {
        rating.add(new Rating.fromJson(v));
      });
    }
    isUserApplied = json['is_user_applied'];
    servicePerc = json['service_perc'];
    serviceFee = json['service_fee'];
    receiving = json['receiving'];
    ratingAvg = json['rating_avg'];
    ratingCount = json['rating_count'];
    jobUserRat = json['job_user_rat'] != null
        ? new Rating.fromJson(json['job_user_rat'])
        : null;
    postUserRat = json['post_user_rat'] != null
        ? new Rating.fromJson(json['post_user_rat'])
        : null;
    hiredUser = json['hired_User'] != null
        ? new HiredUser.fromJson(json['hired_User'])
        : null;
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
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['location'] = this.location;
    data['image'] = this.image;
    data['payment_type'] = this.paymentType;
    data['hire_date'] = this.hireDate;
    data['payment_date'] = this.paymentDate;
    data['contract_end_date'] = this.contractEndDate;
    data['is_user_rat'] = this.isUserRat;
    data['is_hire_user_rat'] = this.isHireUserRat;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.rating != null) {
      data['rating'] = this.rating.map((v) => v.toJson()).toList();
    }
    data['is_user_applied'] = this.isUserApplied;
    data['service_perc'] = this.servicePerc;
    data['service_fee'] = this.serviceFee;
    data['receiving'] = this.receiving;
    data['rating_avg'] = this.ratingAvg;
    data['rating_count'] = this.ratingCount;
    if (this.jobUserRat != null) {
      data['job_user_rat'] = this.jobUserRat.toJson();
    }
    if (this.postUserRat != null) {
      data['post_user_rat'] = this.postUserRat.toJson();
    }
    if (this.hiredUser != null) {
      data['hired_User'] = this.hiredUser.toJson();
    }

    return data;
  }
}

class User {
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
  int isLocation;
  int isPhVerified;
  int isEmailVerified;
  int paymentMethod;
  int profilePicType;
  int isPassword;
  String deviceId;
  int isDeleted;
  int disablePush;
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
      this.isLocation,
      this.isPhVerified,
      this.isEmailVerified,
      this.paymentMethod,
      this.profilePicType,
      this.isPassword,
      this.deviceId,
      this.isDeleted,
      this.disablePush,
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
    isLocation = json['is_location'];
    isPhVerified = json['is_ph_verified'];
    isEmailVerified = json['is_email_verified'];
    paymentMethod = json['payment_method'];
    profilePicType = json['profile_pic_type'];
    isPassword = json['is_password'];
    deviceId = json['device_id'];
    isDeleted = json['is_deleted'];
    disablePush = json['disable_push'];
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
    data['is_deleted'] = this.isDeleted;
    data['disable_push'] = this.disablePush;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class HiredUser {
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
  int isDeleted;
  int disablePush;
  String createdAt;
  String updatedAt;

  HiredUser({this.id,
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
    this.isDeleted,
    this.disablePush,
    this.createdAt,
    this.updatedAt});

  HiredUser.fromJson(Map<String, dynamic> json) {
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
    isDeleted = json['is_deleted'];
    disablePush = json['disable_push'];
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
    data['is_deleted'] = this.isDeleted;
    data['disable_push'] = this.disablePush;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Rating {
  int id;
  int userId;
  int favourId;
  int ratedBy;
  int rating;
  String description;
  int isActive;
  String createdAt;
  String updatedAt;

  Rating(
      {this.id,
      this.userId,
      this.favourId,
      this.ratedBy,
      this.rating,
      this.description,
      this.isActive,
      this.createdAt,
      this.updatedAt});

  Rating.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    favourId = json['favour_id'];
    ratedBy = json['rated_by'];
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
    data['favour_id'] = this.favourId;
    data['rated_by'] = this.ratedBy;
    data['rating'] = this.rating;
    data['description'] = this.description;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
