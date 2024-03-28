import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<String?> getToken() async {
  String? token;
  try {
    token = await FirebaseMessaging.instance.getToken();
    return token;
  } catch (e) {
    debugPrint(e.toString());
    return token;
  }
}

class NotificationSet {
  Future<String?> requestUserPermission() async {
    // final authStatus = await FirebaseMessaging.instance.requestPermission();
    // final enabled = authStatus == AuthorizationStatus.authorized ||
    //     authStatus == AuthorizationStatus.provisional;

    // debugPrint('Authorization status: $authStatus');

    // if (enabled) {
    //   await getFcmToken();
    // }
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await getToken();
      return token;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      final token = await getToken();
      return token;
    } else {
      debugPrint('User declined or has not accepted permission');
      debugPrint("okokokokokok");
      debugPrint('${settings.authorizationStatus}');
      return '';
    }
  }
}
