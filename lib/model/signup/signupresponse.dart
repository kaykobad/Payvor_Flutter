

class SignupResponse {
  String token;
   //UserData user;

  SignupResponse({this.token});

  SignupResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'];
  //  user = json['user'] != null ? new UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
//    if (this.user != null) {
//      data['user'] = this.user.toJson();
//    }
    return data;
  }
}

