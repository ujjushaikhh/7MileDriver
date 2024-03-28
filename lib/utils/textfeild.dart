import 'package:driverflow/constant/color_constant.dart';
import 'package:flutter/material.dart';

import '../constant/font_constant.dart';
import '../constant/image_constant.dart';

class TextFormDriver extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? prefixIcon, suffixIcon;
  final bool filled;
  final String? Function(String?)? validation;
  final Color fillColor;
  final Color borderColor;
  final Color prefixiconcolor;
  final Color suffixiconcolor;
  final bool obscureText;
  final String? image;
  final bool enable;
  final Color hintColor;
  final Color textstyle;
  final double fontSize;
  final FontWeight fontWeight;

  const TextFormDriver(
      {super.key,
      required this.controller,
      required this.hintText,
      this.keyboardType,
      this.prefixIcon,
      this.suffixiconcolor = whitecolor,
      this.textstyle = whitecolor,
      this.prefixiconcolor = whitecolor,
      this.hintColor = hintcolor,
      this.fontSize = fontSize14,
      this.fontWeight = fontWeightRegular,
      this.enable = true,
      this.filled = true,
      this.fillColor = background,
      this.borderColor = bordercolor,
      this.suffixIcon,
      this.validation,
      this.image,
      this.obscureText = false});

  @override
  State<TextFormDriver> createState() => _TextFormDriverState();
}

class _TextFormDriverState extends State<TextFormDriver> {
  bool _obscureText = true;
  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validation,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText ? _obscureText : false,
      style: TextStyle(
          color: widget.textstyle,
          fontFamily: fontfamilybeVietnam,
          fontWeight: fontWeightMedium,
          fontSize: fontSize14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 16.0),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: widget.hintColor,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontFamily: fontfamilybeVietnam,
        ),
        fillColor: widget.fillColor,
        filled: widget.filled,
        enabled: widget.enable,
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image.asset(
                      widget.prefixIcon!,
                      color: widget.prefixiconcolor,
                    ),
                  ),
                ),
              )
            : null,
        suffixIcon: widget.suffixIcon != null
            ? GestureDetector(
                onTap: _togglePassword,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      _obscureText ? icCloseeye : icOpeneye,
                      color: widget.suffixiconcolor,
                      height: 24.0,
                      width: 24.0,
                    ),
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            width: 1.0,
            color: widget.borderColor,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: widget.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: widget.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: widget.borderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: bordererror),
        ),
      ),
    );
  }
}
