class DataModel {
  String name;
  bool isSelect;


  DataModel({this.name, this.isSelect});

  DataModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    isSelect = json['isSelect'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['isSelect'] = this.isSelect;

    return data;
  }
}