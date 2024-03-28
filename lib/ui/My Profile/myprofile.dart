import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/constant/font_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Home/home.dart';
import 'package:driverflow/ui/My%20Profile/Change%20password/change_password.dart';
import 'package:driverflow/ui/My%20Profile/Edit%20Profile/edit_profile.dart';
import 'package:driverflow/ui/My%20Profile/My%20Deliveries/my_deliveies.dart';
import 'package:driverflow/ui/My%20Profile/My%20wallet/mywallet.dart';
import 'package:driverflow/ui/My%20Profile/Setting/settings.dart';
import 'package:driverflow/ui/Notification/notification.dart';
import 'package:driverflow/ui/Terms&Condition/terms_condtion.dart';
import 'package:driverflow/ui/login/login.dart';
import 'package:driverflow/utils/dailog.dart';
import 'package:driverflow/utils/textwidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import 'package:http/http.dart' as http;

import '../../constant/api_constant.dart';
import '../../utils/internetconnection.dart';
import '../../utils/sharedprefs.dart';
import '../Home/model/notify_count.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void initState() {
    super.initState();
    getNotifycountapi();
  }

  String getName = getString('name');
  String getImage = getString('userimage');
  int? notifyCount = 0;

  Future<void> getNotifycountapi() async {
    if (await checkUserConnection()) {
      try {
        var apiurl = getnotifycounturl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(getString('token'));

        var request = http.Request('GET', Uri.parse(apiurl));

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var getNotifyCount = NotifyCountModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          // ProgressDialogUtils.dismissProgressDialog();
          if (getNotifyCount.status == 1) {
            setState(() {
              notifyCount = getNotifyCount.count ?? 0;
            });
            debugPrint('is it success');
          } else {
            debugPrint('failed to load');
          }
        } else if (response.statusCode == 401) {
          // ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {},
          ).show();
        } else if (response.statusCode == 404) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        }
      } catch (e) {
        debugPrint("$e");
        if (!mounted) return;
        vapeAlertDialogue(
          context: context,
          desc: '$e',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ).show();
      }
    } else {
      if (!mounted) return;
      vapeAlertDialogue(
        context: context,
        type: AlertType.info,
        desc: 'Please check your internet connection',
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
        backgroundColor: background,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'My Profile ',
              textFontSize: fontSize15,
              textFontWeight: fontWeightSemiBold,
              textColor: whitecolor),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHome()),
                    (route) => false);
              },
              icon: Image.asset(
                icHome,
                color: whitecolor,
                height: 24,
                width: 24,
                fit: BoxFit.cover,
              )),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 20),
            child: Stack(
              children: [
                IconButton(
                  icon: Image.asset(
                    icNotification,
                    height: 24,
                    width: 24,
                    color: whitecolor,
                  ),
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyNotification()))
                        .whenComplete(() => getNotifycountapi());
                  },
                ),
                if (notifyCount! > 0)
                  Positioned(
                    top: 1,
                    right: 3,
                    child: Container(
                      height: 22.0,
                      width: 22.0,
                      decoration: const BoxDecoration(
                        color: orangecolor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18.0,
                        minHeight: 18.0,
                      ),
                      child: Center(
                        child: Text(
                          notifyCount!.toString(),
                          style: const TextStyle(
                            color: whitecolor,
                            fontSize: fontSize13,
                            fontFamily: fontfamilybeVietnam,
                            fontWeight: fontWeightSemiBold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 17.0),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      height: 147.0,
                      width: 147.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: const BoxDecoration(
                            color: Colors.grey, shape: BoxShape.circle),
                      ),
                    ),
                    imageUrl: getImage.toString(),
                    height: 147.0,
                    width: 147.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: getTextWidget(
                  title: getName,
                  textAlign: TextAlign.center,
                  textFontSize: fontSize20,
                  textFontWeight: fontWeightSemiBold,
                  textColor: background),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 17.0),
              child: GridView.builder(
                itemCount: myprofile.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    mainAxisExtent: 112,
                    crossAxisSpacing: 15),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (myprofile[index]['route'] != null) {
                        if (myprofile[index]['title'] == 'Edit Profile') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => myprofile[index]
                                      ['route'])).whenComplete(() {
                            setState(() {
                              getImage = getString('userimage');
                              getName = getString('name');
                            });
                          });
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      myprofile[index]['route']));
                        }
                      } else {
                        Fluttertoast.showToast(msg: 'There is no route');
                      }
                    },
                    child: Container(
                      width: 164,
                      // height: 112,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: orangeBorder, width: 1)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14.0),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const ShapeDecoration(
                                color: orangeBorder,
                                shape: OvalBorder(),
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    if (myprofile[index]['route'] != null) {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      myprofile[index]
                                                          ['route']))
                                          .whenComplete(() {
                                        setState(() {
                                          getImage = getString('userimage');
                                          getName = getString('name');
                                        });
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'There is no route');
                                    }
                                  },
                                  icon: Image.asset(
                                    myprofile[index]['icon'],
                                    height: 24.0,
                                    width: 24.0,
                                    fit: BoxFit.cover,
                                    color: orangecolor,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: getTextWidget(
                                title: myprofile[index]['title'],
                                textFontSize: fontSize13,
                                textFontWeight: fontWeightRegular,
                                textColor: background),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: GestureDetector(
                onTap: () {
                  showOkCancelAlertDialog(
                      context: context,
                      message: 'Are you sure you want to logout ',
                      okButtonTitle: 'Ok',
                      isCancelEnable: true,
                      cancelButtonTitle: 'Cancel',
                      okButtonAction: () {
                        setString('userlogin', '0');
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyLogin()),
                            (route) => false);
                      });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      icLogout,
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                      color: orangecolor,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    getTextWidget(
                        title: 'Logout',
                        textFontSize: fontSize13,
                        textFontWeight: fontWeightRegular,
                        textColor: orangecolor)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List myprofile = [
    {
      'icon': icEditProfile,
      'title': 'Edit Profile',
      'route': const MyEditProfile()
    },
    {'icon': icWallet, 'title': 'My Wallet', 'route': const MyWallet()},
    {
      'icon': icDelivery,
      'title': 'My Deliveries',
      'route': const MyDeliveries()
    },
    {
      'icon': icPassword,
      'title': 'Change Password',
      'route': const MyChangePassword()
    },
    {'icon': icSetting, 'title': 'Settings', 'route': const MySetting()},
    {
      'icon': icTerms,
      'title': 'Terms & Condition',
      'route': const MyTermsandCondition()
    }
  ];
}
