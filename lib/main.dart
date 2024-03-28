import 'dart:io';

import 'package:driverflow/ui/Splash/splash.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAbeJH46hKqlBOxw4qV8YyuGKOuxIDUKnU",
            appId: "1:478923021746:ios:81640a29c54bdc93b758ab",
            messagingSenderId: "478923021746",
            projectId: 'mile-vapeandhape-customerflow'));
  } else {
    await Firebase.initializeApp();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MaterialApp(
    home: MySplash(),
    debugShowCheckedModeBanner: false,
  ));
}
