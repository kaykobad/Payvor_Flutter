import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_for_chat.dart';
import 'package:payvor/networkmodel/APIHandler.dart';
import 'package:payvor/networkmodel/APIs.dart';
import 'package:payvor/pages/chat/chat_user.dart';
import 'package:payvor/pages/chat/payvor_firebase_user.dart';
import 'package:payvor/pages/chat/payvor_group_chat.dart';
import 'package:payvor/pages/chat/send_noti_request.dart';
import 'package:payvor/pages/payment/firebase_constants.dart';
import 'package:payvor/pages/search/search_home.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';

class FirebaseProvider with ChangeNotifier {
  var _isLoading = false;
  StreamController<bool> notificationStreamController;
  BuildContext _homeContext;

  GlobalKey<HomeState> myKey;

  void setHomeContextKey(Key key) {
    myKey = key;
  }

  GlobalKey<HomeState> getHomeKey() {
    return myKey;
  }

  void setHomeContext(BuildContext context) {
    _homeContext = context;
  }

  void changeScreen(Widget screen, {bool rootNavigator=false}) {
    Navigator.of(_homeContext, rootNavigator: rootNavigator).push(
      CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: screen);
      }),
    );
  }

//  final List<dynamic> userList = List();
//  var groupUserList = new Map<String, List<PayvorFirebaseUser>>();
//  var firebaseUserList = new Map<String, PayvorFirebaseUser>();
//
//  final List<int> myFriendsIdList = List();

  void setStreamNotifier(StreamController<bool> streamController) {
    notificationStreamController = streamController;
  }

  getLoading() => _isLoading;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void clearAllCache() {
//    userList.clear();
//    groupUserList.clear();
//    firebaseUserList.clear();
//    myFriendsIdList.clear();
  }

  Stream<List<ChatUser>> getChatFriends(
      {@required String userId, String name}) {
    var firestore = FirebaseFirestore.instance
        .collection("chatfriends")
        .doc(userId)
        .collection("friends")
        .orderBy('lastMessageTime', descending: true)
        .snapshots();

    StreamController<List<ChatUser>> controller =
        new StreamController<List<ChatUser>>();

    //get the data and convert to list
    firestore.listen((QuerySnapshot snapshot) {
      final List<ChatUser> productList =
      snapshot.docs.map((documentSnapshot) {
        return ChatUser.fromMap(documentSnapshot.data());
      }).toList();

      //remove if any item is null
      productList.removeWhere((product) => product == null);
      controller.add(productList);
    });

    return controller.stream;
  }

  Future<List<ChatUser>> getChatFriendsList({@required String userId}) async {
    var firestore = FirebaseFirestore.instance
        .collection("chatfriends")
        .doc(userId)
        .collection("friends")
        .orderBy('lastMessageTime', descending: true);

//    StreamController<List<ChatUser>> controller =
//    new StreamController<List<ChatUser>>();
//
//    //get the data and convert to list
//    firestore.listen((QuerySnapshot snapshot) {
//      final List<ChatUser> productList =
//      snapshot.documents.map((documentSnapshot) {
//        return ChatUser.fromMap(documentSnapshot.data);
//      }).toList();
//
//      //remove if any item is null
//      productList.removeWhere((product) => product == null);
//      controller.add(productList);
//    });

    List<ChatUser> chatUserList=[];
    var querySnapshots = await firestore.get();
    for (var document in querySnapshots.docs) {
      var chatUser = ChatUser.fromMap(document.data());
      chatUserList.add(chatUser);
    }

    return chatUserList;
  }

//  Future<List<dynamic>> getUserChatAndGroups({@required int userId}) async {
//    var firestore = Firestore.instance
//        .collection("chatfriends")
//        .document(userId.toString())
//        .collection("friends")
//        .orderBy('lastMessageTime', descending: true);
//
//    var firestoreGroup = Firestore.instance
//        .collection(GROUPS)
//        .where('groupMembersId', arrayContains: userId);
//
//    //read personal chat users
//
//    var querySnapshots = await firestore.getDocuments();
//    for (var document in querySnapshots.documents) {
//      userList.add(ChatUser.fromMap(document.data));
//    }
//
//    //read group data
//    var querySnapshotsGroup = await firestoreGroup.getDocuments();
//
//    for (var document in querySnapshotsGroup.documents) {
//      userList.add(FilmShapeFirebaseGroup.fromJson(document.data));
//    }
//
//    return userList;
//  }

