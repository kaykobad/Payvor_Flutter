class PostForChat {
  String postId;
  String userId;
  int updatedAt;

  PostForChat({this.postId, this.userId, this.updatedAt});

  PostForChat.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    userId = json['userId'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['userId'] = this.userId;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}