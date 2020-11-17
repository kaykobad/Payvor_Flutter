//
//import 'dart:io';
//
//import 'package:flutter/material.dart';
//import 'package:flick_video_player/flick_video_player.dart';
//import 'package:godash/resources/class%20ResString.dart';
//import 'package:video_player/video_player.dart';
//
//class VideoPlay extends StatefulWidget {
//  File file;
//
//  VideoPlay({Key key , this.file}) : super(key: key);
//  @override
//  _SamplePlayerState createState() => _SamplePlayerState(file);
//}
//
//class _SamplePlayerState extends State<VideoPlay> {
//  FlickManager flickManager;
//  File file;
//  _SamplePlayerState(this.file);
//
//  @override
//  void initState() {
//    super.initState();
//    print("path="+file.path);
//    flickManager = FlickManager(videoPlayerController: VideoPlayerController.file(file)
//    );
//  }
//
//  @override
//  void dispose() {
//    flickManager.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar:AppBar(
//          backgroundColor: Colors.white,
//          leading: BackButton(
//            onPressed: () {
//              Navigator.pop(context);
//            },
//            color: Colors.black,
//          ),
//          title: Text(ResString().get('importimage'), style: TextStyle(fontSize: 14, color: Colors.black),),
//          centerTitle: true
//      ),
//      body: Container(
//        child: FlickVideoPlayer(
//          flickManager: flickManager,
//          flickVideoWithControls: FlickVideoWithControls(
//            controls: FlickPortraitControls(),
//          ),
//          flickVideoWithControlsFullscreen: FlickVideoWithControls(
//            controls: FlickLandscapeControls(),
//          ),
//        ),
//      ),
//    );
//  }
//}