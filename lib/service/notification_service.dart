import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  static final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  /// 🔥 INIT NOTIFICATION SERVICE
  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings =
        InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin
        .initialize(settings);

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// 🔥 SAVE TOKEN FIRST TIME
    await saveUserToken();

    /// 🔥 TOKEN REFRESH AUTO
    messaging.onTokenRefresh.listen(
      (newToken) async {
        await updateToken(newToken);
      },
    );

    /// 🔥 FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        showNotification(
          title:
              message.notification?.title ??
                  "New Notification",
          body:
              message.notification?.body ??
                  "",
        );
      },
    );
  }

  /// 🔥 SAVE TOKEN TO FIRESTORE
  static Future<void> saveUserToken() async {
    String? token =
        await messaging.getToken();

    if (token == null) return;

    await updateToken(token);
  }

  /// 🔥 UPDATE TOKEN
  static Future<void> updateToken(
      String token) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    /// role from users collection
    final userDoc = await firestore
        .collection("users")
        .doc(user.uid)
        .get();

    String role = "customer";

    if (userDoc.exists) {
      role =
          userDoc.data()?["role"] ??
              "customer";
    }

    /// 🔥 SAVE TOKEN TO USERS
    await firestore
        .collection("users")
        .doc(user.uid)
        .set({
      "uid": user.uid,
      "fcmToken": token,
      "role": role,
      "updatedAt":
          FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    /// 🔥 SAVE TO MERCHANT COLLECTION IF MERCHANT
    if (role == "merchant") {
      await firestore
          .collection("merchant")
          .doc(user.uid)
          .set({
        "fcmToken": token,
        "updatedAt":
            FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// 🔥 LOCAL POPUP NOTIFICATION
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails =
        AndroidNotificationDetails(
      'dhibic_channel',
      'Dhibic Notifications',
      channelDescription:
          'Orders and chats notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details =
        NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin
        .show(
      DateTime.now()
          .millisecondsSinceEpoch
          .remainder(100000),
      title,
      body,
      details,
    );
  }

  /// 🔥 ORDER NOTIFICATION SAVE
  static Future<void> saveOrderNotification({
    required String merchantId,
    required String title,
    required String body,
  }) async {
    await firestore
        .collection("notifications")
        .add({
      "merchantId": merchantId,
      "title": title,
      "body": body,
      "type": "order",
      "createdAt":
          FieldValue.serverTimestamp(),
      "isRead": false,
    });
  }

  /// 🔥 CHAT NOTIFICATION SAVE
  static Future<void> saveChatNotification({
    required String merchantId,
    required String title,
    required String body,
  }) async {
    await firestore
        .collection("notifications")
        .add({
      "merchantId": merchantId,
      "title": title,
      "body": body,
      "type": "chat",
      "createdAt":
          FieldValue.serverTimestamp(),
      "isRead": false,
    });
  }
}