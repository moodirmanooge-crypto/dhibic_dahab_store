import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {

  static Future init() async {

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

  }

}