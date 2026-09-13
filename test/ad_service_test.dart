import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okey_defteri/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    AdService.dispose();
  });

  group('AdService tests', () {
    test('ad unit IDs are configured with production IDs directly', () {
      expect(
        AdService.bannerAdUnitId,
        equals('ca-app-pub-4674396016131447/7054889708'),
      );
      expect(
        AdService.interstitialAdUnitId,
        equals('ca-app-pub-4674396016131447/8600025809'),
      );
    });

    test('isSupported is true only for Android platform', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(AdService.isSupported, isTrue);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(AdService.isSupported, isFalse);

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(AdService.isSupported, isFalse);

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(AdService.isSupported, isFalse);

      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(AdService.isSupported, isFalse);
    });

    test('createBannerAd returns null when platform is not Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final bannerAd = AdService.createBannerAd(
        onAdLoaded: () {},
        onAdFailedToLoad: (err) {},
      );
      expect(bannerAd, isNull);
    });

    test('showInterstitialAd invokes onDismissed immediately when unsupported', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      bool dismissed = false;

      AdService.showInterstitialAd(
        onDismissed: () {
          dismissed = true;
        },
      );

      expect(dismissed, isTrue);
    });

    test('showInterstitialAd invokes onDismissed if no ad is loaded on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      bool dismissed = false;

      AdService.showInterstitialAd(
        onDismissed: () {
          dismissed = true;
        },
      );

      expect(dismissed, isTrue);
    });
  });
}
