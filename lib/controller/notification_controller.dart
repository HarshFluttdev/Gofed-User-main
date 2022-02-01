import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController {
  FirebaseMessaging messaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin localNot = FlutterLocalNotificationsPlugin();

  static Future<dynamic> backgroundMessageHandler(
    Map<String, dynamic> message,
  ) async {
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.updateBadgeCount(1);
    }

    return;
  }

  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Ride', 'Ride name', 'Ride notifications',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSChannelSpecifics,
    );
    await localNot.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'test',
    );
  }

  NotificationController(BuildContext context) {
    try {
      var initializationSettingsAndroid =
          new AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      localNot.initialize(initializationSettings);
      messaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true),
      );
      messaging.configure(
        onLaunch: (message) async {
          return;
        },
        onResume: (message) async {
          return;
        },
        onMessage: (message) async {
          var title = message['notification']['title'];
          var body = message['notification']['body'];
          return;
        },
        onBackgroundMessage: Platform.isIOS ? null : backgroundMessageHandler,
      );
      messaging.subscribeToTopic('root');
    } catch (e) {
      print(e);
    }
  }
}
