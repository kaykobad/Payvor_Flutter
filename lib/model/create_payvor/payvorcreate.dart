class PayvorCreateRequest {
  String title;
  String price;
  String description;
  String lat;
  String long;
  String location;

  PayvorCreateRequest(
      {this.title,
      this.price,
      this.description,
      this.lat,
      this.long,
      this.location});

  PayvorCreateRequest.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    price = json['price'];
    description = json['description'];
    lat = json['lat'];
    long = json['long'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['price'] = this.price;
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['location'] = this.location;
    return data;
  }
}
