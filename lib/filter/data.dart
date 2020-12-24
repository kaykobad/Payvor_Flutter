class DataModel {
  int id;
  String name;
  String sendTitle;
  bool isSelect;

  DataModel({this.name, this.isSelect, this.sendTitle, this.id});

  DataModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    isSelect = json['isSelect'];
    sendTitle = json['sendTitle'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['isSelect'] = this.isSelect;
    data['sendTitle'] = this.sendTitle;
    data['id'] = this.id;

    return data;
  }
}