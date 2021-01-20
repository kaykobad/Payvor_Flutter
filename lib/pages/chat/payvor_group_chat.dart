class FilmShapeFirebaseGroup {
  String groupId;
  String createdBy;
  String createdAt;
  String updatedAt;
  String groupName;
  num groupTotalMembers;
  String groupThumbnail;
  List<int> groupMembersId;
  String lastMessage;
  num lastMessageTime;
  String membersName;
  String creatorProfilePic;

  FilmShapeFirebaseGroup({
    this.createdAt,
    this.updatedAt,
    this.groupThumbnail,
    this.groupName,
    this.groupId,
    this.createdBy,
    this.groupTotalMembers,
    this.groupMembersId,
    this.lastMessage,
    this.lastMessageTime,
  });

  FilmShapeFirebaseGroup.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    groupThumbnail = json['groupThumbnailUrl'];
    groupName = json['groupName'];
    groupTotalMembers = json['groupTotalMembers'];
    createdBy = json['createdBy'];
    groupMembersId = new List<int>.from(json['groupMembersId']);
    lastMessage = json['lastMessage'] ?? "";
    lastMessageTime = json['lastMessageTime'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (groupId != null) data['groupId'] = groupId;
    if (createdAt != null) data['createdAt'] = createdAt;
    if (updatedAt != null) data['updatedAt'] = updatedAt;
    if (groupThumbnail != null) data['groupThumbnailUrl'] = groupThumbnail;
    if (groupName != null) data['groupName'] = groupName;
    if (groupTotalMembers != null)
      data['groupTotalMembers'] = groupTotalMembers;
    if (createdBy != null) data['createdBy'] = createdBy;
    if (groupMembersId != null) data['groupMembersId'] = groupMembersId;
    if (lastMessage != null) data['lastMessage'] = this.lastMessage;
    if (lastMessageTime != null) data['lastMessageTime'] = this.lastMessageTime;
    return data;
  }
}

class FilmShapeFirebaseGroupMember {
  bool isAdmin;
  String createdAt;
  String updatedAt;
  bool isBlocked;
  String userId;
  String userName;
  String profilePic;

  FilmShapeFirebaseGroupMember(
      {this.createdAt,
      this.updatedAt,
      this.isAdmin,
      this.isBlocked,
      this.userId,
      this.userName,
      this.profilePic});

  FilmShapeFirebaseGroupMember.fromJson(Map<String, dynamic> json) {
    isAdmin = json['isAdmin'];
    createdAt = json['createdAat'];
    updatedAt = json['updatedAt'];
    isBlocked = json['isBlocked'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (isAdmin != null) data['isAdmin'] = isAdmin;
    if (createdAt != null) data['createdAt'] = createdAt;
    if (updatedAt != null) data['updatedAt'] = updatedAt;
    if (isBlocked != null) data['isBlocked'] = isBlocked;
    if (userId != null) data['userId'] = userId;
    if (userName != null) data['userName'] = userName;
    if (profilePic != null) data['profilePic'] = profilePic;

    return data;
  }
}
