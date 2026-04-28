import 'dart:convert';
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
        "https://api.waafipay.net/asm",
      );

      final payload = {
        "schemaVersion": "1.0",
        "requestId": DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        "timestamp":
            DateTime.now().toIso8601String(),
        "channelName": "WEB",
        "serviceName": "API_PURCHASE",
        "serviceParams": {
          "merchantUid": "M0914174",
          "apiUserId": "1008694",
          "apiKey":
              "YOUR_REAL_API_KEY",
          "paymentMethod":
              "MWALLET_ACCOUNT",
          "payerInfo": {
            "accountNo": phone,
          },
          "transactionInfo": {
            "referenceId":
                referenceId,
            "invoiceId":
                referenceId,
            "amount": amount,
            "currency": "USD",
            "description":
                description,
          }
        }
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type":
              "application/json",
          "Accept":
              "application/json",
        },
        body: jsonEncode(payload),
      );

      print(
          "STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode != 200) {
        return {
          "responseMsg":
              "HTTP ERROR ${response.statusCode}",
          "responseCode":
              response.statusCode,
          "rawBody": response.body,
        };
      }

      final decoded =
          jsonDecode(response.body);

      return decoded;
    } catch (e) {
      print("WAAFI ERROR: $e");

      return {
        "responseMsg":
            "EXCEPTION ERROR",
        "error": e.toString(),
      };
    }
  }
}