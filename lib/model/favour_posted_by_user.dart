class FavourPostedByUserResponse {
  Status status;
  List<DataFavour> data;

  FavourPostedByUserResponse({this.status, this.data});

  FavourPostedByUserResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['data'] != null) {
      data = new List<DataFavour>();
      json['data'].forEach((v) {
        data.add(new DataFavour.fromJson(v));
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

class DataFavour {
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
  int applied_count;

  DataFavour({
    this.id,
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
    this.applied_count,
  });

  DataFavour.fromJson(Map<String, dynamic> json) {
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
    applied_count = json['applied_count'];
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
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['location'] = this.location;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['applied_count'] = this.applied_count;
    return data;
  }
}
