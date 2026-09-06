import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_models.dart';
import 'auth_service.dart';

/// Supabase ile okey oyunu verilerini senkronize eder.
/// Tablo: okey_games
class CloudService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'okey_games';

  /// Tek oyunu buluta kaydet / guncelle
  static Future<void> syncGame(Game game) async {
    if (!AuthService.isSignedIn) return;
    try {
      await _supabase.from(_table).upsert({
        'id': game.id,
        'user_id': AuthService.currentUser!.id,
        'data': game.toJson(),
        'game_mode': game.gameMode.name,
        'is_finished': game.isFinished,
        'created_at': game.createdAt.toIso8601String(),
        'ended_at': game.endedAt?.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('CloudService.syncGame hatasi: $e');
    }
  }

  /// Tüm oyunlari buluttan indir
  static Future<List<Game>> fetchAllGames() async {
    if (!AuthService.isSignedIn) return [];
    try {
      final response = await _supabase
          .from(_table)
          .select('data')
          .eq('user_id', AuthService.currentUser!.id)
          .order('created_at', ascending: false);

      return response
          .map<Game>((row) => Game.fromJson(row['data'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CloudService.fetchAllGames hatasi: $e');
      return [];
    }
  }

  /// Oyunu buluttan sil
  static Future<void> deleteGame(String gameId) async {
    if (!AuthService.isSignedIn) return;
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('id', gameId)
          .eq('user_id', AuthService.currentUser!.id);
    } catch (e) {
      debugPrint('CloudService.deleteGame hatasi: $e');
    }
  }

  /// Yerel oyunlari toplu olarak buluta yukle
  static Future<int> pushLocalGames(List<Game> games) async {
    if (!AuthService.isSignedIn || games.isEmpty) return 0;
    int count = 0;
    for (final game in games) {
      try {
        await syncGame(game);
        count++;
      } catch (_) {}
    }
    return count;
  }

  /// Buluttaki oyunlari indir, yereldekileri koru (merge)
  /// Donus: buluttan gelen yeni oyun sayisi
  static Future<List<Game>> fetchAndMerge(List<Game> localGames) async {
    final cloudGames = await fetchAllGames();
    if (cloudGames.isEmpty) return [];

    final localIds = localGames.map((g) => g.id).toSet();
    // Yerelde olmayan oyunlari dondur
    return cloudGames.where((g) => !localIds.contains(g.id)).toList();
  }
}
