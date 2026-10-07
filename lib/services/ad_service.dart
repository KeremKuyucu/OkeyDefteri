import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Tüm reklam işlemlerini merkezi olarak yöneten servis.
/// Sadece Android platformunda çalışacak şekilde yapılandırılmıştır.
class AdService {
  AdService._();

  // AdMob Reklam Birimi Kimlikleri (Yalnızca Android)
  static const String bannerAdUnitId = 'ca-app-pub-4674396016131447/7054889708';
  static const String interstitialAdUnitId = 'ca-app-pub-4674396016131447/8600025809';

  /// Reklamların sadece Android platformunda çalışmasını sağlar
  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;
  static bool _isMobileAdsInitialized = false;

  /// Reklam servisini, UMP rıza akışını ve hedeflenmiş reklam yapılandırmasını başlatır
  static Future<void> init() async {
    if (!isSupported) return;
    try {
      // Hedeflenmiş / kişiselleştirilmiş reklamların kısıtlanmaması için çocuk ve yaş ayarlarını yapılandır
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        ),
      );

      // Google UMP (User Messaging Platform) rıza formu ve hedeflenmiş reklam izni akışı
      final params = ConsentRequestParameters();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          ConsentForm.loadAndShowConsentFormIfRequired((loadAndShowError) async {
            if (loadAndShowError != null) {
              debugPrint('AdService: Rıza formu hatası: ${loadAndShowError.message}');
            }
            if (await ConsentInformation.instance.canRequestAds()) {
              await _initializeMobileAds();
            }
          });
        },
        (FormError error) async {
          debugPrint('AdService: Rıza bilgi güncelleme hatası: ${error.message}');
          // Ağ veya rıza servisi hatasında yine de SDK'yı başlat
          await _initializeMobileAds();
        },
      );

      // Önceden izin verilmişse veya izin gerekmiyorsa doğrudan başlat
      if (await ConsentInformation.instance.canRequestAds()) {
        await _initializeMobileAds();
      }
    } catch (e) {
      debugPrint('AdService: init hatası: $e');
      await _initializeMobileAds();
    }
  }

  static Future<void> _initializeMobileAds() async {
    if (_isMobileAdsInitialized) return;
    _isMobileAdsInitialized = true;
    try {
      await MobileAds.instance.initialize();
      loadInterstitialAd();
    } catch (e) {
      debugPrint('AdService: MobileAds initialize hatası: $e');
    }
  }

  /// Kullanıcının hedeflenmiş reklam ve gizlilik tercihlerini açar
  static void showPrivacyOptionsForm(BuildContext context) {
    if (!isSupported) return;
    try {
      ConsentForm.showPrivacyOptionsForm((FormError? formError) {
        if (formError != null) {
          debugPrint('AdService: Gizlilik formu hatası: ${formError.message}');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(formError.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          debugPrint('AdService: Gizlilik tercihleri güncellendi.');
        }
      });
    } catch (e) {
      debugPrint('AdService: showPrivacyOptionsForm hatası: $e');
    }
  }

  /// Geçiş reklamını arka planda önceden yükler
  static void loadInterstitialAd() {
    if (!isSupported || _isLoadingInterstitial || _interstitialAd != null) return;

    _isLoadingInterstitial = true;
    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdService: InterstitialAd loaded.');
            _interstitialAd = ad;
            _isLoadingInterstitial = false;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('AdService: InterstitialAd failed to load: $error');
            _interstitialAd = null;
            _isLoadingInterstitial = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService: InterstitialAd load hatası: $e');
      _isLoadingInterstitial = false;
    }
  }

  /// Geçiş reklamını gösterir.
  /// Reklam kapatıldığında, gösterilemediğinde veya desteklenmediğinde [onDismissed] tetiklenir.
  static void showInterstitialAd({required VoidCallback onDismissed}) {
    if (!isSupported || _interstitialAd == null) {
      onDismissed();
      loadInterstitialAd();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;

    try {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onDismissed();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('AdService: InterstitialAd failed to show: $error');
          ad.dispose();
          onDismissed();
          loadInterstitialAd();
        },
      );

      ad.show();
    } catch (e) {
      debugPrint('AdService: InterstitialAd show hatası: $e');
      ad.dispose();
      onDismissed();
      loadInterstitialAd();
    }
  }

  /// Banner reklam nesnesi oluşturur
  static BannerAd? createBannerAd({
    required VoidCallback onAdLoaded,
    required void Function(LoadAdError) onAdFailedToLoad,
  }) {
    if (!isSupported) return null;

    try {
      return BannerAd(
        adUnitId: bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('AdService: BannerAd loaded.');
            onAdLoaded();
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('AdService: BannerAd failed to load: $err');
            ad.dispose();
            onAdFailedToLoad(err);
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService: BannerAd create hatası: $e');
      return null;
    }
  }

  /// Bellekteki geçiş reklamını serbest bırakır
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoadingInterstitial = false;
  }
}
