import 'package:flutter/material.dart';
import 'package:payvor/utils/AssetStrings.dart';

class TextThemes {
  static final Color ndGold = Color.fromRGBO(220, 180, 57, 1.0);
  static final Color ndBlue = Color.fromRGBO(2, 43, 91, 1.0);

  static final TextStyle extraBold = TextStyle(
    fontFamily: AssetStrings.circulerBoldStyle,
    fontSize: 28,
    color: Colors.black,
  );

  static final TextStyle smallBold = TextStyle(
    fontFamily: AssetStrings.circulerBoldStyle,
    fontSize: 16,
    color: Colors.black,
  );

  static final TextStyle grayNormal = TextStyle(
    fontFamily: AssetStrings.circulerNormal,
    fontSize: 16,
    color: Color.fromRGBO(103, 99, 99, 1.0),
  );

  static final TextStyle grayNormalSmall = TextStyle(
    fontFamily: AssetStrings.circulerNormal,
    fontSize: 14,
    color: Color.fromRGBO(103, 99, 99, 1.0),
  );

  static final TextStyle blueMediumSmall = TextStyle(
    fontFamily: AssetStrings.circulerMedium,
    fontSize: 14,
    color: Color.fromRGBO(9, 165, 255, 1.0),
  );

  static final TextStyle blackTextSmallNormal = TextStyle(
    fontFamily: AssetStrings.circulerNormal,
    fontSize: 14,
    color: Colors.black,
  );

  static const TextStyle blackTextFieldNormal = TextStyle(
    fontFamily: AssetStrings.circulerNormal,
    fontSize: 16,
    color: Colors.black,
  );

  static final TextStyle greyTextFieldHintNormal = TextStyle(
    fontFamily: AssetStrings.circulerNormal,
    fontSize: 16,
    color: Color.fromRGBO(183, 183, 183, 1.0),
  );

  static final TextStyle blackTextSmallMedium = TextStyle(
    fontFamily: AssetStrings.circulerMedium,
    fontSize: 14,
    color: Colors.black,
  );
  static final TextStyle redTextSmallMedium = TextStyle(
      fontFamily: AssetStrings.circulerBoldStyle,
      fontSize: 12,
      color: Color.fromRGBO(205, 107, 102, 1.0));

  static final TextStyle greyTextFieldMedium = TextStyle(
    fontFamily: AssetStrings.circulerMedium,
    fontSize: 14,
    color: Color.fromRGBO(114, 117, 122, 1.0),
  );

  static final TextStyle greyTextFieldNormal = TextStyle(
    fontFamily: AssetStrings.circulerNormal,
    fontSize: 14,
    color: Color.fromRGBO(114, 117, 122, 1.0),
  );

  static final TextStyle greyDarkTextFieldMedium = TextStyle(
    fontFamily: AssetStrings.circulerMedium,
    fontSize: 14,
    color: Color.fromRGBO(103, 99, 99, 1.0),
  );

  static final TextStyle greyDarkTextFieldItalic = TextStyle(
    fontFamily: AssetStrings.circulerItalic,
    fontSize: 14,
    color: Color.fromRGBO(103, 99, 99, 1.0),
  );

  static final TextStyle subtitle1 = TextStyle(
    fontFamily: 'Solway',
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle bodyText1 = TextStyle(
    fontFamily: 'Solway',
    fontSize: 11,
    fontWeight: FontWeight.w300,
  );
  static final TextStyle bodyTextWhite = TextStyle(
    fontFamily: 'Solway',
    fontSize: 11,
    fontWeight: FontWeight.w300,
    color: Colors.white
  );
  static final TextStyle mediumbody = TextStyle(
    fontFamily: 'Solway',
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: ndBlue
  );

  static final TextStyle dateStyle = TextStyle(
    fontFamily: 'Solway',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(2, 43, 91, 1.0),
  );
}
