

import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  void initialLocalNotification(BuildContext context , RemoteMessage message)async{
    var androidInitializeMessageSetting  = const AndroidInitializationSettings("@mipmap/ic_launchar");

    var iosInitializeMessageSetting = const  DarwinInitializationSettings();

    var initializeSetting = InitializationSettings(
        android: androidInitializeMessageSetting,
        iOS: iosInitializeMessageSetting
    );

    await _flutterLocalNotificationsPlugin.initialize(initializeSetting ,
    onDidReceiveNotificationResponse: (payLoad){

    }
    );

  }

  void firebaseInit()async{
    FirebaseMessaging.onMessage.listen((message) async{

      showNotification(message);
      print("firebase message : ${message.notification?.title.toString()}");
      print("firebase message : ${message.notification?.body.toString()}");
    });
  }


  Future<void> showNotification(RemoteMessage message)async{
    
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(1000).toString(),
        "high important notification",
    importance: Importance.max

    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(

        channel.id.toString(),
        channel.name.toString(),
        channelDescription: "Your channel description",
        importance: Importance.max,
        priority: Priority.high,
        ticker: "ticker"
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );


    Future.delayed(Duration.zero , (){
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification?.title.toString(),
          message.notification?.body.toString(),
          notificationDetails
      );
    }
    );
  }


  void requestNotificationPermission()async{

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true

    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      if (kDebugMode) {
        print("user granted permission");
      }
    }
    else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      if (kDebugMode) {
        print("user provisional permission");
      }
    }
    else{
      if (kDebugMode) {
        print("user denied permission");
      }
    }
  }

  Future<String> getDeviceToken()async{
    String? token = await messaging.getToken();
    return token!;
  }



  //refresh token
  void isTokenRefresh()async{
  messaging.onTokenRefresh.listen((event) {
      event.toString();
  });
  }

}