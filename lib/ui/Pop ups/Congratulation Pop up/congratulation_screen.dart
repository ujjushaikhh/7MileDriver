import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/constant/font_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/My%20Profile/myprofile.dart';
import 'package:driverflow/utils/button.dart';
import 'package:driverflow/utils/textwidget.dart';
import 'package:flutter/material.dart';

class MyCongratualtion extends StatelessWidget {
  const MyCongratualtion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 56.0, right: 56.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icCongratulation,
              width: 292.74,
              height: 128.83,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 27.0),
              child: getTextWidget(
                  title: 'Congratulations!',
                  textFontSize: fontSize20,
                  textFontWeight: fontWeightSemiBold,
                  textColor: background),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 13.0),
              child: getTextWidget(
                  textAlign: TextAlign.center,
                  title: 'You have successfully delivered the order.',
                  textFontSize: fontSize14,
                  textFontWeight: fontWeightRegular,
                  textColor: background),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 21),
              child: CustomizeButton(
                text: 'Go to Next Order',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyProfile()));
                },
                buttonWidth: MediaQuery.of(context).size.width / 2,
              ),
            )
          ],
        ),
      ),
    );
  }
}
