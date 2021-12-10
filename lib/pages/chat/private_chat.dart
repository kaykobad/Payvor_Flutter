import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payvor/model/post_details/report_post_response.dart';
import 'package:payvor/model/post_for_chat.dart';
import 'package:payvor/pages/chat/chat_user.dart';
import 'package:payvor/pages/chat/send_noti_request.dart';
import 'package:payvor/pages/chat_message_details.dart';
import 'package:payvor/pages/payment/chat_bubble_image_left.dart';
import 'package:payvor/pages/payment/chat_bubble_image_right.dart';
import 'package:payvor/pages/payment/chat_bubble_left.dart';
import 'package:payvor/pages/payment/chat_bubble_right.dart';
import 'package:payvor/pages/payment/chat_input_widgetr.dart';
import 'package:payvor/pages/payment/firebase_constants.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/common_dialog.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:payvor/utils/timeago.dart';
import 'package:provider/provider.dart';

class ChoicePrivate {
  const ChoicePrivate({this.title, this.icon});

  final String title;
  final IconData icon;
}

class ChoiceGroup {
  const ChoiceGroup({this.title, this.icon});

  final String title;
  final IconData icon;
}

class PrivateChat extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String userName;
  final bool isGroup;
  final String currentUserId;
  final String currentUserName;
  final String currentUserProfilePic;
  String bio;
  bool isOnline;
  String postId;

  PrivateChat(
      {Key key,
      @required this.peerId,
      @required this.currentUserId,
      @required this.peerAvatar,
      @required this.userName,
      @required this.isGroup,
      @required this.currentUserName,
      @required this.currentUserProfilePic,
      this.bio,
      this.isOnline,
      this.postId})
      : super(key: key);

  @override
  State createState() => new PrivateChatScreenState(
      peerId: peerId, peerAvatar: peerAvatar, currentUseerId: currentUserId);
}

