class MediaResponse {
  String id;
  String username;
  Media media;

  MediaResponse({this.id, this.username, this.media});

  MediaResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    media = json['media'] != null ? new Media.fromJson(json['media']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    if (this.media != null) {
      data['media'] = this.media.toJson();
    }
    return data;
  }
}

class Media {
  List<Data> data;
  Paging paging;

  Media({this.data, this.paging});

  Media.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    paging =
        json['paging'] != null ? new Paging.fromJson(json['paging']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    if (this.paging != null) {
      data['paging'] = this.paging.toJson();
    }
    return data;
  }
}

class Data {
  String id;

  Data({this.id});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    return data;
  }
}

class Paging {
  Cursors cursors;
  String next;

  Paging({this.cursors, this.next});

  Paging.fromJson(Map<String, dynamic> json) {
    cursors =
        json['cursors'] != null ? new Cursors.fromJson(json['cursors']) : null;
    next = json['next'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cursors != null) {
      data['cursors'] = this.cursors.toJson();
    }
    data['next'] = this.next;
    return data;
  }
}

class Cursors {
  String before;
  String after;

  Cursors({this.before, this.after});

  Cursors.fromJson(Map<String, dynamic> json) {
    before = json['before'];
    after = json['after'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['before'] = this.before;
    data['after'] = this.after;
    return data;
  }
}
