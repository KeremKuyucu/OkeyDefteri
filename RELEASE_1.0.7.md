## 📦 Version 1.0.7 – Cloud Backup, Americano Solo Mode & Scoring Enhancements

### 🚀 Changes

* **Cloud Backup & Supabase Sync:**
  Added cloud backup and cross-device sync powered by Supabase and Google Sign-In. Users can now securely back up, restore, and sync their game records across devices.

* **Americano Solo Mode:**
  Added support for 4-player solo (individual) Americano game mode alongside the existing team mode. In solo mode, team score displays are automatically hidden.

* **Americano Penalty Updates:**
  Added the "Finish with Misplay" (İşlek Atarak Bitti) penalty (+100 points) and allowed ending rounds with "No Winner / Tiles Out" (Kimse Bitmedi / Taş Bitti).

* **101 Okey Round Enhancements:**
  Added the "No Winner / Tiles Out" round end mode with quick penalty options (+202 button) and trophy/win counters on player scores.

* **Bilingual Localization:**
  Full English and Turkish localization support for all newly added cloud management, game options, and score entries.

* **Robust Data Serialization:**
  Enum values in game data are now serialized as readable string names instead of integer indexes, ensuring backward and forward compatibility.

### 🐛 Bug Fixes

* Configured web OAuth redirect URL for production (`https://okey.keremkk.com.tr/`).
* Fixed missing localization strings across game modes and score input dialogs.

---

## 📦 Sürüm 1.0.7 – Bulut Yedekleme, Americano Tekli Mod & Skor Geliştirmeleri

### 🚀 Değişiklikler

* **Bulut Yedekleme & Supabase Senkronizasyonu:**
  Google Sign-In ve Supabase altyapısı ile bulut yedekleme eklendi. Kullanıcılar artık maç kayıtlarını buluta yedekleyebilir, farklı cihazlara aktarabilir ve tek dokunuşla geri yükleyebilir.

* **Americano Tekli Mod Desteği:**
  Mevcut takımlı modun yanı sıra 4 kişilik bireysel (tekli) Americano modu eklendi. Tekli modda takım skor çubuğu otomatik olarak gizlenir.

* **Americano Ceza Güncellemeleri:**
  "İşlek Atarak Bitti" ceza seçeneği (+100 puan) ve "Kimse Bitmedi / Taş Bitti" durumunda turu kaydetme desteği eklendi.

* **101 Okey Tur Geliştirmeleri:**
  101 Okey için "Kimse Bitmedi (Taş Bitti)" tur sonu modu, hızlı +202 açamadı butonu ve el bitirenler için kupa/galibiyet takibi eklendi.

* **Tam Türkçe & İngilizce Desteği:**
  Tüm yeni bulut yönetimi, Americano alt modları ve ceza seçenekleri için eksiksiz Türkçe ve İngilizce dil desteği sağlandı.

* **Gelişmiş Veri Kayıt Yapısı:**
  Oyun kayıtlarında enum değerleri sayısal index yerine isim tabanlı kaydedilerek olası veri uyuşmazlıkları ve kayıpları engellendi.

### 🐛 Hata Düzeltmeleri

* Web OAuth yönlendirme adresi canlı ortam (`https://okey.keremkk.com.tr/`) için yapılandırıldı.
* Oyun modları ve skor diyaloglarında eksik olan dil çeviri anahtarları tamamlandı.
