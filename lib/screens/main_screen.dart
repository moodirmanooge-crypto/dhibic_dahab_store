import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'reading_screen.dart';
import 'profile_screen.dart';
import 'exchange_screen.dart';
import 'delivery/delivery_request_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // ❌ const removed (important fix)
    screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const DeliveryRequestScreen(
        usePoints: false,
      ),
      const ReadingScreen(),
      const ExchangeScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 SAFE BODY
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFFD4AF37),
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
            label: "Delivery",
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