class DataModelPayment {
  int id;
  String price;
  String days;
  bool isSelect;

  DataModelPayment({this.price, this.isSelect, this.days, this.id});

  DataModelPayment.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    isSelect = json['isSelect'];
    days = json['days'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['isSelect'] = this.isSelect;
    data['days'] = this.days;
    data['id'] = this.id;

    return data;
  }
}
