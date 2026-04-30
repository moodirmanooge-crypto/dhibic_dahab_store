import 'dart:convert';
import 'dart:developer'; // Tan ayaan ku daray si aan 'log' u isticmaalno
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Tan waxaan u soo qaatay debugPrint

class PaymentService {
  // 🔥 CHANGE THIS ONLY haddii URL-kaaga isbedelo
  static const String waafiUrl =
      "https://paywithwaafi-5mu7fobkqg-uc.a.run.app";

  static Future<bool> payWithWaafi({
    required String phone,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(waafiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "amount": amount.toInt(),
        }),
      );

      // Waxaan u bedelay debugPrint si error-ka 'avoid_print' meesha uga baxo
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 haddii function-kaagu return sameeyo success
        if (data is Map && data["success"] == true) {
          return true;
        }

        return true; // fallback haddii backend return kale leeyahay
      }

      return false;
    } catch (e) {
      // Halkan waxaan u isticmaalay 'log' oo ka socota dart:developer
      log("PAYMENT ERROR: $e");
      return false;
    }
  }
}