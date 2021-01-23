class HiredUserDetailsResponse {
  Status status;
  Data data;

  HiredUserDetailsResponse({this.status, this.data});

  HiredUserDetailsResponse.fromJson(Map<String, dynamic> json) {
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
  String createdAt;
  String updatedAt;
  Postedbyuser postedbyuser;
  HiredUser hiredUser;
  int servicePerc;
  num serviceFee;
  num receiving;
  num ratingAvg;
  int ratingCount;

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
      this.createdAt,
      this.updatedAt,
      this.postedbyuser,
      this.hiredUser,
      this.servicePerc,
      this.serviceFee,
      this.receiving,
      this.ratingAvg,
      this.ratingCount});

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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    postedbyuser = json['postedbyuser'] != null
        ? new Postedbyuser.fromJson(json['postedbyuser'])
        : null;
    hiredUser = json['hired_user'] != null
        ? new HiredUser.fromJson(json['hired_user'])
        : null;
    servicePerc = json['service_perc'];
    serviceFee = json['service_fee'];
    receiving = json['receiving'];
    ratingAvg = json['rating_avg'];
    ratingCount = json['rating_count'];
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.postedbyuser != null) {
      data['postedbyuser'] = this.postedbyuser.toJson();
    }
    if (this.hiredUser != null) {
      data['hired_user'] = this.hiredUser.toJson();
    }
    data['service_perc'] = this.servicePerc;
    data['service_fee'] = this.serviceFee;
    data['receiving'] = this.receiving;
    data['rating_avg'] = this.ratingAvg;
    data['rating_count'] = this.ratingCount;
    return data;
  }
}

class Postedbyuser {
  int id;
  String name;
  String email;
  String phone;
  num otp;
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

  Postedbyuser(
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

  Postedbyuser.fromJson(Map<String, dynamic> json) {
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

class HiredUser {
  int id;
  String name;
  String email;
  String phone;
  num otp;
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

  HiredUser(
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
