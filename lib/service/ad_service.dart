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
          print("✅ App Open Ad Loaded");
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("❌ Failed to load ad: $error");
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
      print("⚠️ No ad available yet");
    }
  }
}