## 📦 Version 1.0.5 – AdMob Integration & Score Logic Fixes

### 🚀 Changes

* **Interstitial Ad Integration:**
  Added Interstitial Ads that trigger when moving to the next round, utilizing pre-loading for a seamless user experience.

* **Banner Ad Environment Handling:**
  Updated the AdBannerWidget to automatically use AdMob Test IDs during debug mode and Production IDs during release mode.

### 🐛 Bug Fixes

* **Teammate Scoring Fix:**
  Fixed an issue in the end-of-round dialog where it was possible to enter penalty points for the winner's teammate. The dialog now automatically assigns 0 penalty points to the teammate and hides the input field.

---

## 📦 Sürüm 1.0.5 – AdMob Entegrasyonu & Puan Mantığı Düzeltmeleri

### 🚀 Değişiklikler

* **Geçiş Reklamı (Interstitial Ad) Entegrasyonu:**
  "Sonraki Tur" butonuna basıldığında tetiklenen tam ekran geçiş reklamları eklendi. Kullanıcı deneyimini bozmamak adına reklamlar arka planda önceden yükleniyor.

* **Banner Reklam Ortam Yönetimi:**
  AdBannerWidget, geliştirme (debug) modunda test kimliklerini, canlı (release) modda ise gerçek reklam kimliklerini otomatik olarak kullanacak şekilde güncellendi.

### 🐛 Hata Düzeltmeleri

* **Takım Arkadaşı Puanı Düzeltmesi:**
  Tur sonu puan girişi ekranında, kazanan kişinin takım arkadaşı için ceza puanı girilebilmesi sorunu giderildi. Artık takım arkadaşı otomatik algılanarak ceza puanı 0 (sıfır) olarak kabul ediliyor ve puan giriş kutusu gizleniyor.
