import 'dart:convert';

import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/utils/button.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:driverflow/utils/textfeild.dart';
import 'package:driverflow/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../constant/font_constant.dart';
import '../../../constant/image_constant.dart';
import '../../../utils/dailog.dart';
import '../../../utils/internetconnection.dart';
import '../../../utils/progressdialogue.dart';
import '../../../utils/textwidget.dart';
import 'model/changepassword.dart';

class MyChangePassword extends StatefulWidget {
  const MyChangePassword({super.key});

  @override
  State<MyChangePassword> createState() => _MyChangePasswordState();
}

class _MyChangePasswordState extends State<MyChangePassword> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confrimPassword = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  Future<void> updatePassapi() async {
    if (await checkUserConnection()) {
      try {
        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);

        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };
        debugPrint('$headers');
        debugPrint(getString('token'));

        var request = http.Request('POST', Uri.parse(changepasswordurl));
        request.body = json.encode(
            {'oldpassword': _oldPassword.text, 'password': _newPassword.text});
        request.headers.addAll(headers);
        debugPrint('Body :- ${request.body}');

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var getcartdetailModel = ChangePasswordModel.fromJson(jsonResponse);
        debugPrint(responsed.body);
        if (response.statusCode == 200) {
          ProgressDialogUtils.dismissProgressDialog();
          if (getcartdetailModel.status == 1) {
            setState(() {
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'Password updated Successfully');
              //   Navigator.pushReplacement(context,
              //       MaterialPageRoute(builder: (context) => SucessScreen()));
            });
          } else {
            ProgressDialogUtils.dismissProgressDialog();
            if (!mounted) return;
            vapeAlertDialogue(
              context: context,
              desc: '${getcartdetailModel.message}',
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getcartdetailModel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 404) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getcartdetailModel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getcartdetailModel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: 'Internal Server Error: ${getcartdetailModel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        }
      } catch (e) {
        ProgressDialogUtils.dismissProgressDialog();
        debugPrint("$e");
        if (!mounted) return;
        vapeAlertDialogue(
          context: context,
          desc: 'Something went Wrong',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ).show();
      }
    } else {
      if (!mounted) return;
      vapeAlertDialogue(
        context: context,
        desc: 'Check internet connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitecolor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: background,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Icon(
                Icons.arrow_back,
                color: whitecolor,
              ),
            )),
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'Change password',
              textColor: whitecolor,
              textFontWeight: fontWeightMedium,
              textFontSize: fontSize15),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
        ),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getImage(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: getTextWidget(
                    title: 'Current Password',
                    textFontSize: fontSize14,
                    textColor: blackcolor,
                    textFontWeight: fontWeightMedium),
              ),
              _getOldPasswordfeild(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: getTextWidget(
                    title: 'New Password',
                    textFontSize: fontSize14,
                    textColor: blackcolor,
                    textFontWeight: fontWeightMedium),
              ),
              _getNewPasswordfeild(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: getTextWidget(
                    title: 'Confirm New Password',
                    textFontSize: fontSize14,
                    textColor: blackcolor,
                    textFontWeight: fontWeightMedium),
              ),
              _getConfirmPasswordfeild(),
              _getButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 21.0),
        child: Container(
          height: 147,
          width: 147,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    icChangepass,
                  ),
                  fit: BoxFit.cover)),
        ),
      ),
    );
  }

  Widget _getButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: CustomizeButton(
                text: 'Reset Password',
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    updatePassapi();
                  }
                })),
      ),
    );
  }

  Widget _getOldPasswordfeild() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 9.0, bottom: 16),
      child: TextFormDriver(
        prefixIcon: icPassword,
        borderColor: dropdownborder,
        fillColor: whitecolor,
        suffixIcon: icCloseeye,
        prefixiconcolor: background,
        suffixiconcolor: background,
        validation: (value) => Validation.validateText(value),
        obscureText: true,
        controller: _oldPassword,
        textstyle: background,
        hintText: 'Current Password',
      ),
    );
  }

  Widget _getNewPasswordfeild() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 9.0, bottom: 16),
      child: TextFormDriver(
        prefixIcon: icPassword,
        borderColor: dropdownborder,
        fillColor: whitecolor,
        suffixIcon: icCloseeye,
        textstyle: background,
        validation: (value) => Validation.validateText(value),
        prefixiconcolor: background,
        suffixiconcolor: background,
        obscureText: true,
        controller: _newPassword,
        hintText: ' New Password',
      ),
    );
  }

  Widget _getConfirmPasswordfeild() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 9.0, bottom: 16),
      child: TextFormDriver(
        prefixIcon: icPassword,
        borderColor: dropdownborder,
        textstyle: background,
        fillColor: whitecolor,
        prefixiconcolor: background,
        suffixiconcolor: background,
        validation: (value) => Validation.validateText(value),
        controller: _confrimPassword,
        hintText: 'Confirm New Password',
      ),
    );
  }
}
