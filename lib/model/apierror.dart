import 'dart:ui';

class APIError {
  String error;
  dynamic messag;
  int status;
  VoidCallback onAlertPop;

  APIError({this.error, this.status, this.messag, this.onAlertPop});

  APIError.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    messag = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.messag;
    return data;
  }
}