class PrivateChatScreenState extends State<PrivateChat> {
  PrivateChatScreenState(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.currentUseerId});

  var timeout = const Duration(seconds: 3);
  var ms = const Duration(milliseconds: 1);

  String peerId;
  String peerAvatar;
  String currentUseerId;
  List<QueryDocumentSnapshot> listMessage;
  String groupChatId;
  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  bool isUserBlocked = false;
  bool isUserBlockedBy;
  bool userWindowStatus = false;
  String _timeSection = "Today";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseProvider firebaseProvider;

  List<ChoicePrivate> choicesPrivate = const <ChoicePrivate>[
    const ChoicePrivate(title: 'Block', icon: Icons.block),
    const ChoicePrivate(title: 'Report', icon: Icons.report),
  ];

  List<ChoicePrivate> choicesGroup = const <ChoicePrivate>[
    //  const ChoicePrivate(title: 'Block', icon: Icons.block),
    const ChoicePrivate(title: 'Report', icon: Icons.report),
  ];

  //to show  loader
  final StreamController<bool> _streamControllerUserStatus =
      new StreamController<bool>();

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    MemoryManagement.init();
    focusNode.addListener(onFocusChange);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
    Future.delayed(const Duration(milliseconds: 300), () {
      resetCount();
      updatePostInfo();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    setOnlineOfflineStatusOnWindow(false);
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  //reset unread message count
  Future<Null> resetCount() async {
    firebaseProvider.resetUnreadMessageCount(
        userId: currentUseerId, chatUserId: peerId);
  }

  //update post info
  Future<void> updatePostInfo() async {
    try {
      if (widget.postId != null) {
        var postForChatRequest = PostForChat(postId: widget.postId,
            userId: widget.currentUserId,
            updatedAt: DateTime
                .now()
                .millisecondsSinceEpoch);
        firebaseProvider.insertPostInfoForChat(
            documentId: groupChatId, request: postForChatRequest);
      }
      else {
        var response = await firebaseProvider.getPostInfoForChat(
            documentId: groupChatId);
        widget.postId = response.postId;
      }
    }catch(ex)
    {

    }
  }

  readLocal() async {
    //currentUseerId=getUserId();

    print("peerid, currentid $peerId, $currentUseerId");

    if (!widget.isGroup ?? false) {
      int val1 = int.tryParse(currentUseerId) ?? 0;
      int val2 = int.tryParse(peerId) ?? 0;

      if (val1 >= val2) {
        groupChatId = '$currentUseerId-$peerId';
      } else {
        groupChatId = '$peerId-$currentUseerId';
      }
    } else {
      groupChatId = widget.peerId;
    }

    setState(() {});

    setOnlineOfflineStatusOnWindow(true); //set user on chat screen
    getUserUserStatusOnChatWindow();
    _checkIsUserBockedOrBlockedBy(); //check user block status
  }

  void getUserUserStatusOnChatWindow() {
    var docRef = FirebaseFirestore.instance
        .collection(MESSAGES)
        .doc(groupChatId)
        .collection("chatwindowstatus")
        .doc(peerId)
        .snapshots();

    docRef.listen((DocumentSnapshot snapshot) {
      if (snapshot.data == null) {
        userWindowStatus = false;
      } else {
        userWindowStatus =
            (snapshot.data() == null) ? false : snapshot.data()["isOnline"];
      }
      print("isonline $userWindowStatus");
      _streamControllerUserStatus.add(userWindowStatus);
    });
  }

  void _checkIsUserBockedOrBlockedBy() {
    //check if user whom chatting is blocked
    var docRef = FirebaseFirestore.instance
        .collection(MESSAGES)
        .doc(groupChatId)
        .collection("blockstatus")
        .doc(peerId)
        .snapshots();

    docRef.listen((DocumentSnapshot result) {
      if (result.data == null) {
        isUserBlocked = false;
      } else {
        isUserBlocked =
            (result.data() == null) ? false : result.data()["isBlocked"];
      }
    });

    //check if user blocked by chatting user
    var docRef2 = FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection("blockstatus")
        .doc(currentUseerId)
        .snapshots();

    docRef2.listen((DocumentSnapshot result) {
      if (result.data == null) {
        isUserBlockedBy = false;
      } else {
        isUserBlockedBy =
            (result.data() == null) ? false : result.data()["isBlocked"];
      }
    });
  }

  void _blockUnblockUser(bool status) {
    var docRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection("blockstatus")
        .doc(peerId);

    docRef.set({'isBlocked': status}).then((results) {
      isUserBlocked = status;
      if (status) //if user is blocked
        showAlertDialog(Constants.USER_BLOCKED_MESSAGE);
      else //if user is unblocked
        showAlertDialog(Constants.USER_UNBLOCKED_MESSAGE);
    });
  }

  void showAlertDialog(String message) {
    Dialogs.AppAlertDialogSuccess(context, message, "OK", callBackDialog);
  }

  void showWarningDialog(String message) {
    Dialogs.warningDialog(
        context, message, "CANCEL", "UNBLOCK", warningDialogCallBack);
  }

  VoidCallback callBackDialog() {}

  ValueSetter<int> warningDialogCallBack(int status) {
    if (status == 2) {
      _blockUnblockUser(false); //unblock the user
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    var user = "user+${widget.currentUserId}";
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child(user).child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot = await uploadTask.snapshot;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });

      showInSnackBar('This file is not an image');
    });
  }

  void onSendMessage(String content, int type) async {
    //check for user block status
    //if user is blocked to whom is chatting
    if (isUserBlocked) {
      showWarningDialog("User Blocked");
      return;
    }

    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      var timeStamp = DateTime.now().millisecondsSinceEpoch;
      print("chatid" + groupChatId);
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection('items')
          .doc(timeStamp.toString());

      documentReference.set(
        {
          'idFrom': currentUseerId,
          'idTo': peerId,
          'timestamp': timeStamp,
          'content': content,
          'type': type
        },
      ).then((onvalue) {
        print("saved ");
      }).catchError((error) {
        print("error ${error.toString()} ");
      });

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);

      //create friend and update last messagae vice-versa
      await _createUser(content);
    } else {
      showInSnackBar('Nothing to send');
    }

    //check if user online or offline
    if (!userWindowStatus) {
        setPushNotification(content);
    }
  }

  void setOnlineOfflineStatusOnWindow(bool status) async {
    var statusData = new Map<String, dynamic>();
    statusData["isOnline"] = status;
    var docRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection("chatwindowstatus")
        .doc(currentUseerId);

    docRef.set(statusData).catchError((e) {
      print("error ${e.toString()}");
    });
  }

  Widget _myChatBubbleMessage(String content, num timeStamp, int index) {
    return Container(
      child: Column(
        children: <Widget>[
          ChatBubbleRight(
            message: content,
            time: readTimestamp(timeStamp.toString()),
            userName: widget.currentUserName,
            profilePic: widget.currentUserProfilePic,
          ),
          // Container(height:100,child: ChatLeft()),
          SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }

  Widget _myChatBubbleImage(String content, num timeStamp, int index) {
    return ChatBubbleImageRight(
      content: content,
      timeStamp: timeStamp,
      profilePic: widget.currentUserProfilePic,
    );
  }

  Widget _otherChatMessageBubble(String content, num timeStamp, int index) {
    var isLiked = false;
    var likedBy = listMessage[index].data()['likedby'];
    print("liked by $likedBy");
    if (likedBy != null) {
      isLiked =
          List<int>.from(likedBy).contains(int.parse(widget.currentUserId));
    }
    return Column(
      children: <Widget>[
        ChatBubbleLeft(
          message: content,
          time: readTimestamp(timeStamp.toString()),
          userName: widget.userName,
          profilePic: widget.peerAvatar,
        ),
        SizedBox(
          height: 8,
        )
      ],
    );
  }

  Widget _otherChatImageBubble(String content, num timeStamp, int index) {
    return ChatBubbleImageLeft(
      content: content,
      timeStamp: timeStamp,
      profilePic: widget.peerAvatar,
    );
  }

  Widget buildItem(int index, QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    if (data['idFrom'] == currentUseerId) {
      // Right (my message)
      return Column(
        children: <Widget>[
          data['type'] == 0
              // Text
              ? _myChatBubbleMessage(data['content'], data['timestamp'], index)
              : data['type'] == 1
                  // Image
                  ? _myChatBubbleImage(
                      data['content'], data['timestamp'], index)
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'images/${data['content']}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 10.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        crossAxisAlignment: CrossAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            isLastMessageLeft(index)
                ? Container()
//                    ? Material(
//                        child: CachedNetworkImage(
//                          placeholder: (context, url) => Container(
//                                child: CircularProgressIndicator(
//                                  strokeWidth: 1.0,
//                                  valueColor: AlwaysStoppedAnimation<Color>(
//                                      AppColors.themeColor),
//                                ),
//                                width: 35.0,
//                                height: 35.0,
//                                padding: EdgeInsets.all(10.0),
//                              ),
//                          imageUrl: peerAvatar,
//                          width: 35.0,
//                          height: 35.0,
//                          fit: BoxFit.cover,
//                        ),
//                        borderRadius: BorderRadius.all(
//                          Radius.circular(18.0),
//                        ),
//                        clipBehavior: Clip.hardEdge,
//                      )
//                    :
                : Container(),
            data['type'] == 0
                ? _otherChatMessageBubble(
                    data['content'], data['timestamp'], index)
                : data['type'] == 1
                    ? Container(
                        child: _otherChatImageBubble(
                            data['content'], data['timestamp'], index),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : Container(
//                  child: new Image.asset(
//                    'images/${doc.data()['content']}.gif',
//                    width: 100.0,
//                    height: 100.0,
//                    fit: BoxFit.cover,
//                  ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      ),

            // Time
//            isLastMessageLeft(index)
//                ? Container(
//                    child: Text(
//                      DateFormat('dd MMM kk:mm').format(
//                          DateTime.fromMillisecondsSinceEpoch(
//                              doc.data()['timestamp'])),
//                      style: TextStyle(
//                          color: AppColors.kGrey,
//                          fontSize: 12.0,
//                          fontStyle: FontStyle.italic,
//                          fontFamily: "RobotoRegular"),
//                    ),
//                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
//                  )
//                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
        listMessage[index - 1].data()['idFrom'] == currentUseerId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
        listMessage[index - 1].data()['idFrom'] != currentUseerId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  ///This will show loader through stream
  Widget _userStatus() {
    return new StreamBuilder<bool>(
        stream: _streamControllerUserStatus.stream,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          bool status = snapshot.data;
          return status ? _circle(Colors.greenAccent) : _circle(Colors.grey);
        });
  }

  Widget _circle(Color color) {
    return new Container(
      width: 10,
      height: 10,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  void _showReportDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Report"),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Report Message:',
                      hintText: 'Enter your message'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("REPORT"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget popupMenuPrivate() {
    return InkWell(
      onTap: () {
        showBottomSheets();
      },
      child: Container(
        width: 50,
        child: Icon(
          Icons.more_vert,
          color: AppColors.kBlack,
        ),
      ),
    );
  }

  Widget popupMenuGroup() {
    return PopupMenuButton<ChoicePrivate>(
      icon: Icon(
        Icons.menu,
        color: AppColors.kWhite,
      ),
      onSelected: onItemMenuPressPrivate,
      itemBuilder: (BuildContext context) {
        return choicesGroup.map((ChoicePrivate choice) {
          return PopupMenuItem<ChoicePrivate>(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: AppColors.kAppBlue,
                  ),
                  Container(
                    width: 10.0,
                  ),
                  Text(
                    choice.title,
                    style: TextStyle(
                        color: AppColors.kAppBlue, fontFamily: "RobotoRegular"),
                  ),
                ],
              ));
        }).toList();
      },
    );
  }

  Widget getBottomText(String icon, String text, double size) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (text == "Report Profile") {
          _showReportDialog();
        } else if (text == "View Profile") {
          Navigator.push(
            context,
            new CupertinoPageRoute(builder: (BuildContext context) {
              return Material(
                  child: new ChatMessageDetails(
                hireduserId: widget.peerId,
                userButtonMsg: false,
              ));
            }),
          );
        }
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: new SvgPicture.asset(
                  icon,
                  width: size,
                  height: size,
                ),
              ),
            ),
            new SizedBox(
              width: 20.0,
            ),
            Container(
              child: new Text(
                text,
                style: text == "Delete Post"
                    ? TextThemes.darkRedMedium
                    : TextThemes.darkBlackMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomSheets() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0), topRight: Radius.circular(26.0)),
        ),
        builder: (BuildContext bc) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      margin: new EdgeInsets.only(top: 43, left: 27),
                      child: getBottomText(
                          AssetStrings.view_profile, "View Profile", 14)),
                  Container(
                      margin: new EdgeInsets.only(top: 35, left: 27),
                      child: getBottomText(
                          AssetStrings.slash, "Report Profile", 22)),
                  Opacity(
                    opacity: 0.12,
                    child: new Container(
                      height: 1.0,
                      margin: new EdgeInsets.only(top: 35, left: 27, right: 27),
                      color: AppColors.dividerColor,
                    ),
                  ),
                  Container(
                      margin: new EdgeInsets.only(top: 35, left: 24),
                      child: getBottomText(AssetStrings.cross, " Cancel", 18)),
                  Container(
                    height: 56,
                  )
                ],
              )));
        });
  }

  void onItemMenuPressPrivate(ChoicePrivate choice) {
    if (choice.title == 'Block') {
      _blockUnblockUser(true); //block or unblock user
    } else {
      _showReportDialog();
    }
  }

  void onItemMenuPressGroup(ChoiceGroup choice) {
    if (choice.title == 'Block') {
      _blockUnblockUser(true); //block or unblock user
    } else {
      _showReportDialog();
    }
  }

  // Getters
  _getAppbar(String userName) {
    return new AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            userName,
            style: TextThemes.chatUUserTextBold,
          ),
        /*  Padding(
            padding: const EdgeInsets.all(8.0),
            child: _userStatus(),
          )*/
        ],
      ),
      centerTitle: true,
      actions: <Widget>[popupMenuPrivate()],
    );
  }

  void setPushNotification(String content) async {
    bool gotInternetConnection = await hasInternetConnection(
      context: context,
      mounted: mounted,
      canShowAlert: true,
      onFail: () {},
      onSuccess: () {},
    );

    if (gotInternetConnection) {
      var request = new SendNotificationRequest(
          reciver_id: peerId, message: content);
      var response = await firebaseProvider.sendNotification(
          context: context, notificationRequest: request);
      //push sent
      if (response != null && (response is ReportResponse)) {
        print(response.success);
      } else {
        print(response);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    return SafeArea(
      child: new Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: _getAppbar(widget.userName),
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
/*
            Container(
              height: 1,
              color: AppColors.dividerColor.withOpacity(0.5),
            ),*/
            new Expanded(
              child: Container(
                  color: Color.fromRGBO(248, 248, 250, 1),
                  child: _getBodyWidget()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTitle() {
    return InkWell(
      onTap: () {
//        if (widget.isGroup) {
//          Navigator.push(context,
//              CupertinoPageRoute(builder: (BuildContext context) {
//            return new OtherFunProvider(
//              child: GroupInfo(widget.peerId),
//              postBloc: OtherFunBloc(OtherFunServiceApi()),
//            );
//          }));
//        } else {
//          Navigator.push(context,
//              CupertinoPageRoute(builder: (BuildContext context) {
//            return new OtherFunProvider(
//                child: ChatUserProfileInfo(peerId),
//                postBloc: OtherFunBloc(OtherFunServiceApi()));
//          }));
//        }
      },
      child: new Text(
        widget.userName ?? "",
        style:
            TextStyle(color: AppColors.kAppBlue, fontWeight: FontWeight.bold),
      ),
    );
  }

  ValueChanged<int> callBack(int value) {
    if (value == 1) //for sending text message
    {
      onSendMessage(textEditingController.text, 0);
    } else //for sending image
    {
      _imagePicker();
    }
  }

  Widget _getBodyWidget() {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Input content
              //  buildInput(),
              ChatInputWidget(callBack, textEditingController),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CupertinoActivityIndicator(
                  radius: Constants.LOADER_RADIUS,
                ),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: _imagePicker,
                color: AppColors.kAppBlue,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                    color: AppColors.kAppBlue,
                    fontSize: 15.0,
                    fontFamily: "RobotoRegular"),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: ' Type your message...',
                  hintStyle: TextStyle(
                      color: AppColors.kGrey, fontFamily: "RobotoRegular"),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: AppColors.kAppBlue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: AppColors.kGrey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection('items')
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CupertinoActivityIndicator(
              radius: Constants.LOADER_RADIUS,
            ));
          } else {
            listMessage = snapshot.data.docs;
            var messageList = List<Widget>();
            var index = 0;
            for (var doc in snapshot.data.docs) {
              var timeSection = TimeAgo.timeString(doc.data()['timestamp']);
              if (_timeSection != timeSection) {
                messageList.add(_timeSectionWidget(_timeSection));
                _timeSection = timeSection;
              }
              messageList.add(buildItem(index, snapshot.data.docs[index]));
              index++;
            }
            if(messageList.length>0)
             messageList.add(_timeSectionWidget(_timeSection));

            _timeSection="Today";
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                return messageList[index];
              },
              itemCount: messageList.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget _timeSectionWidget(String text) {
    return Center(
      child: Container(
        margin: new EdgeInsets.only(left: 14, right: 14),
        child: Row(
          children: [
            Expanded(
              child: new Container(
                height: 0.3,
                color: AppColors.kBlack.withOpacity(0.7),
              ),
            ),
            Container(
                margin: new EdgeInsets.only(left: 14, right: 14),
                child: Center(
                    child: Text(text.toUpperCase(),
                        style: TextThemes.chatSectionItemTheme))),
            Expanded(
              child: new Container(
                height: 0.3,
                color: AppColors.kBlack.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _createUser(String message) async {
    var chatUser = new ChatUser();
    chatUser.username = widget.userName;
    chatUser.userId = peerId;
    chatUser.profilePic = widget.peerAvatar;
    chatUser.lastMessage = message;
    chatUser.lastMessageTime = new DateTime.now().millisecondsSinceEpoch;
    chatUser.unreadMessageCount = (userWindowStatus) ? 0 : 1;
    chatUser.isGroup = false;
    chatUser.updatedAt = new DateTime.now().millisecondsSinceEpoch;

    //update last message of group in group data
    if (widget.isGroup) {
//      await _dashBoardBloc.updateGroupMessage(
//          user: chatUser, userId: currentUseerId);
    } else {
      await firebaseProvider.createChatUser(
          user: chatUser, userId: currentUseerId);
    }
  }

  void _imagePicker() {
    _crupitinoActionSheet();
  }

  _crupitinoActionSheet() {
    return containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(Constants.CAMERA),
              onPressed: () {
                _getCameraImage();
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Text(Constants.GALLARY),
              onPressed: () {
                _getGalleryImage();
                Navigator.pop(context);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(Constants.CANCEL),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          )),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  Future _getCameraImage() async {
    imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: Constants.maxWidth,
        maxHeight: Constants.maxHeight);

    if (imageFile != null) {
      // imageFile=await rotateAndCompressAndSaveImage(imageFile);
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future _getGalleryImage() async {
    imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: Constants.maxWidth,
        maxHeight: Constants.maxHeight);

    if (imageFile != null) {
      //imageFile=await rotateAndCompressAndSaveImage(imageFile);
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
