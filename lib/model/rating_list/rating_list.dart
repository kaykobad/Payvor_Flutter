class RatingReviewResponse {
  Status status;
  List<DataRating> data;

  RatingReviewResponse({this.status, this.data});

  RatingReviewResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['data'] != null) {
      data = new List<DataRating>();
      json['data'].forEach((v) {
        data.add(new DataRating.fromJson(v));
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

class DataRating {
  int id;
  int userId;
  int favourId;
  int ratedBy;
  num rating;
  String description;
  int isActive;
  String createdAt;
  String updatedAt;
  String name;
  String profilePic;

  DataRating(
      {this.id,
      this.userId,
      this.favourId,
      this.ratedBy,
      this.rating,
      this.description,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.name,
      this.profilePic});

  DataRating.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    favourId = json['favour_id'];
    ratedBy = json['rated_by'];
    rating = json['rating'];
    description = json['description'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    name = json['name'];
    profilePic = json['profile_pic'];
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
    data['name'] = this.name;
    data['profile_pic'] = this.profilePic;
    return data;
  }
}
