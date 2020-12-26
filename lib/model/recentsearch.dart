import 'package:flutter/cupertino.dart';

class RecentSearch {
  int id;
  String keyword;
  String createAt;

  RecentSearch(
      {this.id,
        this.keyword,
        this.createAt,
     });

  RecentSearch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    keyword = json['keyword'];
    createAt = json['createdAt'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['keyword'] = this.keyword;
    data['createdAt'] = this.createAt;

    return data;
  }
}