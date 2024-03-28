import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/constant/font_constant.dart';
import 'package:driverflow/ui/Add%20Vehicle/add_vehicle.dart';
import 'package:driverflow/utils/button.dart';
import 'package:driverflow/utils/dailog.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:driverflow/utils/textwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../constant/color_constant.dart';
import '../../constant/image_constant.dart';
import '../../utils/internetconnection.dart';
import '../../utils/progressdialogue.dart';
import 'model/verifyotpmodel.dart';

class MyOtpScreen extends StatefulWidget {
  // final String? countryCode;
  // final String? phonenumber;
  const MyOtpScreen({
    super.key,
  });

  @override
  State<MyOtpScreen> createState() => _MyOtpScreenState();
}

class _MyOtpScreenState extends State<MyOtpScreen> {
  TextEditingController otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  int start = 60;
  bool wait = false;
  String getCountryCode = getString('countrycode');
  String getphonenumber = getString('mobilenum');

  String? verifyID;

  int? resendToken;
  int? resend;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      startTimer();
      loginWithPhone();
    });
    debugPrint('$getCountryCode' '$getphonenumber');
    // debugPrint(getCountryCode + getphonenumber);
  }

  Future<dynamic> getverifiedapi() async {
    if (await checkUserConnection()) {
      try {
        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);

        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };
        var request = http.Request('GET', Uri.parse(verifyotpurl));

        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var verifymodel = VerifyOtpModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (verifymodel.status == 1) {
            // debugPrint('Is registered or not $isAlreadyRegister');
            if (!mounted) return;
            setState(() {
              Fluttertoast.showToast(msg: '${verifymodel.message}');
              verifyOTP();
            });
          } else {
            debugPrint('failed to login');
            ProgressDialogUtils.dismissProgressDialog();
            if (!mounted) return;
            vapeAlertDialogue(
                context: context,
                desc: '${verifymodel.message}',
                onPressed: () {
                  Navigator.pop(context);
                }).show();
          }
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          //  displayToast("There is no account with that user name & password !");
          vapeAlertDialogue(
              context: context,
              desc: 'There is no account with that user name & password !',
              onPressed: () {
                Navigator.pop(context);
              }).show();
        } else if (response.statusCode == 404) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          //  displayToast("There is no account with that user name & password !");
          vapeAlertDialogue(
              context: context,
              desc: "${verifymodel.message}",
              onPressed: () {
                Navigator.pop(context);
              }).show();
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          //  displayToast("There is no account with that user name & password !");
          vapeAlertDialogue(
              context: context,
              desc: "${verifymodel.message}",
              onPressed: () {
                Navigator.pop(context);
              }).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          //  displayToast("There is no account with that user name & password !");
          vapeAlertDialogue(
              context: context,
              desc: "${verifymodel.message}",
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
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: background,
            image: DecorationImage(
                image: AssetImage(icBackground), fit: BoxFit.cover)),
        child: Column(
          children: [
            getVerify(),
            getText(),
            getTextAgain(),
            getNumber(),
            getOtp(),
            getTimer(),
            getButton()
          ],
        ),
      ),
    );
  }

  Widget getVerify() {
    return Padding(
      padding: const EdgeInsets.only(top: 128.0),
      child: Image.asset(
        icVerify,
        height: 93,
        width: 93,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget getText() {
    return Padding(
      padding: const EdgeInsets.only(top: 33.0),
      child: getTextWidget(
          title: 'Verify',
          textFontSize: fontSize27,
          textFontWeight: fontWeightBold,
          textColor: whitecolor),
    );
  }

  Widget getTextAgain() {
    return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: getTextWidget(
            title: 'Enter OTP Code sent to your mobile number',
            textFontSize: fontSize14,
            textFontWeight: fontWeightRegular,
            textColor: whitecolor));
  }

  Widget getNumber() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getTextWidget(
          title: '$getCountryCode' '$getphonenumber',
          textFontSize: fontSize14,
          textFontWeight: fontWeightSemiBold,
        ),
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset(
              icEditProfile,
              height: 24.0,
              width: 24.0,
              fit: BoxFit.cover,
            ))
      ],
    );
  }

  Widget getButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
      child: CustomizeButton(
          text: 'Submit',
          onPressed: () {
            getverifiedapi();
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: ((context) => const MyAddVehicle())));
          }),
    );
  }

  Widget getOtp() {
    return SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0, left: 50, right: 50),
          child: PinCodeTextField(
            enableActiveFill: true,
            cursorColor: whitecolor,
            keyboardType: TextInputType.number,
            autoFocus: true,
            textStyle: const TextStyle(
                color: whitecolor,
                fontFamily: fontfamilybeVietnam,
                fontSize: fontSize22,
                fontWeight: fontWeightSemiBold),
            onChanged: (value) {},
            onCompleted: (String verificationCode) {
              otpController.text = verificationCode;
            },
            appContext: context,
            length: 6,
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 45,
                fieldWidth: 45,
                activeFillColor: background,
                inactiveColor: bordercolor,
                inactiveFillColor: background,
                selectedFillColor: background,
                selectedColor: bordercolor,
                activeColor: greencolor),
          ),
        ));
  }

  Widget getTimer() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: start == 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getTextWidget(
                    title: "Don’t receive the code? ",
                    textColor: whitecolor,
                    textFontSize: fontSize16,
                    textFontWeight: fontWeightSemiBold),
                InkWell(
                  onTap: () {
                    if (!wait) {
                      resendCode();
                      startTimer();
                    }
                  },
                  child: getTextWidget(
                      title: "Resend",
                      textColor: greencolor,
                      textFontSize: fontSize16,
                      textFontWeight: fontWeightBold),
                )
              ],
            )
          : Text(
              '00:$start',
              style: const TextStyle(
                color: whitecolor,
                fontSize: fontSize14,
                fontWeight: fontWeightRegular,
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  void resendCode() async {
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 0),
      phoneNumber: '$getCountryCode' '$getphonenumber',
      // getCountryCode + getphonenumber,
      //  '${getString(userCountryCode)}${getString(userNumber)}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          debugPrint("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.message);
        if (kDebugMode) {
          log(e.code);
          log(e.message.toString());
          log(e.credential.toString());
          // log(e.code);
        }
      },
      codeSent: (String verificationId, int? token) {
        if (kDebugMode) {
          log(verificationId);
          log(token.toString());
          // log(e.credential.toString());
          // log(e.code);
        }
        if (!mounted) return;
        setState(() {
          verifyID = verificationId;
          resendToken = token; // Update the resendToken value
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken:
          resendToken, // Provide the resendToken when resending the code
    );
  }

  void verifyOTP() async {
    debugPrint(otpController.text);
    debugPrint(verifyID.toString());
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verifyID!, smsCode: otpController.text);
    try {
      await auth.signInWithCredential(credential).then((value) {
        debugPrint('loginsuccessfull');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyAddVehicle()),
        ); // getVerify();
      });
    } on FirebaseException catch (e) {
      if (e.code == 'invalid-verification-code') {
        debugPrint('failed to login');
        if (!mounted) return;
        vapeAlertDialogue(
            context: context,
            desc: "The otp you have entered is invalid",
            onPressed: () {
              Navigator.pop(context);
            }).show();
      }
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      vapeAlertDialogue(
          context: context,
          desc: "Something went wrong",
          onPressed: () {
            Navigator.pop(context);
          }).show();
      // displayToast('envalid otp ');
    }
  }

  void loginWithPhone() async {
    auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 0),
      phoneNumber: getCountryCode + getphonenumber,
      // '+' '${widget.countryCode!}' '${widget.phonenumber!}',

      // '${getString(userCountryCode)}${getString(userNumber)}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          debugPrint("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.message);
        if (kDebugMode) {
          log(e.code);
          log(e.message.toString());
          log(e.credential.toString());
          // log(e.stackTrace.toString());
          // log(e.credential.toString());
          // log(e.credential.toString());
          // log(e.code);
        }
      },
      codeSent: (String verificationId, int? resend) {
        if (!mounted) return;
        setState(() {
          verifyID = verificationId;
          resendToken = resend;
        });
        if (kDebugMode) {
          log(verificationId);
          log(resend.toString());
          // log(e.credential.toString());
          // log(e.code);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
