import 'package:flutter/material.dart';

import '../../constant/color_constant.dart';
import '../../constant/font_constant.dart';
import '../../utils/textwidget.dart';

class MyTermsandCondition extends StatefulWidget {
  const MyTermsandCondition({super.key});

  @override
  State<MyTermsandCondition> createState() => _MyTermsandConditionState();
}

class _MyTermsandConditionState extends State<MyTermsandCondition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: background,
        centerTitle: true,
        elevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'Terms & Condition',
              textFontSize: fontSize15,
              textFontWeight: fontWeightSemiBold,
              textColor: whitecolor),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 24.0,
                color: whitecolor,
              )),
        ),
      ),
      body: Center(
        child: getTextWidget(
            title: 'Terms and Condition',
            textFontSize: fontSize20,
            textFontWeight: fontWeightSemiBold,
            textColor: background),
      ),
    );
  }
}
