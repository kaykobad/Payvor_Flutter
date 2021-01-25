class OtpRequest {
  String otp;
  String id;
  String type;

  OtpRequest({this.otp, this.id, this.type});

  OtpRequest.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    id = json['id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp'] = this.otp;
    data['id'] = this.id;
    data['type'] = this.type;
    return data;
  }
}
