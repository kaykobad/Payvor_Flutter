class PropmoteDataResponse {
  Status status;
  List<DataPromotion> data;

  PropmoteDataResponse({this.status, this.data});

  PropmoteDataResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['data'] != null) {
      data = new List<DataPromotion>();
      json['data'].forEach((v) {
        data.add(new DataPromotion.fromJson(v));
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

class DataPromotion {
  int id;
  String type;
  int price;
  String title;
  String validity;
  String createdAt;
  String updatedAt;
  bool isSelect;

  DataPromotion(
      {this.id,
      this.type,
      this.price,
      this.title,
      this.validity,
      this.createdAt,
      this.updatedAt,
      this.isSelect});

  DataPromotion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    price = json['price'];
    title = json['title'];
    validity = json['validity'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['price'] = this.price;
    data['title'] = this.title;
    data['validity'] = this.validity;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
