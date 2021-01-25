class OtpForgotRequest {
  String otp;
  String email;
  String type;

  OtpForgotRequest({this.otp, this.email, this.type});

  OtpForgotRequest.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    email = json['email'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp'] = this.otp;
    data['email'] = this.email;
    data['type'] = this.type;
    return data;
  }
}
