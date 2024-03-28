import 'dart:async';

import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Add%20Document/add_document.dart';
import 'package:driverflow/ui/Add%20Vehicle/add_vehicle.dart';
import 'package:driverflow/ui/Home/home.dart';
import 'package:flutter/material.dart';

import '../../utils/sharedprefs.dart';
import '../Intro/intro_screen.dart';
import '../login/login.dart';

class MySplash extends StatefulWidget {
  const MySplash({super.key});

  @override
  State<MySplash> createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  void initState() {
    super.initState();
    _showSpalsh();
  }

  _showSpalsh() async {
    if (getBool('seen') == false) {
      Timer(const Duration(seconds: 3), () async {
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyIntro()),
            (route) => false);
      });
    } else if (getBool('seen') == true) {
      if (getString('userlogin') != '1') {
        Timer(const Duration(seconds: 3), () async {
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyLogin()),
              (route) => false);
        });
      } else if (getString('vehicledoc') != '1') {
        Timer(const Duration(seconds: 3), () async {
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyAddVehicle()),
              (route) => false);
        });
      } else if (getString('isAdded') != '1') {
        Timer(const Duration(seconds: 3), () async {
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyAddDoc()),
              (route) => false);
        });
      } else {
        Timer(const Duration(seconds: 3), () async {
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHome()),
              (route) => false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: background,
            image: DecorationImage(
                image: AssetImage(icBackground), fit: BoxFit.cover)),
        child: Center(
            child: Image.asset(
          icLogo,
          width: 169,
          height: 109,
        )),
      ),
    );
  }
}
