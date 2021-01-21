class GiveRatingRequest {
  String favour_id;
  String rating;
  String description;

  GiveRatingRequest({this.favour_id, this.rating, this.description});

  GiveRatingRequest.fromJson(Map<String, dynamic> json) {
    favour_id = json['favour_id'];
    rating = json['rating'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['favour_id'] = this.favour_id;
    data['rating'] = this.rating;
    data['description'] = this.description;

    return data;
  }
}
