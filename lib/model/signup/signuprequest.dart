class SignUpRequest {
  String fullName;
  String email;
  String password;
  String location;

  SignUpRequest({this.fullName, this.email, this.password, this.location});

  SignUpRequest.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
    email = json['email'];
    password = json['password'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full_name'] = this.fullName;
    data['email'] = this.email;
    data['password'] = this.password;
    data['location'] = this.location;
    return data;
  }
}
