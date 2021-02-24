class SendNotificationRequest {
  String reciver_id;
  String message;

  SendNotificationRequest({this.reciver_id, this.message});

  SendNotificationRequest.fromJson(Map<String, dynamic> json) {
    reciver_id = json['reciver_id'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reciver_id'] = this.reciver_id;
    data['message'] = this.message;
    return data;
  }
}
