import 'package:payvor/model/login/loginsignupreponse.dart';

class MyProfileResponse {
  Status status;
  Datas data;
  AppUser user;

  MyProfileResponse({this.status, this.data, this.user});

  MyProfileResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    data = json['data'] != null ? new Datas.fromJson(json['data']) : null;
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

class Datas {
  int currentPage;
  List<Data> data;
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

  Datas(
      {this.currentPage,
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

  Datas.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
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

class Data {
  int id;
  int userId;
  int categoryId;
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

/*  Hireduser hireduser;*/
  String jobType;
  Hireduser hiredby;

  Data(
      {this.id,
      this.userId,
      this.categoryId,
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
      /* this.hireduser,*/
      this.jobType,
      this.hiredby});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    categoryId = json['category_id'];
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
    /*  hireduser = json['hireduser'] != null
        ? new Hireduser.fromJson(json['hireduser'])
        : null;*/
    jobType = json['job_type'];
    hiredby = json['hiredby'] != null
        ? new Hireduser.fromJson(json['hiredby'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
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
    /*if (this.hireduser != null) {
      data['hireduser'] = this.hireduser.toJson();
    }*/
    data['job_type'] = this.jobType;
    if (this.hiredby != null) {
      data['hiredby'] = this.hiredby.toJson();
    }
    return data;
  }
}

class Hireduser {
  String name;

  Hireduser({this.name});

  Hireduser.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
