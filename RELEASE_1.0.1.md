## 📦 Version 1.0.1 – Telemetry, Automation & Fixes

### 🚀 Changes

* **Anonymous Daily Telemetry:**
  Added a new `LoggingService` to track daily active usage anonymously, including platform detection (mobile/web). Users can opt-out from the settings menu.

* **Build & Deploy Automation:**
  Created `build_and_deploy.ps1` script to automate APK & Web builds, Vercel deployments, and GitHub Releases.

* **Import/Export Enhancements:**
  Added a "Copy All" button to easily copy the generated JSON payload from the export dialog in the home screen.

* **App Icon Generation:**
  Regenerated app icons and integrated web launcher icon support into `pubspec.yaml`.

### 🐛 Bug Fixes

* Fixed Kotlin DSL compilation issues (`java.util.Properties` unresolved references) in `build.gradle.kts`.
* Resolved Android signing keystore file path resolution bug for release builds.

---

## 📦 Sürüm 1.0.1 – Telemetri, Otomasyon ve Düzeltmeler

### 🚀 Değişiklikler

* **Anonim Günlük Telemetri:**
  Günlük aktif kullanımı anonim olarak takip etmek için platform algılamalı (mobil/web) yeni bir `LoggingService` eklendi. Kullanıcılar ayarlar menüsünden bu özelliği kapatabilir.

* **Derleme ve Dağıtım Otomasyonu:**
  APK ve Web derlemelerini, Vercel dağıtımlarını ve GitHub Sürüm (Release) yayınlarını otomatikleştirmek için `build_and_deploy.ps1` scripti oluşturuldu.

* **İçe/Dışa Aktarma Geliştirmeleri:**
  Ana ekrandaki dışa aktarma penceresine, üretilen JSON verisini anında kopyalamak için "Tümünü Kopyala" butonu eklendi.

* **Uygulama İkonları:**
  Uygulama logoları yeniden oluşturuldu ve web ikon desteği `pubspec.yaml` dosyasına eklendi.

### 🐛 Hata Düzeltmeleri

* `build.gradle.kts` içindeki Kotlin DSL derleme hataları (`java.util.Properties` vb.) düzeltildi.
* Release derlemeleri (APK) sırasında Android imza (keystore) dosya yolunun yanlış algılanması hatası giderildi.
