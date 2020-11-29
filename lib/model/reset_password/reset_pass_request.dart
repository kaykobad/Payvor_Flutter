class ResetPasswordRequest {
  String new_pas;
  String cnf_pas;

  ResetPasswordRequest({this.new_pas, this.cnf_pas});

  ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    new_pas = json['new_pas'];
    cnf_pas = json['cnf_pas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['new_pas'] = this.new_pas;
    data['cnf_pas'] = this.cnf_pas;
    return data;
  }
}