//  Future<List<dynamic>> getFriends({@required String userId}) async {
//    var firestore = Firestore.instance
//        .collection("chatfriends")
//        .document(userId)
//        .collection("friends")
//        .orderBy('lastMessageTime', descending: true);
//
//    //read personal chat users
//
//    var querySnapshots = await firestore.getDocuments();
//    for (var document in querySnapshots.documents) {
//      ChatUser chatUser = ChatUser.fromMap(document.data);
//      myFriendsIdList.add(int.tryParse(chatUser.userId));
//    }
//    return myFriendsIdList;
//  }

  Future<List<PayvorFirebaseUser>> getFriendsProfile(
      {@required List<int> userIds}) async {
    print("friendlist ${userIds.join(",")}");
    var firestore = FirebaseFirestore.instance
        .collection(USERS)
        .where("filmshape_id", whereIn: userIds);

    //get the data and convert to list
    List<PayvorFirebaseUser> userList = [];
    var querySnapshots = await firestore.get();
    for (var document in querySnapshots.docs) {
      var firebaseUser = PayvorFirebaseUser.fromJson(document.data());
      userList.add(firebaseUser);
      print("payvouruser ${firebaseUser.toJson()}");

    }

    return userList;
  }

//  Future<List<PayvorFirebaseUser>> getGroupFriends(
//      {@required List<int> userIds, @required String groupId}) async {
//    var firestore = Firestore.instance
//        .collection(USERS)
//        .where("filmshape_id", whereIn: userIds);
//
//    print("group_id $groupId userids ${userIds.join(",")}");
//    var snapshot = await firestore.getDocuments();
//    final List<PayvorFirebaseUser> groupUsers =
//    snapshot.documents.map((documentSnapshot) {
//      return PayvorFirebaseUser.fromJson(documentSnapshot.data);
//    }).toList();
//
//    groupUserList[groupId] = groupUsers; //save user for later quick access
//    print("group_id $groupId memeber_received ${groupUsers.length}");
//    return groupUsers;
//  }

  Future<bool> checkGroupMemberIsAdmin(
      {@required String groupId, @required String userId}) async {
    var firestore = FirebaseFirestore.instance
        .collection(GROUPS)
        .doc(groupId)
        .collection(GROUP_MEMBERS)
        .doc(userId);

    print("path ${firestore.path}");
    var document = await firestore.get();
    print("group member $groupId ,$userId");
    if (document.data == null) {
      print("no member found");
      return false;
    } else {
      print("member found");
      var member = FilmShapeFirebaseGroupMember.fromJson(document.data());
      return member.isAdmin;
    }
  }

