import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Added
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';

import 'localization/app_localizations.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/exchange_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/admin_notifications.dart';

// ✅ DELIVERY + DRIVER
import 'screens/delivery/delivery_request_screen.dart';
import 'screens/delivery/driver_login_screen.dart';

// 🔥 Messaging Background Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  // 🔥 INITIALIZE FIREBASE (AS REQUESTED)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 🔥 THIS IS THE KEY

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  await FirebaseMessaging.instance.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LanguageProvider()..loadLanguage(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadTheme(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

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
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.grey,
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
        "/addProduct": (context) {
          final raw = ModalRoute.of(context)?.settings.arguments;

          if (raw is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(child: Text("Invalid arguments")),
            );
          }

          final args = raw;

          return AddProductScreen(
            merchantId: args["merchantId"]?.toString() ?? "",
            category: args["category"]?.toString() ?? "",
          );
        },

        "/adminNotifications": (context) =>
            const AdminNotifications(),
      },

      home: const AuthGate(), // ✅ First Screen
    );
  }
}

/// 🔐 AUTH GATE
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

        if (snapshot.hasData) {
          return const MainScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

/// 🔻 MAIN SCREEN (Bottom Navigation)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    // ✅ Waxaan halkan ku dhex qeexay liiska screen-nada si looga fogaado error-ka 'currentLang'
    final List<Widget> screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const DeliveryRequestScreen(usePoints: false), // ✅ Index 2
      const ReadingScreen(),
      const ExchangeScreen(),
      ProfileScreen(currentLang: langProvider.locale.languageCode), // ✅ Index 5 (La waafajiyey Profile-kaaga cusub)
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dhibic Dahab"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "merchant") {
                Navigator.pushNamed(context, "/addProduct");
              } else if (value == "driver") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DriverLoginScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "merchant",
                child: Text("Merchant Login"),
              ),
              const PopupMenuItem(
                value: "driver",
                child: Text("Driver Login 🚚"),
              ),
            ],
          )
        ],
      ),

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: "Delivery", // ✅ Active Tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Reading",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: "Exchange",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

/// 🌐 LOCALIZATION DELEGATE
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {

  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ["en","so","ar","tr","de"]
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}