class GetFavorListResponse {
  Status status;
  String success;
  Data data;

  GetFavorListResponse({this.status, this.success, this.data});

  GetFavorListResponse.fromJson(Map<String, dynamic> json) {
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
  int currentPage;
  List<Datas> data;
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
      data = new List<Datas>();
      json['data'].forEach((v) {
        data.add(new Datas.fromJson(v));
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

class Datas {
  int id;
  int userId;
  int isActive;
  String title;
  String price;
  String description;
  String lat;
  String long;
  String distance;
  String location;
  String image;
  String createdAt;
  String updatedAt;
  User user;

  Datas(
      {this.id,
      this.userId,
      this.isActive,
      this.title,
      this.price,
      this.description,
      this.distance,
      this.lat,
      this.long,
      this.location,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.user});

  Datas.fromJson(Map<String, dynamic> json) {
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
    distance = json['distance'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
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
    data['distance'] = this.distance;
    data['long'] = this.long;
    data['location'] = this.location;
    data['image'] = this.image;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  String name;
  String email;
  String profilePic;
  int isActive;
  num perc;
  String location;

  User(
      {this.name,
      this.email,
      this.profilePic,
      this.isActive,
      this.location,
      this.perc});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    profilePic = json['profile_pic'];
    isActive = json['is_active'];
    location = json['location'];
    perc = json['perc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['profile_pic'] = this.profilePic;
    data['is_active'] = this.isActive;
    data['location'] = this.location;
    data['perc'] = this.perc;
    return data;
  }
}