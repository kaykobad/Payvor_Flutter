import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvor/dialog/customdialogbox.dart';
import 'package:payvor/model/apierror.dart';
import 'package:payvor/model/home/homerequest.dart';
import 'package:payvor/shimmers/media_grid_shimmer.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/AssetStrings.dart';
import 'package:payvor/utils/UniversalFunctions.dart';
import 'package:payvor/viewmodel/home_view_model.dart';

import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'mediadetailpage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MediaStorePage extends StatefulWidget {
  @override
  _MediaStorePageState createState() => _MediaStorePageState();
}

class _MediaStorePageState extends State<MediaStorePage> {
  HomeViewModel _homeViewModel;
  var _imagesList = List<String>();

  //for media picking
  //for image mix height and width
  double _maxWidth = 500;
  double _maxHeight = 500;

  //for picking media
  PickedFile _imageFile;
  bool isVideo = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      fetchData();
    });
  }

  void fetchData() async {
    _homeViewModel.setLoading();
    var response =
        await _homeViewModel.getMediaStoreData(HomeRequest(), context);
    if (response is APIError) {
    } else {
      _imagesList.addAll(response);
    }
  }

  VoidCallback backButtonPressed() {
    Navigator.pop(context);
  }

  Widget _addMedia() {
    return InkWell(
      onTap: showActionSheet,
      child: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: SvgPicture.asset(
            AssetStrings.addMediaIcon,
            semanticsLabel: 'Acme Logo',
            width: 24,
            height: 24,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    _homeViewModel = Provider.of<HomeViewModel>(context);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: AppColors.kBackgroundColor,
        appBar: commonAppBar(callback: backButtonPressed, action: _addMedia(),title: "Wineglass Bay"),
        body: Stack(
          children: [
            Container(

              child: Padding(
                padding: const EdgeInsets.only(left: 1.0, right: 1.0, top: 8.0),
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    physics: BouncingScrollPhysics(),
                    itemCount: _imagesList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _getItem(_imagesList[index], index);
                    }),
              ),
            ),
            Visibility(
                visible: _homeViewModel.getLoading(),
                child: Center(
                  child: GridViewShimmer(),
                ))
          ],
        ));
  }

  redirect(int pos) async {
    //Navigator.of(context).pushNamed(Routes.nearpost);
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new MediaDetailPage(
                  imagesList: _imagesList,
                  pos: pos,
                )));
  }

  Widget _getItem(String url, int pos) {
    return InkWell(
      onTap: () {
        redirect(pos);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(8),
        )),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: getCachedNetworkImage(
                url: url,
              ),
            ),
            (pos%5==0)?Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    AssetStrings.videoIcon,
                    semanticsLabel: 'Acme Logo',
                    width: 18,
                    height: 18,
                  ),
                )):Container()
          ],
        ),
      ),
    );
  }

  void showActionSheet() {
    final act = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              _closeActionSheet();
              isVideo = false;
              _onImageButtonPressed(ImageSource.camera, context: context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Gallery'),
            onPressed: () {
              _closeActionSheet();
              isVideo = false;
              _onImageButtonPressed(ImageSource.gallery, context: context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Pick Video'),
            onPressed: () {
              _closeActionSheet();
              isVideo = true;
              _onImageButtonPressed(ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Record Video'),
            onPressed: () {
              _closeActionSheet();
              isVideo = true;
              _onImageButtonPressed(ImageSource.camera);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            _closeActionSheet();

          },
        ));
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  void _closeActionSheet()
  {
    Navigator.of(context, rootNavigator: true).pop("Discard");
  }


  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
//    if (_controller != null) {
//      await _controller.setVolume(0.0);
//    }
    if (isVideo) {
      final PickedFile file = await _picker.getVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      // await _playVideo(file);
    } else {
      try {
        final pickedFile = await _picker.getImage(
          source: source,
          maxWidth: _maxWidth,
          maxHeight: _maxHeight,
          imageQuality: 100,
        );
        setState(() {
          _imageFile = pickedFile;
        });
        _showImageDilaog();
      } catch (e) {
//              setState(() {
//                _pickImageError = e;
//              });
      }
    }
  }

  void _showImageDilaog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: "Custom Dialog Demo",
            descriptions:
                "Hii all this is a custom dialog in flutter and  you will be use in your flutter applications",
            text: "UPLOAD",
            img: _imageFile,
          );
        });
  }
}
