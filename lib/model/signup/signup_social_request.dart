class SignUpSocialRequest {
  String name;
  String email;
  String profile_pic;
  String type;
  String snsId;

  SignUpSocialRequest(
      {this.name, this.email, this.profile_pic, this.type, this.snsId});

  SignUpSocialRequest.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    profile_pic = json['profile_pic'];
    type = json['type'];
    snsId = json['snsId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['profile_pic'] = this.profile_pic;
    data['type'] = this.type;
    data['snsId'] = this.snsId;
    return data;
  }
}
