import 'dart:async';

import 'package:flutter/material.dart';
import 'package:payvor/utils/AppColors.dart';
import 'package:payvor/utils/constants.dart';
import 'package:payvor/utils/themes_styles.dart';
import 'package:rxdart/rxdart.dart';

typedef void OnTapCallback(String value);

class AutoCompleteTextView extends StatefulWidget
    with AutoCompleteTextInterface {
  final double maxHeight;
  final TextEditingController controller;

  //AutoCompleteTextField properties
  final tfCursorColor;
  final tfCursorWidth;
  final tfStyle;
  final tfTextDecoration;
  final tfTextAlign;

  //Suggestiondrop Down properties
  final suggestionStyle;
  final suggestionTextAlign;
  final onTapCallback;
  final Function getSuggestionsMethod;
  final Function focusGained;
  final Function focusLost;
  final int suggestionsApiFetchDelay;
  final Function onValueChanged;
  final String hintText;
  final IconData icon;
  final bool isLocation;
  final double defaultPadding;
  final String svgicon;
  final bool backgroundShow;

  AutoCompleteTextView(
      {this.isLocation,
      this.hintText,
      @required this.controller,
      this.onTapCallback,
      this.maxHeight = 200,
      this.tfCursorColor = Colors.blue,
      this.tfCursorWidth = 2.0,
      this.tfStyle = TextThemes.blackTextFieldNormal,
      this.tfTextDecoration = const InputDecoration(),
      this.tfTextAlign = TextAlign.left,
      this.suggestionStyle = TextThemes.blackTextFieldNormal,
      this.suggestionTextAlign = TextAlign.left,
      @required this.getSuggestionsMethod,
      this.focusGained,
      this.suggestionsApiFetchDelay = 0,
      this.focusLost,
      this.onValueChanged,
      this.icon,
      this.svgicon,
      this.defaultPadding,
      this.backgroundShow});

  @override
  _AutoCompleteTextViewState createState() => _AutoCompleteTextViewState();

  //This funciton is called when a user clicks on a suggestion
  @override
  void onTappedSuggestion(String suggestion) {
    onTapCallback(suggestion);
  }
}

class _AutoCompleteTextViewState extends State<AutoCompleteTextView> {
  ScrollController scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  OverlayEntry _overlayEntry;
  LayerLink _layerLink = LayerLink();
  final suggestionsStreamController = new BehaviorSubject<List<String>>();
  List<String> suggestionShowList = List<String>();
  Timer _debounce;
  bool isSearching = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
        (widget.focusGained != null) ? widget.focusGained() : () {};
      } else {
        this._overlayEntry.remove();
        (widget.focusLost != null) ? widget.focusLost() : () {};
      }
    });
    widget.controller.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce =
        Timer(Duration(milliseconds: widget.suggestionsApiFetchDelay), () {
      if (isSearching == true) {
        _getSuggestions(widget.controller.text);
      }
    });
  }

  _getSuggestions(String data) async {
    if (data.length > 0 && data != null) {
      List<String> list = await widget.getSuggestionsMethod(data);
      suggestionsStreamController.sink.add(list);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    return OverlayEntry(
        builder: (context) => Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                  elevation: 4.0,
                  child: StreamBuilder<Object>(
                      stream: suggestionsStreamController.stream,
                      builder: (context, suggestionData) {
                        if (suggestionData.hasData &&
                            widget.controller.text.isNotEmpty) {
                          suggestionShowList = suggestionData.data;
                          return ConstrainedBox(
                            constraints: new BoxConstraints(
                              maxHeight: 200,
                            ),
                            child: ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: suggestionShowList.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      suggestionShowList[index],
                                      style: widget.tfStyle,
                                      textAlign: widget.suggestionTextAlign,
                                    ),
                                    onTap: () {
                                      isSearching = false;
                                      if (widget.isLocation) {
                                        widget.controller.text =
                                            suggestionShowList[index];
                                      } else {
                                        widget.controller.text = "";
                                      }

                                      suggestionsStreamController.sink.add([]);
                                      widget.onTappedSuggestion(
                                          suggestionShowList[index]);
                                    },
                                  );
                                }),
                          );
                        } else {
                          return Container();
                        }
                      }),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: Container(
        height: Constants.textFieldHeight,
        child: TextField(
          controller: widget.controller,
          style: widget.tfStyle,
          cursorColor: widget.tfCursorColor,
          cursorWidth: widget.tfCursorWidth,
          textAlign: widget.tfTextAlign,
          focusNode: this._focusNode,
          onChanged: (text) {
            if (text.trim().isNotEmpty) {
              (widget.onValueChanged != null)
                  ? widget.onValueChanged(text)
                  : () {};
              isSearching = true;
              scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            } else {
              isSearching = false;
              suggestionsStreamController.sink.add([]);
            }
          },
          decoration: !widget.backgroundShow ? new InputDecoration(
            enabledBorder: new OutlineInputBorder(
                borderSide: new BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                ),
                borderRadius: new BorderRadius.circular(8)),
            focusedBorder: new OutlineInputBorder(
                borderSide: new BorderSide(
                  color: AppColors.colorCyanPrimary,
                ),
                borderRadius: new BorderRadius.circular(8)),
            contentPadding: new EdgeInsets.only(top: 10.0),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14.0),
              child: new Image.asset(
                widget.svgicon,
                width: 20.0,
                height: 20.0,
              ),
            ),
            suffixIcon: new Container(width: 1,),
            hintText: widget.hintText,
            hintStyle: TextThemes.greyTextFieldHintNormal,
          ) : new InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: new EdgeInsets.only(top: 10.0),
            hintText: widget.hintText,
            hintStyle: TextThemes.greyTextFieldHintNormal,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    suggestionsStreamController.close();
    scrollController.dispose();
    widget.controller.dispose();
    super.dispose();
  }
}

abstract class AutoCompleteTextInterface {
  void onTappedSuggestion(String suggestion);
}
