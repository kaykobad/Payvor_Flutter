class ReferUserRequest {
  String user_id;
  String favour_id;
  String description;

  ReferUserRequest({this.user_id, this.favour_id, this.description});

  ReferUserRequest.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'];
    favour_id = json['favour_id'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.user_id;
    data['favour_id'] = this.favour_id;
    data['description'] = this.description;

    return data;
  }
}
