import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WaafiPaymentService {
  static Future<Map<String, dynamic>> makePayment({
    required String phone,
    required double amount,
    required String referenceId,
    required String description,
  }) async {
    try {
      final url = Uri.parse(
        "https://us-central1-dhibic-dahab-online-store.cloudfunctions.net/payWithWaafi",
      );

      final payload = {
        "phone": phone.trim(),
        "amount": amount.round(), // ✅ integer required by Waafi
        "referenceId": referenceId,
        "description": description,
      };

      debugPrint("➡️ REQUEST: ${jsonEncode(payload)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      debugPrint("⬅️ STATUS CODE: ${response.statusCode}");
      debugPrint("⬅️ BODY: ${response.body}");

      if (response.statusCode != 200) {
        return {
          "responseMsg": "HTTP ERROR ${response.statusCode}",
          "responseCode": response.statusCode,
          "rawBody": response.body,
        };
      }

      final decoded = jsonDecode(response.body);

      // ✅ fallback si crash uusan u dhicin
      if (decoded == null || decoded is! Map<String, dynamic>) {
        return {
          "responseMsg": "INVALID RESPONSE",
          "rawBody": response.body,
        };
      }

      return decoded;
    } catch (e) {
      debugPrint("❌ WAAFI ERROR: $e");

      return {
        "responseMsg": "EXCEPTION ERROR",
        "error": e.toString(),
      };
    }
  }
}