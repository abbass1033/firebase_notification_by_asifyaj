
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notification_by_asifyaj/messages_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' as IO;

class NotificationServices {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  void initialLocalNotification(BuildContext context , RemoteMessage message)async{
    var androidInitializeMessageSetting  = const AndroidInitializationSettings("@mipmap/ic_launcher");

    var iosInitializeMessageSetting = const  DarwinInitializationSettings(
        requestAlertPermission:  true,
        requestBadgePermission: true,
        requestCriticalPermission: true,
        requestSoundPermission: true
    );

    var initializeSetting = InitializationSettings(
        android: androidInitializeMessageSetting,
        iOS: iosInitializeMessageSetting,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializeSetting ,

    onDidReceiveNotificationResponse: (payLoad){
        handleMessages(context , message);
    }
    );

  }


  void firebaseInit(BuildContext context)async{
    FirebaseMessaging.onMessage.listen((message) async {
      if (IO.Platform.isAndroid) {
        initialLocalNotification(context, message);
        showNotification(message);
      }
      else {
        showNotification(message);
      }
    });


  }



  Future<void> showNotification(RemoteMessage message)async{
    
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(1000000).toString(),
        "high important notification",
    importance: Importance.max,
      playSound: true,


    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "pushnotificationapp",
        channel.name.toString(),
        channelDescription: "your channel description",
        icon: '@mipmap/ic_launcher',
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        //sound: RawResourceAndroidNotificationSound('notification'),
        ticker: "ticker",
          enableLights: true,
      actions: [
         AndroidNotificationAction('Mark', "Marked" ,),
        AndroidNotificationAction('Mark', "UnMarked", ),
        AndroidNotificationAction('Mark', "Cancel", ),
      ]
    );



    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );



    NotificationDetails notificationDetails  = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
    );
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    DateTime scheduleDate = DateTime.now().add(const Duration(seconds: 5));
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        message.notification?.title.toString(),
        message.notification?.body.toString(),
        tz.TZDateTime.from(scheduleDate, tz.local),
        notificationDetails ,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
        payload: "notification-payload"
    );



    Future.delayed(Duration.zero , (){
      _flutterLocalNotificationsPlugin.show(
          id,
          message.notification?.title.toString(),
          message.notification?.body.toString(),
          notificationDetails,
        payload: message.data['_id'],
      );
    }
    );

    _flutterLocalNotificationsPlugin.cancel(id);
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

  // when app is in terminated or in background
  void setInteractMessage(BuildContext context)async{
    RemoteMessage? initMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initMessage != null){
      handleMessages(context, initMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
     handleMessages(context, message);
    },

    );
    }

  void handleMessages(BuildContext context, RemoteMessage message , ){

    if(message.data["type"] == "abas")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MessagesScreen(
        id : message.data["id"]
      )));
    }else{
      print("gsdgsad");
    }
  }

}