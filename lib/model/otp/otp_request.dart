class OtpRequest {
  String otp;
  String phone;

  OtpRequest({this.otp, this.phone});

  OtpRequest.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp'] = this.otp;
    data['phone'] = this.phone;
    return data;
  }
}
