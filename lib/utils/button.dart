import 'package:driverflow/constant/color_constant.dart';
import 'package:flutter/material.dart';

import '../constant/font_constant.dart';

class CustomizeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? buttonHeight;
  final double? buttonWidth;
  final Color color;
  const CustomizeButton(
      {Key? key,
      this.color = greencolor,
      required this.text,
      required this.onPressed,
      this.buttonHeight = 45,
      this.buttonWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth ?? MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: background,
            fontSize: fontSize15,
            fontFamily: fontfamilybeVietnam,
            fontWeight: fontWeightSemiBold,
          ),
        ),
      ),
    );
  }
}
