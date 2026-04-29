import 'package:flutter/foundation.dart'; // ✅ debugPrint awgeed ayaa loogu daray
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static AppOpenAd? _appOpenAd;

  // 🔥 TEST AD ID (use this first)
  static const String appOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          debugPrint("✅ App Open Ad Loaded"); // ✅ debugPrint ayaa lagu beddelay
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("❌ Failed to load ad: $error"); // ✅ debugPrint ayaa lagu beddelay
        },
      ),
    );
  }

  static void showAppOpenAd() {
    if (_appOpenAd != null) {
      _appOpenAd!.show();
      _appOpenAd = null;

      // 🔥 preload next ad
      loadAppOpenAd();
    } else {
      debugPrint("⚠️ No ad available yet"); // ✅ debugPrint ayaa lagu beddelay
    }
  }
}