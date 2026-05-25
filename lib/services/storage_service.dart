import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';

class StorageService {
  static const String _gamesKey = 'saved_games';
  static const String _activeGameKey = 'active_game';

  /// Tüm kayıtlı oyunları getir
  static Future<List<Game>> getSavedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesJson = prefs.getString(_gamesKey);
    if (gamesJson == null) return [];

    final List<dynamic> gamesList = jsonDecode(gamesJson);
    return gamesList.map((g) => Game.fromJson(g)).toList();
  }

  /// Oyun kaydet
  static Future<void> saveGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getSavedGames();

    // Mevcut oyunu güncelle veya ekle
    final existingIndex = games.indexWhere((g) => g.id == game.id);
    if (existingIndex != -1) {
      games[existingIndex] = game;
    } else {
      games.add(game);
    }

    await prefs.setString(
      _gamesKey,
      jsonEncode(games.map((g) => g.toJson()).toList()),
    );
  }

  /// Aktif oyunu kaydet (auto-save)
  static Future<void> saveActiveGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeGameKey, jsonEncode(game.toJson()));
    await saveGame(game);
  }

  /// Aktif oyunu getir
  static Future<Game?> getActiveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final gameJson = prefs.getString(_activeGameKey);
    if (gameJson == null) return null;
    return Game.fromJson(jsonDecode(gameJson));
  }

  /// Aktif oyunu temizle
  static Future<void> clearActiveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeGameKey);
  }

  /// Oyun sil
  static Future<void> deleteGame(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getSavedGames();
    games.removeWhere((g) => g.id == gameId);
    await prefs.setString(
      _gamesKey,
      jsonEncode(games.map((g) => g.toJson()).toList()),
    );

    // Silinen oyun aktif oyun ise, aktif oyunu da temizle
    final activeGame = await getActiveGame();
    if (activeGame != null && activeGame.id == gameId) {
      await clearActiveGame();
    }
  }

  /// Bir oyuncunun tüm maçlardaki istatistiklerini getir
  static Future<Map<String, dynamic>> getPlayerStats(String playerName) async {
    final games = await getSavedGames();
    int totalGames = 0;
    int totalScore = 0;
    int totalWins = 0;
    int totalPenalties = 0;

    for (final game in games) {
      for (final player in game.allPlayers) {
        if (player.name.toLowerCase() == playerName.toLowerCase()) {
          totalGames++;
          totalScore += player.totalScore;
          totalWins += player.winCount;
          totalPenalties += player.penaltyCount;
        }
      }
    }

    return {
      'totalGames': totalGames,
      'totalScore': totalScore,
      'totalWins': totalWins,
      'totalPenalties': totalPenalties,
      'averageScore': totalGames > 0 ? totalScore / totalGames : 0,
    };
  }

  /// Verileri JSON formatında dışa aktar
  static Future<String> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_gamesKey) ?? '[]';
  }

  /// JSON formatındaki verileri içe aktar
  static Future<void> importData(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final List<dynamic> gamesList = jsonDecode(jsonData);
      // Doğrulama: Hata fırlatmazsa veriler düzgündür
      for (var g in gamesList) {
        Game.fromJson(g);
      }
      await prefs.setString(_gamesKey, jsonData);
    } catch (e) {
      throw FormatException('Geçersiz veri formatı');
    }
  }
}
