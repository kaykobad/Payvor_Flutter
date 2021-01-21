import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/pages/chat/chat_user.dart';
import 'package:payvor/pages/chat/payvor_firebase_user.dart';
import 'package:payvor/pages/chat/payvor_group_chat.dart';
import 'package:payvor/pages/payment/firebase_constants.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseProvider with ChangeNotifier {
  var _isLoading = false;
  final List<dynamic> userList = List();
  var groupUserList = new Map<String, List<PayvorFirebaseUser>>();
  var firebaseUserList = new Map<String, PayvorFirebaseUser>();

  final List<int> myFriendsIdList = List();

  getLoading() => _isLoading;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void clearAllCache() {
    userList.clear();
    groupUserList.clear();
    firebaseUserList.clear();
    myFriendsIdList.clear();
  }

  Stream<List<ChatUser>> getChatFriends({@required String userId}) {
    var firestore = Firestore.instance
        .collection("chatfriends")
        .document(userId)
        .collection("friends")
        .orderBy('lastMessageTime', descending: true)
        .snapshots();

    StreamController<List<ChatUser>> controller =
    new StreamController<List<ChatUser>>();

    //get the data and convert to list
    firestore.listen((QuerySnapshot snapshot) {
      final List<ChatUser> productList =
      snapshot.documents.map((documentSnapshot) {
        return ChatUser.fromMap(documentSnapshot.data);
      }).toList();

      //remove if any item is null
      productList.removeWhere((product) => product == null);
      controller.add(productList);
    });

    return controller.stream;
  }

  Future<List<dynamic>> getUserChatAndGroups({@required int userId}) async {
    var firestore = Firestore.instance
        .collection("chatfriends")
        .document(userId.toString())
        .collection("friends")
        .orderBy('lastMessageTime', descending: true);

    var firestoreGroup = Firestore.instance
        .collection(GROUPS)
        .where('groupMembersId', arrayContains: userId);

    //read personal chat users

    var querySnapshots = await firestore.getDocuments();
    for (var document in querySnapshots.documents) {
      userList.add(ChatUser.fromMap(document.data));
    }

    //read group data
    var querySnapshotsGroup = await firestoreGroup.getDocuments();

    for (var document in querySnapshotsGroup.documents) {
      userList.add(FilmShapeFirebaseGroup.fromJson(document.data));
    }

    return userList;
  }

  Future<List<dynamic>> getFriends({@required String userId}) async {
    var firestore = Firestore.instance
        .collection("chatfriends")
        .document(userId)
        .collection("friends")
        .orderBy('lastMessageTime', descending: true);

    //read personal chat users

    var querySnapshots = await firestore.getDocuments();
    for (var document in querySnapshots.documents) {
      ChatUser chatUser = ChatUser.fromMap(document.data);
      myFriendsIdList.add(int.tryParse(chatUser.userId));
    }
    return myFriendsIdList;
  }

  Stream<List<PayvorFirebaseUser>> getActiveFriends(
      {@required List<int> userIds}) {
//    if(userIds.length==0)
//      userIds.add(0);//to avoid error
    print("friendlist ${userIds.join(",")}");
    var firestore = Firestore.instance
        .collection(USERS)
        .where("is_online", isEqualTo: true)
        .where("filmshape_id", whereIn: userIds)
//        .document(userId)
//        .collection("friends")
//        .orderBy('lastMessageTime', descending: true)
        .snapshots();

    var controller = new StreamController<List<PayvorFirebaseUser>>();

    //get the data and convert to list
    firestore.listen((QuerySnapshot snapshot) {
      final List<PayvorFirebaseUser> activeUsers =
      snapshot.documents.map((documentSnapshot) {
        return PayvorFirebaseUser.fromJson(documentSnapshot.data);
      }).toList();

      //saving quick access at some other screen
      for (var user in activeUsers) {
        firebaseUserList[user.filmShapeId.toString()] = user;
      }
      controller.add(activeUsers);
    });

    return controller.stream;
  }

  Future<List<PayvorFirebaseUser>> getGroupFriends(
      {@required List<int> userIds, @required String groupId}) async {
    var firestore = Firestore.instance
        .collection(USERS)
        .where("filmshape_id", whereIn: userIds);

    print("group_id $groupId userids ${userIds.join(",")}");
    var snapshot = await firestore.getDocuments();
    final List<PayvorFirebaseUser> groupUsers =
    snapshot.documents.map((documentSnapshot) {
      return PayvorFirebaseUser.fromJson(documentSnapshot.data);
    }).toList();

    groupUserList[groupId] = groupUsers; //save user for later quick access
    print("group_id $groupId memeber_received ${groupUsers.length}");
    return groupUsers;
  }

  Future<bool> checkGroupMemberIsAdmin(
      {@required String groupId, @required String userId}) async {
    var firestore = Firestore.instance
        .collection(GROUPS)
        .document(groupId)
        .collection(GROUP_MEMBERS)
        .document(userId);

    print("path ${firestore.path}");
    var document = await firestore.get();
    print("group member $groupId ,$userId");
    if (document.data == null) {
      print("no member found");
      return false;
    } else {
      print("member found");
      var member = FilmShapeFirebaseGroupMember.fromJson(document.data);
      return member.isAdmin;
    }
  }

  Future<PayvorFirebaseUser> getUserInfo({@required int userId}) async {
    var firestore = Firestore.instance
        .collection(USERS)
        .where("filmshape_id", isEqualTo: userId);

    var snapshot = await firestore.getDocuments();
    final List<PayvorFirebaseUser> groupUsers =
    snapshot.documents.map((documentSnapshot) {
      return PayvorFirebaseUser.fromJson(documentSnapshot.data);
    }).toList();

    //save for later quick access
    if (groupUsers.isNotEmpty) {
      var user = groupUsers.first;
      firebaseUserList[user.filmShapeId.toString()] = user;
    }
    return (groupUsers.isNotEmpty) ? groupUsers.first : null;
  }

  Future<void> updateGroupMessage({@required String message,
    @required num timestamp,
    @required String groupId}) {
    var document = Firestore.instance.collection(GROUPS).document(groupId);

    var dataMap = new Map<String, dynamic>();
    dataMap["lastMessage"] = message;
    dataMap["lastMessageTime"] = timestamp;
    document.updateData(dataMap);
  }

  Future<bool> addNewMembersToGroup(
      {@required FilmShapeFirebaseGroup filmShapeFirebaseGroup,
        @required List<FilmShapeFirebaseGroupMember> members,
        @required String groupId}) async {
    var document = Firestore.instance.collection(GROUPS).document(groupId);

    await document.setData(filmShapeFirebaseGroup.toJson(), merge: true);
    //save members
    for (var member in members) {
      await Firestore.instance
          .collection(GROUPS)
          .document(groupId)
          .collection(GROUP_MEMBERS)
          .document(member.userName)
          .setData(member.toJson());
    }
    hideLoader();
    return true;
  }

  @override
  Future createChatUser({@required ChatUser user, @required String userId}) {
    //var loginResponse = _getUserResponse();
    //  var userId = "0"; //add this current user friend list
    var userName = "";
    var profilePic = "";

    try {
      if (MemoryManagement.getUserInfo() != null) {
        var infoData = jsonDecode(MemoryManagement.getUserInfo());
        var userinfo = LoginSignupResponse.fromJson(infoData);
        userName = userinfo?.user?.name;
        profilePic = MemoryManagement.getImage() ?? "";
      }
    } catch (ex) {
      print("error ${ex.toString()}");
      return null;
    }

    _addUser(userId.toString(), user, userId.toString());

    //storing current user as friend to other user chat friend list

    var chatUser = new ChatUser();
    chatUser.username = userName;
    chatUser.userId = userId.toString();
    chatUser.profilePic = profilePic;
    chatUser.lastMessage = user.lastMessage;
    chatUser.lastMessageTime = user.lastMessageTime;
    chatUser.unreadMessageCount = user.unreadMessageCount;
    chatUser.isGroup = false;
    chatUser.updatedAt = new DateTime.now().millisecondsSinceEpoch;

    _addUser(user.userId, chatUser, userId.toString());
  }

  void _addUser(String userId, ChatUser user, String currentUserId) async {
    var document = Firestore.instance
        .collection("chatfriends")
        .document(userId)
        .collection("friends")
        .document(user.userId);

    //add  details
    await document.get().then((value) {
      //if user doesn't exist add new

      if (!value.exists) {
        if (currentUserId == userId) {
          user.unreadMessageCount = 0; //reset count
        }
        document.setData(user.toJson());
      } else {
        //other wise update the these 3 fields values
        var dataMap = new Map<String, dynamic>();
        dataMap["lastMessage"] = user.lastMessage;
        dataMap["lastMessageTime"] = user.lastMessageTime;
        if (user.profilePic.isNotEmpty) {
          dataMap["profilePic"] = user.profilePic;
        }
        dataMap["username"] = user.username;

        if (currentUserId != userId) {
          //if count is 1 increment it
          if (user.unreadMessageCount == 1)
            document.updateData({
              "unreadMessageCount": FieldValue.increment(1),
              "updatedAt": DateTime
                  .now()
                  .millisecondsSinceEpoch
            });
//TODO: Uncomment
        }

        document.updateData(dataMap);
      }
    }).catchError((error) {
      print("error" + error.toString());
    });
  }

  @override
  Future<bool> resetUnreadMessageCount(
      {@required String userId, @required String chatUserId}) async {
    var document = Firestore.instance
        .collection("chatfriends")
        .document(userId)
        .collection("friends")
        .document(chatUserId);

    await document.updateData({
      "unreadMessageCount": 0,
      "updatedAt": DateTime
          .now()
          .millisecondsSinceEpoch
    });
    return true;
  }

  @override
  Future<bool> updateDeviceToken({String deviceToken,
    String userId,
    @required String deviceType,
    @required String userName}) async {
    String deviceid = MemoryManagement.getuserId();

    var document =
    Firestore.instance.collection(Constants.FCM_DEVICE_TOKEN).document(userId);

    var documentDevices = Firestore.instance
        .collection(Constants.FCM_DEVICE_TOKEN)
        .document(userId)
        .collection(Constants.DEVICES)
        .document(deviceid);

    //save document to collection
    await document.setData(
        {"deviceType": deviceType, "userId": userId, "userName": userName});
    //save token to devices
    await documentDevices.setData({
      "fcmTokenId": deviceToken,
    });

    return true;
  }

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> createFirebaseUser(PayvorFirebaseUser PayvorFirebaseUser) async {
    var firebaseUser = await getCurrentUser();
    var document =
    Firestore.instance.collection(USERS).document(firebaseUser.uid);

    await document.setData(PayvorFirebaseUser.toJson());
  }

  Future<bool> createGroup(FilmShapeFirebaseGroup filmShapeFirebaseGroup,
      List<FilmShapeFirebaseGroupMember> members,) async {
    var document = Firestore.instance.collection(GROUPS).document();
    var documentId = document.documentID;
    filmShapeFirebaseGroup.groupId = documentId;
    await document.setData(filmShapeFirebaseGroup.toJson());
    //save members
    for (var member in members) {
      await Firestore.instance
          .collection(GROUPS)
          .document(documentId)
          .collection(GROUP_MEMBERS)
          .document(member.userId)
          .setData(member.toJson());
    }
    hideLoader();
    return true;
  }

  Future<bool> createGroupProject(FilmShapeFirebaseGroup filmShapeFirebaseGroup,
      List<FilmShapeFirebaseGroupMember> members, String groupId) async {
    var document = Firestore.instance.collection(GROUPS).document(groupId);

    filmShapeFirebaseGroup.groupId = groupId;
    await document.setData(filmShapeFirebaseGroup.toJson());
    //save members
    for (var member in members) {
      await Firestore.instance
          .collection(GROUPS)
          .document(groupId)
          .collection(GROUP_MEMBERS)
          .document()
          .setData(member.toJson());
    }
    hideLoader();
    return true;
  }

  Future<void> updateFirebaseUser(PayvorFirebaseUser PayvorFirebaseUser) async {
    var firebaseUser = await getCurrentUser();
    var document =
    Firestore.instance.collection(USERS).document(firebaseUser.uid);

    await document.updateData(PayvorFirebaseUser.toJson());
  }

  Future<void> updateUserOnlineOfflineStatus({@required bool status}) async {
    var firebaseUser = await getCurrentUser();
    var document =
    Firestore.instance.collection(USERS).document(firebaseUser.uid);
    var payvorFirebaseUser = PayvorFirebaseUser(isOnline: status);
    return await document.updateData(payvorFirebaseUser.toJson());
  }


  Future<bool> privateChatLikedUnliked(bool status, String chatId,
      String commentId, int userId) async {
    var firestore = Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .collection(ITEMS)
        .document(commentId);

    print("path of like ${firestore.path}");
    var ids = List<int>();
    ids.add(userId);
    print("id ${ids.join(",")} $status");
    if (!status) //for like
        {
      print("like aadd");

      await firestore.updateData({"likedby": FieldValue.arrayUnion(ids)});

      return true;
    } else {
      print("like remove");
      await firestore.updateData({"likedby": FieldValue.arrayRemove(ids)});
      return false;
    }
  }


  void hideLoader() {
    print(_isLoading);
    _isLoading = false;
    notifyListeners();
  }

  void setLoading() {
    print(_isLoading);
    _isLoading = true;
    notifyListeners();
  }
}