//  Future<PayvorFirebaseUser> getUserInfo({@required int userId}) async {
//    var firestore = Firestore.instance
//        .collection(USERS)
//        .where("filmshape_id", isEqualTo: userId);
//
//    var snapshot = await firestore.getDocuments();
//    final List<PayvorFirebaseUser> groupUsers =
//    snapshot.documents.map((documentSnapshot) {
//      return PayvorFirebaseUser.fromJson(documentSnapshot.data);
//    }).toList();
//
//    //save for later quick access
//    if (groupUsers.isNotEmpty) {
//      var user = groupUsers.first;
//      firebaseUserList[user.filmShapeId.toString()] = user;
//    }
//    return (groupUsers.isNotEmpty) ? groupUsers.first : null;
//  }

  Future<void> updateGroupMessage({@required String message,
    @required num timestamp,
    @required String groupId}) {
    var document = FirebaseFirestore.instance.collection(GROUPS).doc(groupId);

    var dataMap = new Map<String, dynamic>();
    dataMap["lastMessage"] = message;
    dataMap["lastMessageTime"] = timestamp;
    document.update(dataMap);
  }

  Future<bool> addNewMembersToGroup(
      {@required FilmShapeFirebaseGroup filmShapeFirebaseGroup,
        @required List<FilmShapeFirebaseGroupMember> members,
        @required String groupId}) async {
    var document = FirebaseFirestore.instance.collection(GROUPS).doc(groupId);

    await document.set(
        filmShapeFirebaseGroup.toJson(), SetOptions(merge: true));
    //save members
    for (var member in members) {
      await FirebaseFirestore.instance
          .collection(GROUPS)
          .doc(groupId)
          .collection(GROUP_MEMBERS)
          .doc(member.userName)
          .set(member.toJson());
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

  Future<dynamic> sendNotification(
      {@required SendNotificationRequest notificationRequest,
      @required BuildContext context}) async {
    Completer<dynamic> completer = new Completer<dynamic>();

    var response = await APIHandler.post(
      context: context,
      requestBody: notificationRequest,
      url: APIs.sendNotification,
    );

    if (response is APIError) {
      completer.complete(response);
      return completer.future;
    } else {
      ReportResponse sendNotificationResponse =
          new ReportResponse.fromJson(response);
      completer.complete(sendNotificationResponse);
      return completer.future;
    }
  }

  void _addUser(String userId, ChatUser user, String currentUserId) async {
    var document = FirebaseFirestore.instance
        .collection("chatfriends")
        .doc(userId)
        .collection("friends")
        .doc(user.userId);

    //add  details
    await document.get().then((value) {
      //if user doesn't exist add new

      if (!value.exists) {
        if (currentUserId == userId) {
          user.unreadMessageCount = 0; //reset count
        }
        document.set(user.toJson());
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
            document.update({
              "unreadMessageCount": FieldValue.increment(1),
              "updatedAt": DateTime
                  .now()
                  .millisecondsSinceEpoch
            });

        }

        document.update(dataMap);
      }
    }).catchError((error) {
      print("error" + error.toString());
    });
  }

  @override
  Future<bool> resetUnreadMessageCount(
      {@required String userId, @required String chatUserId}) async {
    var document = FirebaseFirestore.instance
        .collection("chatfriends")
        .doc(userId)
        .collection("friends")
        .doc(chatUserId);

    try {
      await document.update({
        "unreadMessageCount": 0,
        "updatedAt": DateTime
            .now()
            .millisecondsSinceEpoch
      });
    }
    catch(ex)
    {

    }
    return true;
  }

  @override
  Future<bool> updateDeviceToken({String deviceToken,
    String userId,
    @required String deviceType,
    @required String userName}) async {
    String deviceid ="";// MemoryManagement.getuserId();

    var document =
    FirebaseFirestore.instance.collection(Constants.FCM_DEVICE_TOKEN).doc(userId);

    var documentDevices = FirebaseFirestore.instance
        .collection(Constants.FCM_DEVICE_TOKEN)
        .doc(userId)
        .collection(Constants.DEVICES)
        .doc(deviceid);

    //save document to collection
    await document.set(
        {"deviceType": deviceType, "userId": userId, "userName": userName});
    //save token to devices
    await documentDevices.set({
      "fcmTokenId": deviceToken,
    });

    return true;
  }

  Future<String> signIn(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    User user = userCredential.user;

    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    User user = userCredential.user;

    return user.uid;
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> createFirebaseUser(PayvorFirebaseUser PayvorFirebaseUser) async {
    var firebaseUser = await getCurrentUser();
    var document =
        FirebaseFirestore.instance.collection(USERS).doc(firebaseUser.uid);

    await document.set(PayvorFirebaseUser.toJson());
  }

  Future<bool> createGroup(FilmShapeFirebaseGroup filmShapeFirebaseGroup,
      List<FilmShapeFirebaseGroupMember> members,) async {
    var document = FirebaseFirestore.instance.collection(GROUPS).doc();
    var documentId = document.id;
    filmShapeFirebaseGroup.groupId = documentId;
    await document.set(filmShapeFirebaseGroup.toJson());
    //save members
    for (var member in members) {
      await FirebaseFirestore.instance
          .collection(GROUPS)
          .doc(documentId)
          .collection(GROUP_MEMBERS)
          .doc(member.userId)
          .set(member.toJson());
    }
    hideLoader();
    return true;
  }

  Future<bool> createGroupProject(FilmShapeFirebaseGroup filmShapeFirebaseGroup,
      List<FilmShapeFirebaseGroupMember> members, String groupId) async {
    var document = FirebaseFirestore.instance.collection(GROUPS).doc(groupId);

    filmShapeFirebaseGroup.groupId = groupId;
    await document.set(filmShapeFirebaseGroup.toJson());
    //save members
    for (var member in members) {
      await FirebaseFirestore.instance
          .collection(GROUPS)
          .doc(groupId)
          .collection(GROUP_MEMBERS)
          .doc()
          .set(member.toJson());
    }
    hideLoader();
    return true;
  }

  Future<void> updateFirebaseUser(PayvorFirebaseUser PayvorFirebaseUser) async {
    var firebaseUser = await getCurrentUser();
    var document =
        FirebaseFirestore.instance.collection(USERS).doc(firebaseUser.uid);

    await document.update(PayvorFirebaseUser.toJson());
  }

  Future<DocumentSnapshot> getFirebaseUser(String userId) async {
    // var firebaseUser = await getCurrentUser();
    var document = FirebaseFirestore.instance
        .collection(USERS)
        .where("filmshape_id", isEqualTo: userId);
    await document.get();
  }

  Future<void> updateUserOnlineOfflineStatus({@required bool status}) async {
    var firebaseUser = await getCurrentUser();
    var document = FirebaseFirestore.instance
        .collection(CHATFRIENDS)
        .doc(firebaseUser.uid);
    var payvorFirebaseUser = PayvorFirebaseUser(isOnline: status);
    return await document.update(payvorFirebaseUser.toJson());
  }

  Future<void> updateUserProfilePic({@required String profilePic}) async {
    var firebaseUser = await getCurrentUser();
    var document = FirebaseFirestore.instance
        .collection(USERS)
        .doc(firebaseUser.uid);
   // print("userfirebaseid ${firebaseUser.uid}");
    var payvorFirebaseUser = PayvorFirebaseUser(thumbnailUrl: profilePic);
    return await document.update(payvorFirebaseUser.toJson());
  }

  Future<void> deleteFriend(
      {@required String userId, @required String friendId}) async {
    var document = FirebaseFirestore.instance
        .collection(CHATFRIENDS)
        .doc(userId)
        .collection(FRIENDS)
        .doc(friendId);
    print("path ${document.path}");
    return await document.delete();
  }

  Future<bool> privateChatLikedUnliked(
      bool status, String chatId, String commentId, int userId) async {
    var firestore = FirebaseFirestore.instance
        .collection(MESSAGES)
        .doc(chatId)
        .collection(ITEMS)
        .doc(commentId);

    print("path of like ${firestore.path}");
    var ids = List<int>();
    ids.add(userId);
    print("id ${ids.join(",")} $status");
    if (!status) //for like
        {
      print("like aadd");

      await firestore.update({"likedby": FieldValue.arrayUnion(ids)});

      return true;
    } else {
      print("like remove");
      await firestore.update({"likedby": FieldValue.arrayRemove(ids)});
      return false;
    }
  }

  @override
  Future<bool> insertPostInfoForChat(
      {@required PostForChat request, @required String documentId}) async {
    await FirebaseFirestore.instance
        .collection(FAVOURS)
        .doc(documentId)
        .set(request.toJson());
    return true;
  }

  Future<PostForChat> getPostInfoForChat({@required String documentId}) async {
    var document = FirebaseFirestore.instance.collection(FAVOURS).doc(documentId);
    var documentData = await document.get();
    return PostForChat.fromJson(documentData.data());
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
