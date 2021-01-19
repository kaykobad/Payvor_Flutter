class PayvorFirebaseUser {
  int filmShapeId;
  String firebaseId;
  String created;
  String updated;
  String email;
  String gender;
  String thumbnailUrl;
  String location;
  String fullName;
  bool isOnline;
  String bio;
  List<dynamic> roles;

  PayvorFirebaseUser(
      {this.created,
      this.updated,
      this.thumbnailUrl,
      this.location,
      this.fullName,
      this.gender,
      this.email,
      this.firebaseId,
      this.filmShapeId,
      this.isOnline,
      this.bio,
      this.roles});

  PayvorFirebaseUser.fromJson(Map<String, dynamic> json) {
    filmShapeId = json['filmshape_id'];
    firebaseId = json['firebase_id'];
    created = json['created'];
    updated = json['updated'];
    thumbnailUrl = json['thumbnail_url'];
    email = json['email'];
    location = json['location'];
    fullName = json['full_name'];
    gender = json['gender'];
    isOnline = json['is_online'];
    bio = json['bio'];
    roles = json['roles'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (filmShapeId != null) data['filmshape_id'] = filmShapeId;
    if (firebaseId != null) data['firebase_id'] = firebaseId;
    if (created != null) data['created'] = created;
    if (updated != null) data['updated'] = updated;
    if (email != null) data['email'] = email;

    if (thumbnailUrl != null) data['thumbnail_url'] = thumbnailUrl;
    if (location != null) data['location'] = location;
    if (fullName != null) data['full_name'] = fullName;
    if (gender != null) data['gender'] = gender;
    if (isOnline != null) data['is_online'] = isOnline;
    if (bio != null) data['bio'] = bio;
    if (roles != null) data['roles'] = roles;
    return data;
  }
}
