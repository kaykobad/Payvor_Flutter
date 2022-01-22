class CurrentUserHiredByFavorResponse {
  Status status;
  List<DataNextJob> data;
  num favourapplied;

  CurrentUserHiredByFavorResponse({this.status, this.data, this.favourapplied});

  CurrentUserHiredByFavorResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    favourapplied = json['favourapplied'];
    if (json['data'] != null) {
      data = new List<DataNextJob>();
      json['data'].forEach((v) {
        data.add(new DataNextJob.fromJson(v));
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

    data['favourapplied'] = this.favourapplied;

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

class DataNextJob {
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
  String createdAt;
  String updatedAt;
  HiredBy hiredBy;

  DataNextJob(
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
      this.createdAt,
      this.updatedAt,
      this.hiredBy});

  DataNextJob.fromJson(Map<String, dynamic> json) {
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    hiredBy =
        json['hiredBy'] != null ? new HiredBy.fromJson(json['hiredBy']) : null;
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.hiredBy != null) {
      data['hiredBy'] = this.hiredBy.toJson();
    }
    return data;
  }
}

class HiredBy {
  String name;
  String profile_pic;

  HiredBy({this.name, this.profile_pic});

  HiredBy.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profile_pic = json['profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['profile_pic'] = this.profile_pic;
    return data;
  }
}
