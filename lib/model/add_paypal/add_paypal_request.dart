class PayPalAddRequest {
  String paypal_id;
  String user_id;

  PayPalAddRequest({this.paypal_id, this.user_id});

  PayPalAddRequest.fromJson(Map<String, dynamic> json) {
    paypal_id = json['paypal_id'];
    user_id = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paypal_id'] = this.paypal_id;
    data['user_id'] = this.user_id;
    return data;
  }
}
