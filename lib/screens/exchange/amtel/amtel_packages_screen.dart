import 'package:flutter/material.dart';
import 'amtel_payment_screen.dart';

class AmtelPackagesScreen extends StatelessWidget {
  final String title;
  final String type;

  const AmtelPackagesScreen({
    super.key,
    required this.title,
    required this.type,
  });

  static const Color primaryColor = Color(0xFF060B4F);

  List<Map<String, String>> get packages {
    if (type == "bulaal") {
      return [
        {
          "title": "Bulaal Unlimited",
          "old": "\$0.25",
          "new": "\$0.23",
          "desc": "10 saac",
          "image": "assets/images/bulaal.png"
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$0.5",
          "new": "\$0.46",
          "desc": "36 saac",
          "image": "assets/images/bulaal.png"
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$1",
          "new": "\$0.92",
          "desc": "6 maalin",
          "image": "assets/images/bulaal.png"
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$2.5",
          "new": "\$2.30",
          "desc": "1 usbuuc",
          "image": "assets/images/bulaal.png"
        },
        {
          "title": "Bulaal Unlimited",
          "old": "\$10",
          "new": "\$9.20",
          "desc": "1 bil",
          "image": "assets/images/bulaal.png"
        },
      ];
    }

    if (type == "tanaad") {
      return [
        {
          "title": "Tanaad",
          "old": "\$0.1",
          "new": "\$0.09",
          "desc": "500MB",
          "image": "assets/images/tanaad.png"
        },
        {
          "title": "Tanaad",
          "old": "\$0.25",
          "new": "\$0.24",
          "desc": "1GB",
          "image": "assets/images/tanaad.png"
        },
        {
          "title": "Tanaad",
          "old": "\$0.5",
          "new": "\$0.46",
          "desc": "2GB",
          "image": "assets/images/tanaad.png"
        },
        {
          "title": "Tanaad",
          "old": "\$1",
          "new": "\$0.92",
          "desc": "4GB",
          "image": "assets/images/tanaad.png"
        },
        {
          "title": "Tanaad",
          "old": "\$3",
          "new": "\$2.76",
          "desc": "10GB",
          "image": "assets/images/tanaad.png"
        },
        {
          "title": "Tanaad",
          "old": "\$5",
          "new": "\$4.60",
          "desc": "25GB",
          "image": "assets/images/tanaad.png"
        },
      ];
    }

    return [
      {
        "title": "Amtel Ku Hadal",
        "old": "\$0.1",
        "new": "\$0.10",
        "desc": "3 maalin",
        "image": "assets/images/amtel.png"
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$0.25",
        "new": "\$0.25",
        "desc": "7 maalin",
        "image": "assets/images/amtel.png"
      },
      {
        "title": "Amtel Ku Hadal",
        "old": "\$0.5",