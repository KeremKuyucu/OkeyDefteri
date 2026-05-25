# 🎴 Okey Defteri

A premium Flutter score-keeping app for physical Okey 101 card games. Track scores in real time, analyze player & team performance with detailed statistics, and enjoy dynamic nicknames that react to how the game unfolds.

Built entirely with AI assistance for personal use during real-life Okey matches.

## ✨ Features

### 🎮 Live Match Tracking
- 4-player table layout (Team 1 vs Team 2) with an interactive game board UI.
- Tap a player card to add a score, long-press to undo the last entry.
- Automatic round management with a dedicated "Next Round" button.

### ➕ Comprehensive Score Types
| Penalty / Bonus | Points |
|---|---|
| İşlek Attı (Threw Islek) | +101 |
| Okey Attı (Threw Okey) | +101 |
| Okeyini Aldılar (Okey Taken) | +101 |
| Yanlış El Açtı (Wrong Hand) | +101 |
| Açamadı (Couldn't Open) | +202 |
| Attığı Taşı Aldılar (Tile Taken) | Manual |
| Elde Kalan Taşlar (Tiles Left) | Manual (with built-in calculator) |
| Normal / Elden / Okey Finish | −101 |
| Okey + Elden Finish | 2× bonus |

### 🧮 Built-in Tile Calculator
Enter remaining tiles one by one at the end of a hand; the app sums them automatically. Supports the **Çiftli (Double)** modifier for `×2` scoring.

### 📊 In-Depth Statistics
- Per-player penalty breakdown, win counts, and error analysis.
- Team-level score comparison with visual bars.
- Score-type leaderboards (e.g., "Most Penalties Received").

### 😈 Dynamic Nicknames
Each player earns a context-aware nickname that changes every round based on their performance (early / mid / late game logic). Nicknames can be toggled on/off — and come in a *toxic* variant for those who appreciate colorful language.

### 🌐 Multi-Language Support
- English (`eng`) and Turkish (`tur`) via JSON-based localization files.
- Language can be switched at runtime from Settings; the app restarts seamlessly.

### 💾 Auto-Save & Game History
- Active games are persisted to local storage (`SharedPreferences`) automatically on every action.
- Browse, resume, or delete past games from the Past Games screen.
- Full data import/export as JSON for backup or migration.

### 🔔 Update Checker
- On launch the app checks the latest GitHub Release (`KeremKuyucu/okey-defteri-flutter`) and prompts the user to update if a newer version is available.

### 📡 Anonymous Telemetry
- Optional daily ping (UUID + timestamp) to track app usage count. Contains no personal data and can be disabled in Settings.

### 🎨 Premium Dark Theme
- Casino-green and gold color palette with glassmorphism effects.
- Smooth animations, gradient buttons, and haptic/sound feedback.

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev/) (Dart) |
| Local Storage | `shared_preferences` |
| Networking | `http` |
| Audio | `audioplayers` |
| Haptics | `vibration` |
| Versioning | `package_info_plus` |
| Links | `url_launcher` |
| Identity | `uuid` |
| Icons | `flutter_launcher_icons` |

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point, initializes services
├── models/
│   └── game_models.dart               # Player, Team, Game, ScoreEntry models + nickname engine
├── services/
│   ├── settings_service.dart          # User preferences (vibration, sound, language, toxic nicknames)
│   ├── storage_service.dart           # Local game persistence (SharedPreferences)
│   ├── localization_service.dart      # JSON-based i18n engine (eng / tur)
│   ├── logging_service.dart           # Anonymous daily telemetry ping
│   └── update_checker_service.dart    # GitHub Release version checker
├── theme/
│   └── app_theme.dart                 # Colors, gradients, text styles
├── screens/
│   ├── home_screen.dart               # Home dashboard with active game card & settings
│   ├── new_game_screen.dart           # Team & player setup
│   ├── game_screen.dart               # Live game board
│   ├── score_history_screen.dart      # Round-by-round score log
│   ├── past_games_screen.dart         # Saved games list
│   └── stats_screen.dart             # Detailed player & team statistics
└── widgets/
    ├── player_card.dart               # Player tile on the game board
    ├── team_score_bar.dart            # Top-bar team score summary
    ├── score_input_dialog.dart        # Score entry dialog with calculator
    └── developer_info.dart            # About / credits dialog

assets/
├── lang/                              # Localization JSON files (eng.json, tur.json)
├── sounds/                            # UI sound effects
└── images/                            # App icon and images
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`^3.12.0`)
- Android / iOS emulator or a physical device

### Installation

```bash
# Clone the repository
git clone https://github.com/KeremKuyucu/okey-defteri-flutter.git
cd okey-defteri-flutter

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run

```

## 💡 Quick Tips

| Action | How |
|---|---|
| Add a score | Tap a player card |
| Undo last score | Long-press the player card |
| Calculate remaining tiles | Use the calculator icon inside the score dialog |
| Double scoring (Çiftli) | Toggle the ×2 chip on a player card |
| Switch language | Settings → Language dropdown |
| Import / Export data | Settings → Import/Export |

## 📦 Releases

Release notes for each version are available as `RELEASE_X.X.X.md` files in the project root.

## 📄 License

This project is for personal use. See the repository for details.

---

*Developed by [Kerem Kuyucu](https://github.com/keremkuyucu)*
