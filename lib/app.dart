import 'package:flutter/material.dart';

// Waxaan halkan ku reebnay kaliya screens-ka aad dhabta u isticmaalayso
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pdf_viewer_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dhibic Dahab Store',
      theme: ThemeData(
        primaryColor: Colors.green, // Waxaan u badalnay primaryColor maadaama Swatch uu yahay mid duug ah
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      // Bogga ugu horreeya ee app-ka furmayo
      initialRoute: '/main',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        // OTP halkan waa laga saaray si uusan error kuu siin
      },

      /// 🔥 DYNAMIC ROUTES (PDF Viewer)
      onGenerateRoute: (settings) {
        if (settings.name == '/pdf') {
          final pdfUrl = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              pdfUrl: pdfUrl,
              title: "Read Book",
            ),
          );
        }

        return null;
      },
    );
  }
}