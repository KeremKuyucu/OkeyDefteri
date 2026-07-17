## 📦 Version 1.0.6 – Display Fix & Android 16 Compatibility

### 🐛 Bug Fixes

* **Screen Flip Fix:**
  Fixed a critical issue where the screen content was rendered upside down (180° flipped) on certain devices. The issue was caused by GPU driver incompatibility with the Impeller rendering engine.

* **Android 16 (API 36) Orientation Lock:**
  Added compatibility property to ensure the portrait orientation lock works correctly on Android 16+ devices, which introduced new restrictions on screen orientation locking.

---

## 📦 Sürüm 1.0.6 – Ekran Düzeltmesi & Android 16 Uyumluluğu

### 🐛 Hata Düzeltmeleri

* **Ekran Ters Dönme Düzeltmesi:**
  Belirli cihazlarda ekran içeriğinin 180° ters görüntülenmesine neden olan kritik bir hata giderildi. Sorun, Impeller render motorunun bazı GPU sürücüleriyle uyumsuzluğundan kaynaklanıyordu.

* **Android 16 (API 36) Oryantasyon Kilidi:**
  Android 16 ile gelen yeni ekran yönü kısıtlamalarına karşı uyumluluk özelliği eklendi. Dikey (portrait) mod kilidi artık Android 16+ cihazlarda da doğru şekilde çalışıyor.
