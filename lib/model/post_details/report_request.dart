class ReportPostRequest {
  String favour_id;

  ReportPostRequest({this.favour_id});

  ReportPostRequest.fromJson(Map<String, dynamic> json) {
    favour_id = json['favour_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['favour_id'] = this.favour_id;

    return data;
  }
}
