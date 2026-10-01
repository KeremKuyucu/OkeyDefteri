import 'dart:math';
import '../models/game_models.dart';
import 'settings_service.dart';
import 'localization_service.dart';

class ToxicNicknameService {
  static String getNickname(Player player, List<Player> allPlayers, int roundNumber) {
    if (!SettingsService.getToxicNicknamesEnabled()) return '';
    if (allPlayers.isEmpty) return '';

    final scores = player.scores;
    final totalScore = player.totalScore;

    // ============================================================
    // 1. SIRALAMA
    // ============================================================

    final isNormal = allPlayers
        .any((p) => p.scores.any((s) => s.type.isNormalOkey));
    final sorted = List<Player>.from(allPlayers)
      ..sort((a, b) => isNormal
          ? b.totalScore.compareTo(a.totalScore)
          : a.totalScore.compareTo(b.totalScore));

    final myRank = sorted.indexWhere((p) => p.id == player.id);

    if (myRank < 0) return '';

    final isLeader = myRank == 0;
    final isSecond = myRank == 1;
    final isThird = myRank == 2;
    final isLast = myRank == sorted.length - 1;

    final leaderScore = sorted.first.totalScore;

    final leaderDiff = totalScore - leaderScore;

    final runnerUpDiff = sorted.length > 1
        ? sorted[1].totalScore - leaderScore
        : 0;

    // ============================================================
    // 2. BİTİRME İSTATİSTİKLERİ
    // ============================================================

    final okeyBitti = scores
        .where((s) => s.type == ScoreType.okeyAtarakBitti)
        .length;

    final okeyEldenBitti = scores
        .where((s) => s.type == ScoreType.okeyAtarakEldenBitti)
        .length;

    final eldenBitti = scores
        .where((s) => s.type == ScoreType.eldenBitti)
        .length;

    final normalBitti = scores
        .where((s) => s.type == ScoreType.normalBitti)
        .length;

    final americanoKazandi = scores
        .where(
          (s) =>
              s.type == ScoreType.americanoKazandi ||
              s.type == ScoreType.americanoOkeyAtarakBitti,
        )
        .length;

    final normalOkeyWins = scores.where((s) => s.type.isNormalOkey).length;

    final totalWins =
        okeyBitti +
        okeyEldenBitti +
        eldenBitti +
        normalBitti +
        americanoKazandi +
        normalOkeyWins;

    // ============================================================
    // 3. HATA / CEZA İSTATİSTİKLERİ
    // ============================================================

    final islekAtti = scores.where((s) => s.type == ScoreType.islekAtti).length;

    final okeyAtti = scores.where((s) => s.type == ScoreType.okeyAtti).length;

    final yanlisEl = scores
        .where((s) => s.type == ScoreType.yanlisElActi)
        .length;

    final acamadi = scores.where((s) => s.type == ScoreType.acamadi).length;

    final okeyiniAldilar = scores
        .where((s) => s.type == ScoreType.okeyiniAldilar)
        .length;

    final totalMistakes =
        islekAtti + okeyAtti + yanlisEl + acamadi + okeyiniAldilar;

    // ============================================================
    // 4. RAKİBE VERDİĞİ CEZALAR
    // ============================================================

    int penaltiesCaused = 0;

    for (final other in allPlayers) {
      if (other.id == player.id) continue;

      penaltiesCaused += other.scores
          .where((s) => s.causedByPlayerId == player.id)
          .length;
    }

    // ============================================================
    // 5. SON TURLAR
    // ============================================================

    final lastEntry = scores.isNotEmpty ? scores.last : null;

    final justFinished = lastEntry != null && lastEntry.type.isFinishType;

    final justAcamadi =
        lastEntry != null && lastEntry.type == ScoreType.acamadi;

    final justBigPenalty = lastEntry != null && lastEntry.effectivePoints > 100;

    final recentScores = scores.length >= 3
        ? scores.sublist(scores.length - 3)
        : scores;

    final recentFinishes = recentScores
        .where((s) => s.type.isFinishType)
        .length;

    final isOnFire = recentFinishes >= 2;

    final isComeback =
        (isLeader || isSecond) && recentFinishes >= 2 && roundNumber >= 4;

    // ============================================================
    // 6. ADAYLAR
    // ============================================================

    final Map<String, double> candidates = {};

    void addCandidate(String category, double weight) {
      if (weight <= 0) return;
      candidates[category] = (candidates[category] ?? 0) + weight;
    }

    // ============================================================
    // 7. ERKEN OYUN
    // ============================================================

    if (roundNumber <= 1 && scores.isEmpty) {
      addCandidate('early_start', 100);
    }

    // ============================================================
    // 8. SON EL / MOMENTUM
    // ============================================================

    if (justFinished) {
      addCandidate('recent_winner', 45);
    }

    if (isOnFire) {
      addCandidate('on_fire', 60 + ((recentFinishes - 2) * 15));
    }

    if (isComeback) {
      addCandidate('comeback_king', 75);
    }

    // ============================================================
    // 9. ÇİFTLİ
    // ============================================================

    if (player.isCiftliGidiyor) {
      addCandidate('ciftli_gambler', 70);
    }

    // ============================================================
    // 10. OKEY İLE İLGİLİ DURUMLAR
    // ============================================================

    if (okeyEldenBitti > 0) {
      addCandidate('okey_master', 100 + (okeyEldenBitti * 25));
    }

    if (okeyBitti > 0) {
      addCandidate('okey_master', 90 + (okeyBitti * 20));
    }

    if (penaltiesCaused > 0) {
      addCandidate('okey_master', 75 + (penaltiesCaused * 10));
    }

    if (okeyAtti > 0) {
      addCandidate('okey_victim', 80 + (okeyAtti * 20));
    }

    if (okeyiniAldilar > 0) {
      addCandidate('okey_victim', 90 + (okeyiniAldilar * 20));
    }

    // ============================================================
    // 11. EL AÇAMAMA
    // ============================================================

    if (justAcamadi) {
      addCandidate('cant_open', 95);
    }

    if (acamadi >= 2) {
      addCandidate('cant_open', 80 + ((acamadi - 2) * 20));
    }

    // ============================================================
    // 12. HATA / CEZA MAKİNESİ
    // ============================================================

    if (totalMistakes >= 2) {
      addCandidate('penalty_prone', 55 + (totalMistakes * 8));
    }

    if (yanlisEl >= 2) {
      addCandidate('penalty_prone', 70 + ((yanlisEl - 2) * 15));
    }

    // ============================================================
    // 13. TEMİZ OYUNCU
    // ============================================================

    if (totalMistakes == 0 && totalScore <= 60 && roundNumber >= 3) {
      addCandidate('clean_player', 65);
    }

    // ============================================================
    // 14. PUAN KRİZİ
    // ============================================================

    if (totalScore >= 350) {
      addCandidate('score_crisis', 75 + ((totalScore - 350) / 20));
    }

    if (justBigPenalty) {
      addCandidate('score_crisis', 85);
    }

    // ============================================================
    // 15. EŞ DİNAMİKLERİ
    // ============================================================

    if (allPlayers.length == 4) {
      final partnerSeat = (player.seatIndex + 2) % 4;

      final partner = allPlayers.firstWhere(
        (p) => p.seatIndex == partnerSeat,
        orElse: () => allPlayers.first,
      );

      if (partner.id != player.id) {
        if (totalScore < partner.totalScore - 120 &&
            totalWins >= partner.winCount) {
          addCandidate('team_carry', 85);
        }

        if (totalScore > partner.totalScore + 120 &&
            totalMistakes > partner.penaltyCount) {
          addCandidate('team_burden', 90);
        }
      }
    }

    // ============================================================
    // 16. SIRALAMA
    // ============================================================

    if (isLeader) {
      if (runnerUpDiff >= 100) {
        addCandidate('leader_dominant', 65);
      } else {
        addCandidate('leader_close', 45);
      }
    }

    if (isSecond) {
      if (leaderDiff <= 60) {
        addCandidate('stalker_second', 55);
      } else {
        addCandidate('middle_silent', 20);
      }
    }

    if (isThird) {
      addCandidate('middle_struggle', 35);
      addCandidate('middle_silent', 20);
    }

    if (isLast) {
      if (leaderDiff >= 300 || totalScore >= 500) {
        addCandidate('last_hopeless', 60);
      } else {
        addCandidate('last_fighting', 30);
      }
    }

    // ============================================================
    // 17. TAMAMEN BOŞ DURUM
    // ============================================================

    if (candidates.isEmpty) {
      if (isLeader) {
        addCandidate('leader_close', 30);
      } else if (isSecond) {
        addCandidate('stalker_second', 30);
      } else if (isLast) {
        addCandidate('last_fighting', 25);
      } else {
        addCandidate('middle_silent', 25);
        addCandidate('middle_struggle', 20);
      }
    }

    // ============================================================
    // 18. ÇOK ZAYIF ADAYLARI TEMİZLE
    // ============================================================

    final maxWeight = candidates.values.reduce((a, b) => a > b ? a : b);
    final minimumUsefulWeight = maxWeight * 0.35;
    candidates.removeWhere((_, weight) => weight < minimumUsefulWeight);

    // ============================================================
    // 19. DETERMİNİSTİK AĞIRLIKLI SEÇİM
    // ============================================================

    var seed =
        player.id.hashCode ^
        (roundNumber * 7919) ^
        (scores.length * 104729) ^
        (totalScore * 31);

    seed &= 0x7fffffff;

    final random = Random(seed);

    final totalWeight = candidates.values.fold<double>(
      0,
      (sum, weight) => sum + weight,
    );

    var roll = random.nextDouble() * totalWeight;

    String chosenCategory = candidates.keys.first;

    for (final entry in candidates.entries) {
      roll -= entry.value;

      if (roll <= 0) {
        chosenCategory = entry.key;
        break;
      }
    }

    // ============================================================
    // 20. VARYANT SEÇİMİ
    // ============================================================

    const variantCounts = <String, int>{
      'early_start': 4,
      'leader_dominant': 4,
      'leader_close': 4,
      'stalker_second': 4,
      'middle_silent': 4,
      'middle_struggle': 3,
      'last_hopeless': 4,
      'last_fighting': 3,
      'on_fire': 3,
      'recent_winner': 3,
      'comeback_king': 3,
      'cant_open': 3,
      'penalty_prone': 3,
      'okey_master': 3,
      'okey_victim': 3,
      'ciftli_gambler': 3,
      'score_crisis': 3,
      'clean_player': 3,
      'team_carry': 2,
      'team_burden': 2,
    };

    final variantCount = variantCounts[chosenCategory] ?? 1;
    final variantSeed = seed ^ (chosenCategory.hashCode * 37);
    final variantIndex = (variantSeed.abs() % variantCount) + 1;

    return Localization.t('nicknames.${chosenCategory}_$variantIndex');
  }
}
