class EndedJobHireResponse {
  Status status;
  List<Data> data;

  EndedJobHireResponse({this.status, this.data});

  EndedJobHireResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
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
  num perc;
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
  String profile_pic;
  String contractEndDate;
  String createdAt;
  String updatedAt;
  Hired hired;

  Data(
      {this.id,
      this.userId,
      this.isActive,
      this.isDeleted,
      this.hiredUserId,
      this.perc,
      this.status,
      this.profile_pic,
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
      this.hired});

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
    perc = json['perc'];
    profile_pic = json['profile_pic'];
    long = json['long'];
    location = json['location'];
    image = json['image'];
    paymentType = json['payment_type'];
    hireDate = json['hire_date'];
    paymentDate = json['payment_date'];
    contractEndDate = json['contract_end_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    hired = json['hired'] != null ? new Hired.fromJson(json['hired']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['is_active'] = this.isActive;
    data['is_deleted'] = this.isDeleted;
    data['hired_user_id'] = this.hiredUserId;
    data['perc'] = this.perc;
    data['status'] = this.status;
    data['title'] = this.title;
    data['price'] = this.price;
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['profile_pic'] = this.profile_pic;
    data['location'] = this.location;
    data['image'] = this.image;
    data['payment_type'] = this.paymentType;
    data['hire_date'] = this.hireDate;
    data['payment_date'] = this.paymentDate;
    data['contract_end_date'] = this.contractEndDate;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.hired != null) {
      data['hired'] = this.hired.toJson();
    }
    return data;
  }
}

class Hired {
  String name;

  Hired({this.name});

  Hired.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
