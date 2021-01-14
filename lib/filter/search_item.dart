class DataModelReport {
  bool isSelect;
  String sendTitle;

  DataModelReport({this.isSelect, this.sendTitle});

  DataModelReport.fromJson(Map<String, dynamic> json) {
    isSelect = json['isSelect'];
    sendTitle = json['sendTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isSelect'] = this.isSelect;
    data['sendTitle'] = this.sendTitle;

    return data;
  }
}
