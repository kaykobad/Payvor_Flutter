class RecentSearch {
  String id;
  String keyword;
  String createdAt;

  RecentSearch({this.id,
    this.keyword,
    this.createdAt,
  });

  RecentSearch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    keyword = json['keyword'];
    createdAt = json['createdAt'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['keyword'] = this.keyword;
    data['createdAt'] = this.createdAt;

    return data;
  }
}