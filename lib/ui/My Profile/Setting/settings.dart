import 'dart:convert';

import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/constant/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import '../../../constant/font_constant.dart';
import '../../../utils/dailog.dart';
import '../../../utils/internetconnection.dart';
import '../../../utils/progressdialogue.dart';
import '../../../utils/sharedprefs.dart';
import '../../../utils/textwidget.dart';
import 'model/settingmodel.dart';

class MySetting extends StatefulWidget {
  const MySetting({super.key});

  @override
  State<MySetting> createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  bool? isSwitchEmail = false;
  bool? isSwitchSMS = getBool('getNoti');

  // int? getNoti = getInt('getNoti');

  Future<dynamic> settingapi(int notification) async {
    if (await checkUserConnection()) {
      try {
        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);

        var apichange = drivernotificationonOffurl;
        var token = getString('token');
        debugPrint('Token: $token');
        var headers = {
          'authkey': "Bearer $token",
          'Content-Type': 'application/json',
        };

        var request = http.Request('POST', Uri.parse(apichange));

        request.headers.addAll(headers);

        request.body = json.encode({"is_notification": notification});
        debugPrint(request.body);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var settingmodel = SettingModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (settingmodel.status == 1) {
            debugPrint('debugPrint this ${settingmodel.message}');
          } else {
            if (!mounted) return;
            debugPrint(settingmodel.message);
            vapeAlertDialogue(
              context: context,
              desc: '${settingmodel.message}',
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();

          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${settingmodel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else {
          ProgressDialogUtils.dismissProgressDialog();

          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${settingmodel.message}',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ).show();
        }
      } catch (error) {
        ProgressDialogUtils.dismissProgressDialog();
        debugPrint("$error");

        if (!mounted) return;
        vapeAlertDialogue(
          context: context,
          desc: 'Something went wrong',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ).show();
      }
    } else {
      ProgressDialogUtils.dismissProgressDialog();

      if (!mounted) return;
      vapeAlertDialogue(
        context: context,
        desc: 'Check Internet Connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: background,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: whitecolor,
                size: 24,
              )),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'Settings',
              textFontSize: fontSize15,
              textFontWeight: fontWeightMedium,
              textColor: whitecolor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getTextWidget(
                    title: 'Email Notification',
                    textFontSize: fontSize14,
                    textFontWeight: fontWeightMedium,
                    textColor: background),
                _getEmailButton()
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          const Divider(
            color: dropdownborder,
            thickness: 1.0,
            height: 2.0,
          ),
          // const SizedBox(
          //   height: 15.0,
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getTextWidget(
                    title: "SMS Notification ",
                    textFontSize: fontSize14,
                    textColor: background,
                    textFontWeight: fontWeightMedium),
                _getSMS(),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          const Divider(
            color: dividercolor,
            thickness: 1.0,
            height: 2.0,
          ),
        ],
      ),
    );
  }

  Widget _getSMS() {
    return SizedBox(
      width: 60,
      height: 34,
      child: CupertinoSwitch(
        value: isSwitchSMS!,
        activeColor: orangecolor,
        trackColor: trackcolor,
        onChanged: (value) {
          if (isSwitchSMS! == false) {
            setState(() {
              settingapi(1);
              setBool('getNoti', true);
              isSwitchSMS = true;
            });
          } else {
            setState(() {
              settingapi(0);
              setBool('getNoti', false);
              isSwitchSMS = false;
            });
          }
        },
      ),
    );
  }

  Widget _getEmailButton() {
    return SizedBox(
      width: 60,
      height: 37,
      child: CupertinoSwitch(
        value: isSwitchEmail!,
        activeColor: orangecolor,
        trackColor: trackcolor,
        onChanged: (value) {
          if (isSwitchEmail == true) {
            setState(() {
              // setBool('notification', false);
              isSwitchEmail = false;
              // setInt('getNoti', 0);
              // settingapi(0);
            });
          } else {
            setState(() {
              // setInt('getNoti', 1);
              isSwitchEmail = true;
              // settingapi(1);
            });
          }
        },
      ),
    );
  }
}
