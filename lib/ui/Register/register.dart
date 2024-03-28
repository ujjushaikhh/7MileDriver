import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:driverflow/ui/Otp/otp.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import '../../constant/api_constant.dart';
import '../../constant/color_constant.dart';
import '../../constant/font_constant.dart';
import '../../constant/image_constant.dart';
import '../../utils/button.dart';
import '../../utils/dailog.dart';
import '../../utils/fcmtoken.dart';
import '../../utils/internetconnection.dart';
import '../../utils/progressdialogue.dart';
import '../../utils/sharedprefs.dart';
import '../../utils/textfeild.dart';
import '../../utils/textwidget.dart';
import '../../utils/validation.dart';
import 'model/registermodel.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  @override
  void initState() {
    super.initState();
    countrycode = '1';
  }

  final _emailcontroller = TextEditingController();
  final _passcontroller = TextEditingController();
  final _fullnamecontroller = TextEditingController();
  final _mobilecontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? countrycode;

  bool mobileError = false;
  DateTime selectedDate = DateTime.now();

  String getDeviceType() {
    if (Platform.isAndroid) {
      return 'A';
    } else {
      return 'I';
    }
  }

  Future<dynamic> getregisterapi() async {
    final devicetoken = await NotificationSet().requestUserPermission();
    debugPrint("Fcm token $devicetoken");
    if (await checkUserConnection()) {
      try {
        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);

        var headers = {
          'Content-Type': 'application/json',
        };
        var request = http.Request('POST', Uri.parse(registerurl));

        request.body = json.encode({
          "email": _emailcontroller.text,
          "password": _passcontroller.text,
          "device_type": getDeviceType(),
          "name": _fullnamecontroller.text,
          "phone": _mobilecontroller.text,
          "date_of_birth": selectedDate.toLocal().toString(),
          "device_id": devicetoken.toString(),
          "country_code": '+' '${countrycode.toString()}'
        });

        debugPrint("body:- ${request.body}");
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var registerModel = RegisterModel.fromJson(jsonResponse);
        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (registerModel.status == 1) {
            setString('userlogin', '1');
            setString('token', registerModel.data!.apiToken.toString());
            setString('name', registerModel.data!.name.toString());
            setString('mobilenum', registerModel.data!.phone!.toString());
            setString('email', registerModel.data!.email!.toString());
            setBool('getNoti', registerModel.data!.isNotification!);
            setString(
                'countrycode', registerModel.data!.countryCode!.toString());
            setString('userimage', registerModel.data!.profileImage.toString());
            setString('isAdded', registerModel.data!.isAdded!.toString());
            setState(() {
              Fluttertoast.showToast(msg: 'You\'re register successfully');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOtpScreen()),
              );
            });
          } else {
            debugPrint('failed to login');
            ProgressDialogUtils.dismissProgressDialog();
            if (!mounted) return;
            vapeAlertDialogue(
                context: context,
                desc: registerModel.message,
                onPressed: () {
                  Navigator.pop(context);
                }).show();
          }
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
              context: context,
              desc: 'There is no account with that user name & password !',
              onPressed: () {
                Navigator.pop(context);
              }).show();
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
              context: context,
              desc: "${registerModel.message}",
              onPressed: () {
                Navigator.pop(context);
              }).show();
        } else if (response.statusCode == 404) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
              context: context,
              desc: "${registerModel.message}",
              onPressed: () {
                Navigator.pop(context);
              }).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
              context: context,
              desc: "${registerModel.message}",
              onPressed: () {
                Navigator.pop(context);
              }).show();
        }
      } catch (e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (!mounted) return;
        debugPrint('$e');
        vapeAlertDialogue(
            context: context,
            desc: 'Something went wrong',
            onPressed: () {
              Navigator.pop(context);
            }).show();
      }
    } else {
      if (!mounted) return;
      vapeAlertDialogue(
          context: context,
          type: AlertType.info,
          desc: 'Please check your internet connection',
          onPressed: () {
            Navigator.pop(context);
          }).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: getBottomtext(),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: background,
            image: DecorationImage(
                image: AssetImage(icBackground), fit: BoxFit.cover)),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getLogo(),
                      getLogin(),
                      getFullnameFeild(),
                      getLoginFeild(),
                      getMobileFeild(),
                      getDobtext(),
                      getDobform(),
                      getPasswordFeild(),
                      getLoginButton()
                    ]),
              ),
            ),
            const Spacer(),
            getBottomtext()
          ],
        ),
      ),
    );
  }

  Widget getDobtext() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: getTextWidget(
          title: 'Date of Birth',
          textAlign: TextAlign.left,
          textFontSize: fontSize15,
          textFontWeight: fontWeightMedium,
          textColor: whitecolor),
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

  bool _decideWhichDayToEnable(DateTime day) {
    // Enable all previous and current dates, disable future dates
    return day.isBefore(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        selectableDayPredicate: _decideWhichDayToEnable,
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: greencolor,
                  onPrimary: background,
                  onSurface: background,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: greencolor,
                  ),
                ),
              ),
              child: child!);
        },
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget getDobform() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        readOnly: true,
        onTap: () {
          _selectDate(context);
        },
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(color: whitecolor),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 16.0,
          ),
          hintText: DateFormat('dd-MM-yyyy').format(selectedDate),
          hintStyle: const TextStyle(
            color: whitecolor,
            fontSize: fontSize14,
            fontWeight: fontWeightRegular,
            fontFamily: fontfamilybeVietnam,
          ),
          fillColor: background,
          filled: true,
          enabled: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 24.0,
                color: whitecolor,
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(
              width: 1.0,
              color: bordercolor,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: bordercolor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: bordercolor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: bordercolor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: bordererror),
          ),
        ),
      ),
    );
  }

  Widget getLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 33.0),
        child: getTextWidget(
            title: 'Create an Account',
            textColor: whitecolor,
            textFontSize: fontSize27,
            textFontWeight: fontWeightBold),
      ),
    );
  }

  Widget getFullnameFeild() {
    return Padding(
      padding: const EdgeInsets.only(top: 22.0),
      child: TextFormDriver(
        prefixIcon: icUser,
        controller: _fullnamecontroller,
        hintText: 'Full Name',
        validation: (value) => Validation.validateName(value),
      ),
    );
  }

  Widget getMobileFeild() {
    return Padding(
      padding: const EdgeInsets.only(top: 22.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: background,
            border: Border.all(color: mobileError ? bordererror : bordercolor),
            borderRadius: BorderRadius.circular(6.0)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).

                  //Optional. Shows phone code before the country name.
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    setState(() {
                      countrycode = country.phoneCode;
                    });
                  },
                  // Optional. Sets the theme for the country list picker.
                  countryListTheme: CountryListThemeData(
                    // Optional. Sets the border radius for the bottomsheet.
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    // Optional. Styles the search field.
                    inputDecoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Start typing to search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF8C98A8).withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 0.1,
                      onPressed: () {},
                      icon: Image.asset(
                        icMobile,
                        height: 24,
                        width: 24,
                        color: whitecolor,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: getTextWidget(
                            title: '+ $countrycode',
                            textFontSize: fontSize16,
                            textFontWeight: fontWeightRegular,
                            textColor: whitecolor)),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: whitecolor,
                    )
                  ],
                ),
              )),
          Container(
            decoration: BoxDecoration(
                color: background,
                border: Border.all(color: bordercolor),
                borderRadius: BorderRadius.circular(6.0)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextFormField(
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                      color: whitecolor,
                      fontFamily: fontfamilybeVietnam,
                      fontWeight: fontWeightMedium,
                      fontSize: fontSize14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 16.0),
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(
                      color: hintcolor,
                      fontSize: fontSize14,
                      fontWeight: fontWeightMedium,
                      fontFamily: fontfamilybeVietnam,
                    ),
                    // fillColor: background,

                    // filled: true,
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(
                    //     width: 1.0,
                    //     color: bordercolor,
                    //   ),
                    // ),
                    // disabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordercolor),
                    // ),
                    // enabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordercolor),
                    // ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordercolor),
                    // ),
                    // errorBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordererror),
                    // ),
                  ),
                  controller: _mobilecontroller,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    setState(() {
                      mobileError =
                          Validation.validateMobileNumber(value) != null;
                    });
                    return Validation.validateMobileNumber(value);
                  }),
            ),
          )
        ]),
      ),

      // Row(
      //   children: [
      //     GestureDetector(
      //       onTap: () {
      //         showCountryPicker(
      //             context: context,
      //             showPhoneCode: true,
      //             countryListTheme: CountryListThemeData(
      //               // Optional. Sets the border radius for the bottomsheet.
      //               borderRadius: const BorderRadius.only(
      //                 topLeft: Radius.circular(40.0),
      //                 topRight: Radius.circular(40.0),
      //               ),
      //               // Optional. Styles the search field.
      //               inputDecoration: InputDecoration(
      //                 labelText: 'Search',
      //                 hintText: 'Start typing to search',
      //                 prefixIcon: const Icon(Icons.search),
      //                 border: OutlineInputBorder(
      //                   borderSide: BorderSide(
      //                     color: const Color(0xFF8C98A8).withOpacity(0.2),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             onSelect: (Country country) {
      //               setState(() {
      //                 countrycode = country.phoneCode;
      //               });
      //             });
      //       },
      //       child: Padding(
      //         padding: const EdgeInsets.all(0.0),
      //         child: Row(
      //           children: [
      //             IconButton(
      //               splashRadius: 0.1,
      //               onPressed: () {},
      //               icon: Image.asset(
      //                 icMobile,
      //                 height: 24,
      //                 width: 24,
      //               ),
      //             ),
      //             Padding(
      //                 padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      //                 child: getTextWidget(
      //                     title: '+' "$countrycode",
      //                     textFontSize: fontSize16,
      //                     textFontWeight: fontWeightRegular,
      //                     textColor: background)),
      //             const Icon(Icons.arrow_drop_down)
      //           ],
      //         ),
      //       ),
      //     ),
      //     Container(
      //       //color: Color(0xff020202).withOpacity(0.2),
      //       width: 1,
      //       //height: 32,
      //       decoration: BoxDecoration(
      //           border: Border.all(color: const Color(0xffE8E8E8))),
      //     ),
      //     Expanded(
      //       child: TextFormDriver(
      //         // prefixIcon: icMobile,
      //         controller: _mobilecontroller,
      //         keyboardType: TextInputType.number,
      //         hintText: 'Mobile Number',
      //         validation: (value) => Validation.validateMobileNumber(value),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget getLoginFeild() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: TextFormDriver(
        prefixIcon: icEmail,
        controller: _emailcontroller,
        hintText: 'Email',
        keyboardType: TextInputType.emailAddress,
        validation: (value) => Validation.validateEmail(value),
      ),
    );
  }

  Widget getLoginButton() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 22.0,
      ),
      child: CustomizeButton(
          text: 'Register',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => MyOtpScreen(
              //               countryCode: countrycode,
              //               phonenumber: _mobilecontroller.text.toString(),
              //             )),
              //     (route) => false);
              getregisterapi();
            }
          }),
    );
  }

  Widget getPasswordFeild() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
      ),
      child: TextFormDriver(
        controller: _passcontroller,
        hintText: 'Password',
        prefixIcon: icPassword,
        suffixIcon: icCloseeye,
        validation: (value) => Validation.validatePassword(value),
        obscureText: true,
      ),
    );
  }

  Widget getBottomtext() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(
                  color: whitecolor,
                  fontSize: fontSize15,
                  fontFamily: fontfamilybeVietnam,
                  fontWeight: fontWeightRegular,
                ),
              ),
              WidgetSpan(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: greencolor,
                      fontSize: fontSize15,
                      fontFamily: fontfamilybeVietnam,
                      fontWeight: fontWeightSemiBold,
                    ),
                  ),
                ),
              ),
              const TextSpan(
                text: '.',
                style: TextStyle(
                  color: whitecolor,
                  fontSize: fontSize15,
                  fontFamily: fontfamilybeVietnam,
                  fontWeight: fontWeightBold,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
