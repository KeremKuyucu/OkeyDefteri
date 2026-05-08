# 🎴 Okey 101 Premium Skor Defteri

Fiziksel Okey 101 oyunlarınızın puanlarını profesyonelce takip etmek, takımları ve oyuncu performanslarını detaylı analiz etmek için geliştirilmiş, şık bir Flutter mobil uygulamasıdır.
Tamamen AI ile geliştirilmiştir. Okeyde puan tutmak için kişisel amaçlarla geliştirildi.
## ✨ Özellikler

*   **🎮 Gelişmiş Maç Takibi**: 4 kişilik (Takım 1 vs Takım 2) masa düzeninde gerçek zamanlı skor girişi.
*   **➕ Pratik Skor Girişleri**:
    *   +101 İşlek Attı
    *   +101 Okeyini Aldılar
    *   +101 Yanlış El Açtı
    *   -101 Elden Bitti
    *   +202 Açamadı
    *   Manuel Puan Girişi (Ceza / Normal)
*   **🧮 Entegre Hesap Makinesi**: El sonunda oyuncunun elinde kalan taşları tek tek girerek kolayca toplamanızı sağlar. Çiftli gitme durumunda otomatik `x2` yapar.
*   **📊 Kapsamlı İstatistikler**:
    *   Oyuncuların toplam cezaları ve hata istatistikleri.
    *   Takım galibiyet / mağlubiyet takibi.
    *   Oyuncuların geçmiş tüm maçlara göre başarı analizleri.
*   **💾 Otomatik Kayıt (Auto-Save)**: Oyun sırasında çıkış yapsanız dahi uygulama aktif oyunu hatırlar. Geçmiş tüm oyunlarınızı `SharedPreferences` ile yerel olarak depolar.
*   **🔙 Geri Alma İşlemi**: Yanlış girilen bir puanı oyuncu kartına uzun basarak (Long Press) silebilirsiniz.
*   **🎨 Premium Tasarım**: "Casino Green" ve "Gold" konseptiyle oluşturulmuş, Glass-morphism efektli koyu mod (Dark Mode) arayüz.

## 🛠 Teknoloji Yığını

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Dil**: Dart
*   **Veri Kalıcılığı**: `shared_preferences`
*   **Mimari**: Temiz mimari (MVC benzeri), ayrılmış servis, model ve UI katmanları.

## 📂 Proje Yapısı

```
lib/
├── main.dart                          # Uygulama giriş noktası ve yönlendirme
├── models/
│   └── game_models.dart               # Player, Team, Game ve ScoreEntry modelleri
├── services/
│   └── storage_service.dart           # Yerel depolama (SharedPreferences) yönetimi
├── theme/
│   └── app_theme.dart                 # Özel renk paleti, gradient'ler ve stiller
├── screens/
│   ├── home_screen.dart               # Ana giriş ekranı
│   ├── new_game_screen.dart           # Yeni oyun ve takım belirleme
│   ├── game_screen.dart               # Oyun esnası, skor masası
│   ├── score_history_screen.dart      # Maç içi tur bazlı geçmiş
│   ├── past_games_screen.dart         # Kayıtlı eski oyunlar listesi
│   └── stats_screen.dart              # Detaylı oyuncu/takım istatistikleri
└── widgets/
    ├── player_card.dart               # Oyun masası oyuncu kutucuğu
    ├── team_score_bar.dart            # Üst kısımdaki takım skor özeti
    └── score_input_dialog.dart        # Kapsamlı puan ekleme ve hesap makinesi arayüzü
```

## 🚀 Kurulum ve Çalıştırma

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

1.  **Flutter SDK**'nın yüklü olduğundan emin olun.
2.  Depoyu bilgisayarınıza indirin veya klonlayın.
3.  Terminal veya komut istemcisinde proje dizinine gidin.
4.  Bağımlılıkları yüklemek için:
    ```bash
    flutter pub get
    ```
5.  Uygulamayı bir emülatörde veya fiziksel cihazda başlatmak için:
    ```bash
    flutter run
    ```
    *(Web için çalıştırmak isterseniz: `flutter run -d chrome`)*

## 💡 İpuçları

*   Oyun masasında **Oyuncuya bir kez dokunarak** skor ekleme penceresini açabilirsiniz.
*   Skor penceresinde elinde kalan taşları hesaplamak için **Hesap Makinesi** ikonunu seçebilirsiniz.
*   Yanlış girdiğiniz puanı geri almak için masa üstündeki **oyuncu kartına basılı tutun** (Uzun basış).

---
*Kerem Kuyucu tarafından Flutter ile geliştirilmiştir.*
