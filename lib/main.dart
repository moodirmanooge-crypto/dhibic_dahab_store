import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 PROVIDERS
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';

import 'localization/app_localizations.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/admin_notifications.dart';
import 'screens/admin_panel.dart';
import 'screens/delivery/driver_login_screen.dart';
import 'screens/pdf_viewer_screen.dart';

import 'service/ad_service.dart';
import 'service/notification_service.dart';

// 🔥 PRELOAD (SPEED)
Future<void> preloadAppData() async {
  FirebaseFirestore.instance.collection("products").limit(20).get();
  FirebaseFirestore.instance.collection("merchant").limit(10).get();
}

// 🔥 PROMO
Future<void> applyPromoIfExists() async {
  final prefs = await SharedPreferences.getInstance();
  final promoCode = prefs.getString("promoCode");
  final user = FirebaseAuth.instance.currentUser;

  if (promoCode != null && user != null) {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    final snap = await ref.get();
    final used = snap.data()?["usedPromo"] ?? false;

    if (!used) {
      await ref.set({
        "points": FieldValue.increment(5),
        "usedPromo": true,
        "promoCode": promoCode,
      }, SetOptions(merge: true));
    }
  }
}

// 🔥 BACKGROUND
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();
}

// 🔥 TOKEN
Future<void> saveFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "fcmToken": newToken,
    }, SetOptions(merge: true));
  });

  String? token = await FirebaseMessaging.instance.getToken();

  if (token != null) {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "fcmToken": token,
    }, SetOptions(merge: true));
  }
}

// 🚀 MAIN
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await NotificationService.init();

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await saveFcmToken();

  // 🔥 FAST START (NO WAIT)
  preloadAppData();
  applyPromoIfExists();

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      NotificationService.showNotification(
        title: message.notification?.title ?? "Notification",
        body: message.notification?.body ?? "",
      );
    },
  );

  AdService.loadAppOpenAd();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider()..loadLanguage(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// 🟢 APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dhibic Dahab",
      locale: langProvider.locale,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFD4AF37),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
      ),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        _AppLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale("en"),
        Locale("so"),
        Locale("ar"),
        Locale("tr"),
        Locale("de"),
      ],
      routes: {
        "/login": (_) => const LoginScreen(),
        "/main": (_) => const MainScreen(),
        "/driverLogin": (_) => const DriverLoginScreen(),
        "/adminNotifications": (_) => const AdminNotifications(),
      },
      home: const AuthGate(),
    );
  }
}

// 🟢 AUTH GATE (🔥 FAST FIX)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return const MainScreen();
      },
    );
  }
}

// 🌍 LOCALIZATION
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ["en", "so", "ar", "tr", "de"]
          .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}