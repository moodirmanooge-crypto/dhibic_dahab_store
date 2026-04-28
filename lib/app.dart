import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dhibic Dahab Store',
      theme: ThemeData(primarySwatch: Colors.green),

      initialRoute: '/main',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OtpScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
