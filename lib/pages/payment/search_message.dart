import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvor/filter/refer_request.dart';
import 'package:payvor/filter/refer_response.dart';
import 'package:payvor/filter/refer_user.dart';
import 'package:payvor/filter/refer_user_response.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/login/loginsignupreponse.dart';
import 'package:payvor/pages/chat/chat_user.dart';
import 'package:payvor/pages/chat/payvor_firebase_user.dart';
import 'package:payvor/pages/chat/private_chat.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/shimmers/refer_shimmer_loader.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/memory_management.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchMessage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SearchMessage>
    with AutomaticKeepAliveClientMixin<SearchMessage> {
  var screenSize;

  String searchkey = null;
  FirebaseProvider firebaseProvider;
  int currentPage = 1;
  bool isPullToRefresh = false;
  bool offstagenodata = true;
  bool loader = false;
  String title = "";
  List<DataRefer> listResult = List();
  String userId;
  var _firstTimeChatUser = true;
  var _userName ;
 var  _userProfilePic ;

  TextEditingController _controller = new TextEditingController();
  ScrollController scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    var userData = MemoryManagement.getUserInfo();
    if (userData != null) {
      Map<String, dynamic> data = jsonDecode(userData);
      LoginSignupResponse userResponse = LoginSignupResponse.fromJson(data);
      _userName = userResponse.user.name ?? "";
      _userProfilePic = userResponse.user.profilePic ?? "";
      userId=userResponse.user.id.toString();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _hitApi();
      // checkNewGroup(userId: userId);
      checkNewUser(userId: userId);
    });
    super.initState();
  }

  void _hitApi() async {

    (firebaseProvider.myFriendsIdList.length == 0)
        ? await firebaseProvider.getFriends(userId: userId)
        : firebaseProvider.myFriendsIdList;

    setState(() {});
  }


  void checkNewUser({@required String userId}) {
    var firestore = Firestore.instance
        .collection("chatfriends")
        .document(userId)
        .collection("friends")
        .orderBy('lastMessageTime', descending: true)
        .snapshots();

    //get the data and convert to list
    firestore.listen((QuerySnapshot snapshot) {
      print("new chat");
      if (!_firstTimeChatUser) {
        checkForNewUserOrLatestMessage(snapshot.documents[0]);
      } else {
        _firstTimeChatUser = false;
      }
    });
  }

  void checkForNewUserOrLatestMessage(DocumentSnapshot documentSnapshot) {
    var chatUser = ChatUser.fromMap(documentSnapshot.data);
    print("new chat user ${chatUser.toJson()}");
    if (firebaseProvider.userList.isNotEmpty) {
      var isOldUser = false;
      for (var data in firebaseProvider.userList) {
        if (data is ChatUser) {
          if (data.userId == chatUser.userId) {
            isOldUser = true;
            print("new_msg ${chatUser.lastMessage}");
            break;
          }
        }
      }
      if (!isOldUser) {
        firebaseProvider.myFriendsIdList.add(int.parse(chatUser.userId));
        setState(() {});
      }
    } else {
      firebaseProvider.myFriendsIdList.add(int.parse(chatUser.userId));
      setState(() {});
    }


  }

  void _moveToPrivateChatScreen(ChatUser chatUser) {

    var screen = PrivateChat(
      peerId: chatUser.userId.toString(),
      peerAvatar: chatUser.profilePic,
      userName: chatUser.username,
      isGroup: false,
      currentUserId: userId,
      currentUserName: _userName,
      currentUserProfilePic: _userProfilePic,
    );
    //move to private chat screen
    //widget.fullScreenWidget(screen);
    Navigator.push(
      context,
      new CupertinoPageRoute(builder: (BuildContext context) {
        return Material(child: screen);
      }),
    );
  }
  Widget _buildContestList() {
    return StreamBuilder<List<ChatUser>>(
        stream: firebaseProvider.getChatFriends(userId: userId),
        builder: (context, AsyncSnapshot<List<ChatUser>> result) {
          if (result.hasData) {
            if (result.data.length == 0) {
              return _getEmptyWidget;
            }
           // widget.countCallBack(result.data.length);
            return Expanded(
              child: Container(
                child: new ListView.builder(
                  padding: new EdgeInsets.all(0.0),
                  itemBuilder: (BuildContext context, int index) {
                    var data = result.data[index];
                    return InkWell(
                        onTap: () {
                         // _moveToPrivateChatScreen();
                        },
                        child: buildItemMain(data));
                  },
                  itemCount: result.data.length,
                ),
              ),
            );
          } else {
            return _getEmptyWidget;
          }
        });
  }
  get _getEmptyWidget
  {
    return Column();
//    return Expanded(
//      child: EmptyWidget(
//        message: "No Active users",
//        callback: refreshList,
//        isEnabled: false,
//      ),
//    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    firebaseProvider = Provider.of<FirebaseProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          new Container(
            color: Colors.white,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getTextField(),
                _buildContestList(),
              ],
            ),
          ),
          Offstage(
            offstage: true,
            child: Container(
              height: screenSize.height,
              child: new Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: new SvgPicture.asset(
                        AssetStrings.chat_empty,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 61),
                      child: new Text(
                        "No Messages",
                        style: new TextStyle(
                            color: Colors.black,
                            fontFamily: AssetStrings.circulerMedium,
                            fontSize: 17.0),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 9),
                      child: new Text(
                        "You don’t have any conversation yet",
                        style: new TextStyle(
                            color: Color.fromRGBO(103, 99, 99, 1.0),
                            fontFamily: AssetStrings.circulerNormal,
                            fontSize: 15.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: new EdgeInsets.only(top: 130),
            child: new Center(
              child: getHalfScreenLoader(
                status: loader,
                context: context,
              ),
            ),
          ),
          /* new Center(
            child: _getLoader,
          ),*/
        ],
      ),
    );
  }

  Widget getTextField() {
    return Container(
      margin: new EdgeInsets.only(left: 16.0, right: 16.0),
      padding: new EdgeInsets.all(1),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(3.0),
          border: new Border.all(color: Color.fromRGBO(224, 224, 244, 1)),
          color: AppColors.kWhite),
      child: Container(
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(3.0),
            color: AppColors.lightWhite),
        child: Container(
          height: 46.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              new SizedBox(
                width: 10.0,
              ),
              new Image.asset(
                AssetStrings.searches,
                width: 18.0,
                height: 18.0,
              ),
              new SizedBox(
                width: 10.0,
              ),
              Flexible(
                child: new TextField(
                  controller: _controller,
                  style: TextThemes.blackTextFieldNormal,
                  keyboardType: TextInputType.text,
                  onSubmitted: (String value) {
                    /*  _loadMore = false;
                    isPullToRefresh = false;
                    currentPage = 1;
                    title = value;

                    hitSearchApi(title);*/
                  },
                  onChanged: (String value) {
                    /*   _loadMore = false;
                    isPullToRefresh = false;
                    currentPage = 1;
                    title = value;
                    hitSearchApi(title);*/
                  },
                  decoration: new InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: new EdgeInsets.only(bottom: 3.0),
                    hintText: "Search for message here",
                    hintStyle: TextThemes.greyTextNormal,
                  ),
                ),
              ),
              new SizedBox(
                width: 4.0,
              ),
              InkWell(
                onTap: () {
                  /*   _loadMore = false;
                  isPullToRefresh = false;
                  _controller.text = "";
                  currentPage = 1;
                  hitSearchApi("");
                  setState(() {});*/
                },
                child: new Image.asset(
                  AssetStrings.clean,
                  width: 18.0,
                  height: 18.0,
                ),
              ),
              new SizedBox(
                width: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

//  _buildContestList() {
//    return Expanded(
//        child: Container(
//          color: Colors.white,
//          child: new ListView.builder(
//            padding: new EdgeInsets.all(0.0),
//            physics: const AlwaysScrollableScrollPhysics(),
//            itemBuilder: (BuildContext context, int index) {
//              return buildItemMain();
//            },
//            itemCount:firebaseProvider.userList.length,
//          ),
//        ));
//  }

  Widget buildItem(ChatUser chatUser) {
    return InkWell(
      onTap: (){
        _moveToPrivateChatScreen(chatUser);
      },
      child: Container(
        margin: new EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          children: <Widget>[
            new Container(
              width: 49.0,
              height: 49.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                // margin: new EdgeInsets.only(right: 20.0,top: 20.0,bottom: 60.0),

                child: getCachedNetworkImageWithurl(
                    url: "", fit: BoxFit.fill, size: 49),
              ),
            ),
            Expanded(
              child: Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: new EdgeInsets.only(
                            left: 10.0,
                          ),
                          child: new Text(
                            chatUser.username,
                            style: TextThemes.greyTextFielBold,
                          ),
                        ),
                        Container(
                          margin: new EdgeInsets.only(left: 6),
                          child: new Text(
                            "now",
                            style: TextThemes.lightGrey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin:
                          new EdgeInsets.only(left: 10.0, right: 10.0, top: 6),
                      child: Container(
                          child: new Text(
                       chatUser.lastMessage,
                        style: TextThemes.greyDarkTextHomeLocation,
                      )),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: chatUser.unreadMessageCount>0,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding:
                      new EdgeInsets.only(top: 2, bottom: 2, left: 5, right: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(12.0),
                      color: AppColors.colorDarkCyan),
                  child: new Text(
                    "${chatUser.unreadMessageCount}",
                    style: new TextStyle(
                      color: Colors.white,
                      fontFamily: AssetStrings.circulerMedium,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildItemMain(ChatUser chatUser) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.3,
      child: Container(
        child: Column(
          children: <Widget>[
            new SizedBox(
              height: 14.0,
            ),
            buildItem(chatUser),
            Opacity(
              opacity: 1,
              child: new Container(
                height: 1,
                margin: new EdgeInsets.only(left: 17.0, right: 17.0, top: 14.0),
                color: Color.fromRGBO(151, 151, 151, 0.2),
              ),
            ),
          ],
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Color.fromRGBO(255, 107, 102, 1),
          icon: Icons.delete,
        ),
      ],
    );
  }
}