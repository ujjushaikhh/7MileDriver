import 'package:flutter/material.dart';

import '../../constant/color_constant.dart';
import '../../constant/font_constant.dart';
import '../../constant/image_constant.dart';
import '../../utils/button.dart';
import '../../utils/textfeild.dart';
import '../../utils/textwidget.dart';
import '../../utils/validation.dart';

class MyForgotPassword extends StatefulWidget {
  const MyForgotPassword({super.key});

  @override
  State<MyForgotPassword> createState() => _MyForgotPasswordState();
}

class _MyForgotPasswordState extends State<MyForgotPassword> {
  final _emailcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: background,
            image: DecorationImage(
                image: AssetImage(icBackground), fit: BoxFit.cover)),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getLogo(),
              getLogin(),
              getSubTitle(),
              getLoginFeild(),
              getLoginButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget getLoginButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 24, right: 24),
      child: CustomizeButton(
          text: 'Submit',
          onPressed: () {
            if (_formkey.currentState!.validate()) {
              debugPrint("Forgot Success ");
            } else {
              debugPrint("please enter an email");
            }
          }),
    );
  }

  Widget getLoginFeild() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 24, top: 17.0),
      child: TextFormDriver(
        prefixIcon: icEmail,
        keyboardType: TextInputType.emailAddress,
        controller: _emailcontroller,
        hintText: 'Email',
        validation: (value) => Validation.validateEmail(value),
      ),
    );
  }

  Widget getLogo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: Container(
          width: 169,
          height: 109,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(icLogo), fit: BoxFit.cover)),
        ),
      ),
    );
  }

  Widget getLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 33.0),
        child: getTextWidget(
            title: 'Forgot Password',
            textColor: whitecolor,
            textFontSize: fontSize27,
            textFontWeight: fontWeightBold),
      ),
    );
  }

  Widget getSubTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 36.0, top: 13, right: 36.0),
      child: Opacity(
        opacity: 0.60,
        child: getTextWidget(
            title:
                'Please enter the email address you‘d like to your password reset information sent to.',
            textColor: whitecolor,
            textFontSize: fontSize14,
            textAlign: TextAlign.center,
            textFontWeight: fontWeightRegular),
      ),
    );
  }
}
