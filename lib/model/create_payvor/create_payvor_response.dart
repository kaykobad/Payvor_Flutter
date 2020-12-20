class FavourCreateResponse {
  Status status;
  String success;
  Data data;

  FavourCreateResponse({this.status, this.success, this.data});

  FavourCreateResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    success = json['Success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    data['Success'] = this.success;
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
  int userId;
  int isActive;
  String title;
  String price;
  String description;
  String lat;
  String long;
  String location;
  String image;
  String updatedAt;
  String createdAt;
  int id;

  Data(
      {this.userId,
      this.isActive,
      this.title,
      this.price,
      this.description,
      this.lat,
      this.long,
      this.location,
      this.image,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    isActive = json['is_active'];
    title = json['title'];
    price = json['price'];
    description = json['description'];
    lat = json['lat'];
    long = json['long'];
    location = json['location'];
    image = json['image'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['is_active'] = this.isActive;
    data['title'] = this.title;
    data['price'] = this.price;
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['location'] = this.location;
    data['image'] = this.image;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
