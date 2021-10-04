class UpdateTokenRequest {
  String user_id;
  String device_id;

  UpdateTokenRequest({this.user_id, this.device_id});

  UpdateTokenRequest.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'];
    device_id = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.user_id;
    data['device_id'] = this.device_id;
    return data;
  }
}

class AddStripeRequest {
  String strtoken;

  AddStripeRequest({this.strtoken});

  AddStripeRequest.fromJson(Map<String, dynamic> json) {
    strtoken = json['strtoken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['strtoken'] = this.strtoken;
    return data;
  }
}
