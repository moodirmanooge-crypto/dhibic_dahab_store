const { onRequest } = require("firebase-functions/v2/https");
const axios = require("axios");

exports.payWithWaafi = onRequest(async (req, res) => {
  try {
    const { phone, amount, referenceId, description } = req.body;

    // 🔥 FIX: ensure minimum 0.01 + 2 decimal format
    let parsedAmount = parseFloat(amount);

    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({
        error: "Amount must be greater than 0",
      });
    }

    if (parsedAmount < 0.01) {
      parsedAmount = 0.01;
    }

    // 🔥 IMPORTANT: send as string with 2 decimals
    const finalAmount = parsedAmount.toFixed(2);

    const payload = {
      schemaVersion: "1.0",
      requestId: Date.now().toString(),
      timestamp: new Date().toISOString(),
      channelName: "WEB",
      serviceName: "API_PURCHASE",
      serviceParams: {
        merchantUid: "M0914174",
        apiUserId: "1008694",
        apiKey: "API-QMfqbsf1V6qFSxyQgQ2Nbq3DjHoF",
        paymentMethod: "MWALLET_ACCOUNT",
        payerInfo: {
          accountNo: phone,
        },
        transactionInfo: {
          referenceId: referenceId,
          invoiceId: referenceId,
          amount: finalAmount, // ✅ FIXED HERE
          currency: "USD",
          description: description,
        },
      },
    };

    console.log("REQUEST:", payload);

    const waafiRes = await axios.post(
      "https://api.waafipay.net/asm",
      payload,
      {
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      }
    );

    console.log("WAFFI RESPONSE:", waafiRes.data);

    return res.status(200).json(waafiRes.data);
  } catch (e) {
    console.error("ERROR:", e.response?.data || e.message);

    return res.status(500).json({
      error: e.response?.data || e.message,
    });
  }
});