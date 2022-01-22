class MakePaymentRequest {
  String postId;
  String customer;
  String cardtoken;

  MakePaymentRequest({this.postId, this.customer, this.cardtoken});

  MakePaymentRequest.fromJson(Map<String, dynamic> json) {
    postId = json['post_id'];
    customer = json['customer'];
    cardtoken = json['cardtoken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['post_id'] = this.postId;
    data['customer'] = this.customer;
    data['cardtoken'] = this.cardtoken;
    return data;
  }
}
