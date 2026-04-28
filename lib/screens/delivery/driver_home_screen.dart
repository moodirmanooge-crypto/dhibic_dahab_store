import 'package:flutter/material.dart';
import 'driver_orders_screen.dart';
import 'driver_wallet_screen.dart';
import 'driver_profile_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final String driverId;

  const DriverHomeScreen({super.key, required this.driverId});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {

  int index = 0;

  @override
  Widget build(BuildContext context) {

    final screens = [
      DriverOrdersScreen(driverId: widget.driverId),
      DriverWalletScreen(driverId: widget.driverId),
      DriverProfileScreen(driverId: widget.driverId),
    ];

    return Scaffold(
      body: screens[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}