import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/constant/font_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
// import 'package:driverflow/ui/Pop%20ups/Congratulation%20Pop%20up/congratulation_screen.dart';
import 'package:driverflow/utils/button.dart';
import 'package:driverflow/utils/textwidget.dart';
import 'package:flutter/material.dart';

import '../../Home/home.dart';

class MySuccessScreen extends StatelessWidget {
  const MySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 53.0, right: 53),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icSuccess,
              width: 156.88,
              height: 193.51,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 27.0),
              child: getTextWidget(
                  title: 'Successfully Done!',
                  textFontSize: fontSize20,
                  textFontWeight: fontWeightSemiBold,
                  textColor: background),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 13.0),
              child: getTextWidget(
                  textAlign: TextAlign.center,
                  title:
                      'We’ll notify once your information has been verified from our admin team.',
                  textFontSize: fontSize14,
                  textFontWeight: fontWeightRegular,
                  textColor: background),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 21),
              child: CustomizeButton(
                text: 'OK',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MyHome()));
                },
                buttonWidth: MediaQuery.of(context).size.width / 4,
              ),
            )
          ],
        ),
      ),
    );
  }
}
