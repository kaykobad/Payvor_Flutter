class UpdateStatusRequest {
  String favour_id;
  String status;
  String payment_type;

  UpdateStatusRequest({this.favour_id, this.status, this.payment_type});

  UpdateStatusRequest.fromJson(Map<String, dynamic> json) {
    favour_id = json['favour_id'];
    status = json['rating'];
    payment_type = json['payment_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['favour_id'] = this.favour_id;
    data['rating'] = this.status;
    data['payment_type'] = this.payment_type;

    return data;
  }
}
