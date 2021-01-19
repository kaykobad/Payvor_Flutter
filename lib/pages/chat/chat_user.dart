class ChatUser {
  String username;
  String userId;
  String profilePic;
  String lastMessage;
  num lastMessageTime;
  num unreadMessageCount;
  bool isGroup;
  bool isSelected;
  int pos;
  bool isOnline = false; //by default it's offline
  List<int> likedBy;
  num updatedAt;

  ChatUser(
      {this.username,
      this.userId,
      this.profilePic,
      this.lastMessage,
      this.lastMessageTime,
      this.unreadMessageCount,
      this.isGroup,
      this.likedBy});

  static ChatUser fromMap(Map<String, dynamic> data) {
    print(data.toString());
    ChatUser user = new ChatUser();
    user.username = data['username'];
    user.userId = data['userId'];
    user.profilePic = data['profilePic'];
    user.lastMessage = data['lastMessage'];
    user.lastMessageTime = data['lastMessageTime'];
    user.unreadMessageCount = data['unreadMessageCount'];
    user.isGroup = data['isGroup'];
    user.likedBy = data['likedby'];
    return user;
  }

  static ChatUser fromGroupToChatUserMap(Map<String, dynamic> data) {
    print(data.toString());
    ChatUser user = new ChatUser();
    user.username = data['group_name'] ?? "";
    user.userId = data['groupId'];
    user.profilePic = data['image'] ?? "";
    user.lastMessage = data['lastMessage'] ?? "";
    user.lastMessageTime = data['lastMessageTime'] ?? 0;
    //user.unreadMessageCount = data['unreadMessageCount'];
    user.isGroup = data['isGroup'];

    return user;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['userId'] = this.userId;
    data['profilePic'] = this.profilePic;
    data['lastMessage'] = this.lastMessage;
    data['lastMessageTime'] = this.lastMessageTime;
    data['unreadMessageCount'] = this.unreadMessageCount ?? 0;
    data['isGroup'] = this.isGroup;
    data['likedby'] = this.likedBy;
    data['updatedAt'] = updatedAt;

    return data;
  }
}
