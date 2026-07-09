## 📦 Version 1.0.3 – Americano Game Mode

### 🚀 Changes

* **New Game Mode — Americano:**
  Added a brand-new game mode called "Americano" alongside the existing 101 (Okey) mode. Americano is a 12-round card game where each round requires opening a specific combination before any other moves.

* **Round Rule Banner:**
  In Americano games, a slide-in animated banner at the top of the screen clearly displays the current round number and the required opening combination (e.g. "Round 3 / 12 — 2 Three-Card Sets"). Tapping the banner opens the full 12-round rules list with the current round highlighted.

* **Americano Score Dialog:**
  A dedicated round-end score entry dialog allows selecting the round winner (0 pts), entering remaining card values for each other player (Joker = 50 pts), and toggling 🎯 Misplay (+50) and 🚫 Cheating (+50) penalties per player.

* **In-Round Penalty Dialog:**
  Tapping any player card during an Americano game opens a quick penalty dialog to add İşlek or Hile penalties at any point during the round, without waiting for round end.

* **Game Mode Selection in New Game Screen:**
  The "New Game" screen now features a visual mode picker where players can choose between 🀄 101 (Okey) and 🃏 Americano before starting. Each chip shows the mode name, emoji, and a short description.

* **Past Games Mode Badge:**
  The past games list now shows a small 🃏 AMR / 🀄 101 badge on every game card, making it easy to distinguish between game modes at a glance.

* **Undo Round & Prev/Next Round:**
  All round management features from the 101 screen (undo last score, go to previous round with confirmation) are available in Americano as well.

* **Localization:**
  Added 30+ Americano-specific translation keys in both Turkish and English, including all 12 round rule descriptions, scoring labels, and UI strings.

### 🐛 Bug Fixes

* Fixed `directive_after_declaration` error in `game_models.dart` caused by `import` placed after an `enum` declaration.

---

## 📦 Sürüm 1.0.3 – Americano Oyun Modu

### 🚀 Değişiklikler

* **Yeni Oyun Modu — Americano:**
  Mevcut 101 (Okey) modunun yanına "Americano" adlı yeni bir oyun modu eklendi. Americano, 12 turlu bir kart oyunudur; her turda, başka hamle yapmadan önce belirli bir kombinasyonu açmak gerekir.

* **Tur Kural Banneri:**
  Americano oyunlarında ekranın üstünde, mevcut tur numarasını ve gerekli açılış kombinasyonunu gösteren animasyonlu bir banner görüntülenir (ör. "Tur 3 / 12 — 2 Üçlü Küt"). Bannera dokunulduğunda mevcut tur vurgulu olarak tüm 12 tur listesi açılır.

* **Americano Puan Giriş Dialogu:**
  Tur sonu dialogunda tur kazananını seçebilir (0 puan), diğer oyuncular için elde kalan kart değerini girebilir (Joker = 50 puan) ve her oyuncu için 🎯 İşlek (+50) ve 🚫 Hile (+50) cezalarını toggle ile ekleyebilirsiniz.

* **Tur İçi Ceza Dialogu:**
  Americano oyununda herhangi bir oyuncu kartına dokunulduğunda, tur sonu beklenmeden anlık İşlek veya Hile cezası eklenebilen hızlı bir dialog açılır.

* **Yeni Oyun Ekranında Mod Seçimi:**
  "Yeni Oyun" ekranına, oyuncuların 🀄 101 (Okey) ile 🃏 Americano arasında seçim yapabileceği görsel bir mod seçici eklendi. Her chip, mod adını, emoji'sini ve kısa bir açıklamasını gösterir.

* **Geçmiş Oyunlarda Mod Badge'i:**
  Geçmiş oyunlar listesindeki her oyun kartında artık küçük bir 🃏 AMR / 🀄 101 badge'i görünmektedir.

* **Tur Geri Alma ve İleri/Geri Tur:**
  101 ekranındaki tüm tur yönetimi özellikleri (son puanı geri al, önceki tura dön onayı) Americano'da da kullanılabilir.

* **Yerelleştirme:**
  Türkçe ve İngilizce dil dosyalarına, 12 tur kural açıklamaları, puan etiketleri ve arayüz metinleri dahil 30'dan fazla Americano'ya özel çeviri anahtarı eklendi.

### 🐛 Hata Düzeltmeleri

* `game_models.dart` dosyasında `enum` tanımından sonra gelen `import` ifadesinin yol açtığı `directive_after_declaration` hatası giderildi.
