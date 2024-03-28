import 'package:flutter/material.dart';

Size? screenSize;

void getScreenSize(BuildContext context) {
  screenSize = MediaQuery.of(context).size;
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

//Font Weights
const FontWeight fontWeightExtraLight = FontWeight.w200;
const FontWeight fontWeightLight = FontWeight.w300;
const FontWeight fontWeightRegular = FontWeight.w400;
const FontWeight fontWeightMedium = FontWeight.w500;
const FontWeight fontWeightSemiBold = FontWeight.w600;
const FontWeight fontWeightBold = FontWeight.w700;
const FontWeight fontWeightExtraBold = FontWeight.w800;

const String fontfamilybeVietnam = 'beVietnamPro';
// const String fontfamilybeVietnamPro = 'BeVietnamPro';

//Custom Fonts
const double fontSize8 = 8.0;
const double fontSize10 = 10.0;
const double fontSize11 = 11.0;
const double fontSize12 = 12.0;
const double fontSize13 = 13.0;
const double fontSize14 = 14.0;
const double fontSize15 = 15.0;
const double fontSize16 = 16.0;
const double fontSize17 = 17.0;
const double fontSize18 = 18.0;
const double fontSize20 = 20.0;
const double fontSize22 = 22.0;
const double fontSize23 = 23.0;
const double fontSize24 = 24.0;
const double fontSize25 = 25.0;
const double fontSize26 = 26.0;
const double fontSize27 = 27.0;
const double fontSize28 = 28.0;
const double fontSize30 = 30.0;
const double fontSize34 = 34.0;
const double fontSize35 = 35.0;
const double fontSize36 = 36.0;
const double fontSize40 = 40.0;
const double fontSize44 = 44.0;
const double fontSize45 = 45.0;
const double fontSize120 = 120.0;
