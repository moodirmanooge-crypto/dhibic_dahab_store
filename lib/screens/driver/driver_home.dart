import 'package:flutter/material.dart';

// ✅ Waxaan ka saarnay 'import map_screen.dart' maadaama uu error bixinayo

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  int currentIndex = 0;

  // ✅ Waxaan ku beddelnay MapScreen meel bannaan (Container)
  final List<Widget> screens = [
    const Center(child: Text("Dalabaadka Cusub (Orders)")), // Index 0
    const Center(child: Text("Map-ka hadda waa naafo (Disabled)")), // Index 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.orangeAccent,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        ],
      ),
    );
  }
}