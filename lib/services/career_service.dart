import '../models/game_models.dart';
import '../models/player_profile_models.dart';
import 'storage_service.dart';

class CareerService {
  /// Kayıtlı tüm oyunları analiz edip oyuncu profillerini oluşturur
  static Future<List<PlayerProfile>> getAllProfiles() async {
    final games = await StorageService.getSavedGames();
    return buildProfilesFromGames(games);
  }

  /// Daha önce oynamış benzersiz oyuncu isimlerini getirir (Autocomplete / hızlı seçim için)
  static Future<List<String>> getKnownPlayerNames() async {
    final games = await StorageService.getSavedGames();
    final names = <String>{};
    for (final game in games) {
      for (final player in game.allPlayers) {
        final trimmed = player.name.trim();
        if (trimmed.isNotEmpty) names.add(trimmed);
      }
    }
    final sortedList = names.toList()..sort();
    return sortedList;
  }

  /// Oyun listesinden oyuncu profillerini ve ikili uyumlarını hesaplar
  static List<PlayerProfile> buildProfilesFromGames(List<Game> games) {
    if (games.isEmpty) return [];

    // canonicalName -> stats accumulator
    final profileData = <String, _PlayerAccumulator>{};

    for (final game in games) {
      final isFinished = game.isFinished;
      final winningTeam = isFinished ? game.leadingTeam : null;

      for (final player in game.allPlayers) {
        final canonicalName = player.name.trim();
        if (canonicalName.isEmpty) continue;

        final acc = profileData.putIfAbsent(
          canonicalName,
          () => _PlayerAccumulator(name: canonicalName),
        );

        acc.gamesPlayed++;
        acc.totalPoints += player.totalScore;
        acc.recentScores.add(player.totalScore);
        acc.totalPenalties += player.penaltyCount;

        // Okey atarak bitirme sayısı
        final okeyFinishes = player.scores.where((s) =>
            s.type == ScoreType.okeyAtarakBitti ||
            s.type == ScoreType.okeyAtarakEldenBitti ||
            s.type == ScoreType.americanoOkeyAtarakBitti ||
            s.type == ScoreType.normalOkeyAtarakBitti ||
            s.type == ScoreType.normalOkeyCiftVeOkeyBitti).length;
        acc.totalOkeyFinishes += okeyFinishes;

        // İşlek atma sayısı
        final islekCount = player.scores.where((s) =>
            s.type == ScoreType.islekAtti ||
            s.type == ScoreType.americanoIslek).length;
        acc.totalIslekAtti += islekCount;

        // Kazandı mı?
        bool wonGame = false;
        if (isFinished) {
          if (game.isAmericanoSolo) {
            final leader = game.leadingPlayer;
            if (leader != null && leader.id == player.id) {
              wonGame = true;
            }
          } else if (winningTeam != null) {
            final team = game.getTeamForPlayer(player);
            if (team.id == winningTeam.id) {
              wonGame = true;
            }
          }
        }
        if (wonGame) {
          acc.gamesWon++;
        }

        // Partner sinerjisi (Takımlı oyunlar için)
        if (!game.isAmericanoSolo) {
          final team = game.getTeamForPlayer(player);
          final partner =
              team.player1.id == player.id ? team.player2 : team.player1;
          final partnerName = partner.name.trim();

          if (partnerName.isNotEmpty && partnerName != canonicalName) {
            final partnerAcc = acc.partners.putIfAbsent(
              partnerName,
              () => _PartnerAccumulator(partnerName: partnerName),
            );
            partnerAcc.gamesTogether++;
            if (wonGame) {
              partnerAcc.winsTogether++;
            }
          }
        }
      }
    }

    final profiles = profileData.values.map((acc) {
      final partners = acc.partners.values.map((p) {
        return PartnerSynergy(
          partnerName: p.partnerName,
          gamesTogether: p.gamesTogether,
          winsTogether: p.winsTogether,
        );
      }).toList();

      // En iyi partnerleri sırala: Önce kazanma oranı, sonra maç sayısı
      partners.sort((a, b) {
        final rateCmp = b.winRate.compareTo(a.winRate);
        if (rateCmp != 0) return rateCmp;
        return b.gamesTogether.compareTo(a.gamesTogether);
      });

      return PlayerProfile(
        name: acc.name,
        gamesPlayed: acc.gamesPlayed,
        gamesWon: acc.gamesWon,
        totalPenalties: acc.totalPenalties,
        totalOkeyFinishes: acc.totalOkeyFinishes,
        totalIslekAtti: acc.totalIslekAtti,
        totalPoints: acc.totalPoints,
        bestPartners: partners,
        recentScores: acc.recentScores.reversed.take(5).toList(),
      );
    }).toList();

    // Profilleri en çok galibiyete ve kazanma oranına göre sırala
    profiles.sort((a, b) {
      final winCmp = b.gamesWon.compareTo(a.gamesWon);
      if (winCmp != 0) return winCmp;
      return b.winRate.compareTo(a.winRate);
    });

    return profiles;
  }
}

class _PlayerAccumulator {
  final String name;
  int gamesPlayed = 0;
  int gamesWon = 0;
  int totalPenalties = 0;
  int totalOkeyFinishes = 0;
  int totalIslekAtti = 0;
  int totalPoints = 0;
  final List<int> recentScores = [];
  final Map<String, _PartnerAccumulator> partners = {};

  _PlayerAccumulator({required this.name});
}

class _PartnerAccumulator {
  final String partnerName;
  int gamesTogether = 0;
  int winsTogether = 0;

  _PartnerAccumulator({required this.partnerName});
}
