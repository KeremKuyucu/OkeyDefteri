import 'package:okey_defteri/services/settings_service.dart';
import 'dart:math';
import '../services/localization_service.dart';

/// Oyun modu
enum GameMode { okey101, americano, americanoSolo }

/// Skor giriş türleri
enum ScoreType {
  islekAtti, // +101 İşlek attı
  okeyAtti, // +101 Okey attı
  okeyiniAldilar, // +101 Okeyini aldılar
  yanlisElActi, // +101 Yanlış el açtı
  normalBitti, // -101 Normal bitti (elle kapattı)
  eldenBitti, // -202 Elden bitti
  okeyAtarakBitti, // -202 Okey atarak bitti
  okeyAtarakEldenBitti, // 2x + -404 Okey atarak elden bitti
  acamadi, // +202 Açamadı
  attigiTasiAldilar, // Manuel puan - Attığı taşı aldılar
  eldeKalanTaslar, // Manuel puan - Elde kalan taşlar
  // Americano'ya özel
  americanoEldeKalan, // Elde kalan kart değeri (Americano)
  americanoIslek, // İşlek atma cezası +50 (Americano)
  americanoHile, // Hile yakalanma cezası +50 (Americano)
  americanoKazandi, // Turu kazandı (0 puan, işaret) (Americano)
  americanoTakimYokOkeyAldi, // Takım yok okeyini alma cezası +50 (Americano)
  americanoOkeyAtti, // Okey atma cezası +50 (Americano)
  americanoYanlisElActi, // Yanlış el açma cezası +50 (Americano)
  americanoIslekAtarakBitti, // İşlek atarak bitti +100 puan ceza (Americano)
  americanoOkeyAtarakBitti, // Okey atarak bitti -100 puan (Americano)
}

extension ScoreTypeExtension on ScoreType {
  String get label {
    switch (this) {
      case ScoreType.islekAtti:
        return Localization.t('score_types.islek_atti');
      case ScoreType.okeyAtti:
        return Localization.t('score_types.okey_atti');
      case ScoreType.okeyiniAldilar:
        return Localization.t('score_types.okeyini_aldilar');
      case ScoreType.yanlisElActi:
        return Localization.t('score_types.yanlis_el_acti');
      case ScoreType.normalBitti:
        return Localization.t('score_types.normal_bitti');
      case ScoreType.eldenBitti:
        return Localization.t('score_types.elden_bitti');
      case ScoreType.okeyAtarakBitti:
        return Localization.t('score_types.okey_atarak_bitti');
      case ScoreType.okeyAtarakEldenBitti:
        return Localization.t('score_types.okey_atarak_elden_bitti');
      case ScoreType.acamadi:
        return Localization.t('score_types.acamadi');
      case ScoreType.attigiTasiAldilar:
        return Localization.t('score_types.attigi_tasi_aldilar');
      case ScoreType.eldeKalanTaslar:
        return Localization.t('score_types.elde_kalan_taslar');
      case ScoreType.americanoEldeKalan:
        return Localization.t('score_types.americano_elde_kalan');
      case ScoreType.americanoIslek:
        return Localization.t('score_types.americano_islek');
      case ScoreType.americanoHile:
        return Localization.t('score_types.americano_hile');
      case ScoreType.americanoKazandi:
        return Localization.t('score_types.americano_kazandi');
      case ScoreType.americanoTakimYokOkeyAldi:
        return Localization.t('score_types.americano_takim_yok_okey_aldi');
      case ScoreType.americanoOkeyAtti:
        return Localization.t('score_types.americano_okey_atti');
      case ScoreType.americanoYanlisElActi:
        return Localization.t('score_types.americano_yanlis_el_acti');
      case ScoreType.americanoIslekAtarakBitti:
        return Localization.t('score_types.americano_islek_atarak_bitti');
      case ScoreType.americanoOkeyAtarakBitti:
        return Localization.t('score_types.americano_okey_atarak_bitti');
    }
  }

  String get emoji {
    switch (this) {
      case ScoreType.islekAtti:
        return '🎯';
      case ScoreType.okeyAtti:
        return '🃏❌';
      case ScoreType.okeyiniAldilar:
        return '🃏';
      case ScoreType.yanlisElActi:
        return '❌';
      case ScoreType.normalBitti:
        return '✅';
      case ScoreType.eldenBitti:
        return '🏆';
      case ScoreType.okeyAtarakBitti:
        return '🃏🏆';
      case ScoreType.okeyAtarakEldenBitti:
        return '👑🃏';
      case ScoreType.acamadi:
        return '🚫';
      case ScoreType.attigiTasiAldilar:
        return '🪨';
      case ScoreType.eldeKalanTaslar:
        return '✋';
      case ScoreType.americanoEldeKalan:
        return '🃏';
      case ScoreType.americanoIslek:
        return '🎯';
      case ScoreType.americanoHile:
        return '🚫';
      case ScoreType.americanoKazandi:
        return '🏆';
      case ScoreType.americanoTakimYokOkeyAldi:
        return '🃏⚠️';
      case ScoreType.americanoOkeyAtti:
        return '🃏❌';
      case ScoreType.americanoYanlisElActi:
        return '❌';
      case ScoreType.americanoIslekAtarakBitti:
        return '🎯🏁';
      case ScoreType.americanoOkeyAtarakBitti:
        return '🃏🏆';
    }
  }

  int get defaultPoints {
    switch (this) {
      case ScoreType.islekAtti:
        return 101;
      case ScoreType.okeyAtti:
        return 101;
      case ScoreType.okeyiniAldilar:
        return 101;
      case ScoreType.yanlisElActi:
        return 101;
      case ScoreType.normalBitti:
        return -101;
      case ScoreType.eldenBitti:
        return -202;
      case ScoreType.okeyAtarakBitti:
        return -202;
      case ScoreType.okeyAtarakEldenBitti:
        return -404;
      case ScoreType.acamadi:
        return 202;
      case ScoreType.attigiTasiAldilar:
        return 0; // Manuel giriş
      case ScoreType.eldeKalanTaslar:
        return 0; // Manuel giriş
      case ScoreType.americanoEldeKalan:
        return 0; // Manuel giriş
      case ScoreType.americanoIslek:
        return 50;
      case ScoreType.americanoHile:
        return 50;
      case ScoreType.americanoKazandi:
        return -50;
      case ScoreType.americanoTakimYokOkeyAldi:
        return 50;
      case ScoreType.americanoOkeyAtti:
        return 50;
      case ScoreType.americanoYanlisElActi:
        return 50;
      case ScoreType.americanoIslekAtarakBitti:
        return 100;
      case ScoreType.americanoOkeyAtarakBitti:
        return -100;
    }
  }

  bool get isManual {
    return this == ScoreType.attigiTasiAldilar ||
        this == ScoreType.eldeKalanTaslar ||
        this == ScoreType.americanoEldeKalan;
  }

  /// Bu tür Americano'ya özel ek ceza tipi mi?
  bool get isAmericanoPenalty {
    return this == ScoreType.americanoIslek ||
        this == ScoreType.americanoHile ||
        this == ScoreType.americanoTakimYokOkeyAldi ||
        this == ScoreType.americanoOkeyAtti ||
        this == ScoreType.americanoYanlisElActi ||
        this == ScoreType.americanoIslekAtarakBitti;
  }

  /// Americano'ya mı özel?
  bool get isAmericano {
    return this == ScoreType.americanoEldeKalan ||
        this == ScoreType.americanoIslek ||
        this == ScoreType.americanoHile ||
        this == ScoreType.americanoKazandi ||
        this == ScoreType.americanoTakimYokOkeyAldi ||
        this == ScoreType.americanoOkeyAtti ||
        this == ScoreType.americanoYanlisElActi ||
        this == ScoreType.americanoIslekAtarakBitti ||
        this == ScoreType.americanoOkeyAtarakBitti;
  }

  /// Bu tür bir bitirme türü mü?
  bool get isFinishType {
    return this == ScoreType.normalBitti ||
        this == ScoreType.eldenBitti ||
        this == ScoreType.okeyAtarakBitti ||
        this == ScoreType.okeyAtarakEldenBitti ||
        this == ScoreType.americanoKazandi ||
        this == ScoreType.americanoIslekAtarakBitti ||
        this == ScoreType.americanoOkeyAtarakBitti;
  }

  /// Bu ceza türü için "kim yaptı?" sorusu sorulacak mı?
  bool get hasCausedBy {
    return this == ScoreType.okeyiniAldilar ||
        this == ScoreType.attigiTasiAldilar;
  }

  /// causedBy sorusu label'ı
  String get causedByLabel {
    switch (this) {
      case ScoreType.okeyiniAldilar:
        return Localization.t('score_types.caused_by_okeyini_aldilar');
      case ScoreType.attigiTasiAldilar:
        return Localization.t('score_types.caused_by_attigi_tasi_aldilar');
      default:
        return '';
    }
  }
}

class ScoreEntry {
  final String id;
  final ScoreType type;
  final int points;
  final bool isCiftli; // Oyuncu kendisi çiftli gidiyordu
  final bool isOkeyFinish; // O el okey atılarak bitti (x2)
  final bool isCauserCiftli; // Cezayı verdiren kişi çiftli gidiyordu (x2)
  final DateTime timestamp;
  final int roundNumber;
  final String? causedByPlayerId;

  ScoreEntry({
    required this.id,
    required this.type,
    required this.points,
    this.isCiftli = false,
    this.isOkeyFinish = false,
    this.isCauserCiftli = false,
    required this.timestamp,
    required this.roundNumber,
    this.causedByPlayerId,
  });

  int get effectivePoints {
    int p = points;
    if (isCiftli) p *= 2;
    if (isOkeyFinish) p *= 2;
    if (isCauserCiftli) p *= 2;
    return p;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'points': points,
    'isCiftli': isCiftli,
    'isOkeyFinish': isOkeyFinish,
    'isCauserCiftli': isCauserCiftli,
    'timestamp': timestamp.toIso8601String(),
    'roundNumber': roundNumber,
    'causedByPlayerId': causedByPlayerId,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    id: json['id'],
    type: _parseScoreType(json['type']),
    points: json['points'],
    isCiftli: json['isCiftli'] ?? false,
    isOkeyFinish: json['isOkeyFinish'] ?? false,
    isCauserCiftli: json['isCauserCiftli'] ?? false,
    timestamp: DateTime.parse(json['timestamp']),
    roundNumber: json['roundNumber'],
    causedByPlayerId: json['causedByPlayerId'],
  );

  /// Geriye dönük uyumluluk: eski kayıtlarda int index, yenilerde String name
  static ScoreType _parseScoreType(dynamic raw) {
    if (raw is int) return ScoreType.values[raw];
    try {
      return ScoreType.values.byName(raw as String);
    } catch (_) {
      return ScoreType.eldeKalanTaslar; // bilinmeyen değer için fallback
    }
  }
}

/// Oyuncu modeli
class Player {
  final String id;
  String name;
  final int seatIndex; // 0: üst, 1: sağ, 2: alt, 3: sol
  List<ScoreEntry> scores;
  // Field initializer ile hot reload'da null olmaz
  bool _isCiftliGidiyor = false;
  // ignore: unnecessary_getters_setters
  bool get isCiftliGidiyor => _isCiftliGidiyor;
  // ignore: unnecessary_getters_setters
  set isCiftliGidiyor(bool value) => _isCiftliGidiyor = value;

  Player({
    required this.id,
    required this.name,
    required this.seatIndex,
    List<ScoreEntry>? scores,
    this._isCiftliGidiyor = false,
  }) : scores = scores ?? [];

  int get totalScore =>
      scores.fold(0, (sum, entry) => sum + entry.effectivePoints);

  int get penaltyCount => scores.where((s) => s.effectivePoints > 0).length;

  int get winCount => scores.where((s) => s.type.isFinishType).length;

  Map<ScoreType, int> get scoreBreakdown {
    final breakdown = <ScoreType, int>{};
    for (final entry in scores) {
      breakdown[entry.type] =
          (breakdown[entry.type] ?? 0) + entry.effectivePoints;
    }
    return breakdown;
  }

  String getNickname(List<Player> allPlayers, int roundNumber) {
    if (!SettingsService.getToxicNicknamesEnabled()) return '';
    if (allPlayers.isEmpty) return '';

    final scores = this.scores;
    final totalScore = this.totalScore;

    // ============================================================
    // 1. SIRALAMA
    // ============================================================

    final sorted = List<Player>.from(allPlayers)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));

    final myRank = sorted.indexWhere((p) => p.id == id);

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

    final totalWins =
        okeyBitti +
        okeyEldenBitti +
        eldenBitti +
        normalBitti +
        americanoKazandi;

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

    for (final player in allPlayers) {
      if (player.id == id) continue;

      penaltiesCaused += player.scores
          .where((s) => s.causedByPlayerId == id)
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
    //
    // category -> ağırlık
    //
    // Büyük ağırlık = bu durum nickname'i daha çok hak ediyor.
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
    //
    // Bunlar önemli ama kalıcı karakteristiklerden biraz daha düşük.
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

    if (isCiftliGidiyor) {
      addCandidate('ciftli_gambler', 70);
    }

    // ============================================================
    // 10. OKEY İLE İLGİLİ DURUMLAR
    //
    // Bunlar özellikle güçlü.
    // Çünkü "okey master" veya "okey victim" oyuncunun
    // gerçekten yaptığı bir olaya dayanıyor.
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
      final partnerSeat = (seatIndex + 2) % 4;

      final partner = allPlayers.firstWhere(
        (p) => p.seatIndex == partnerSeat,
        orElse: () => allPlayers.first,
      );

      if (partner.id != id) {
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
    //
    // EN ÖNEMLİ DEĞİŞİKLİK:
    //
    // Sonunculuk artık "her durumda" güçlü bir aday değil.
    // Özel olay varsa onların gerisinde kalıyor.
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
      // Gerçekten ezici şekilde sonuncuysa güçlü.
      if (leaderDiff >= 300 || totalScore >= 500) {
        addCandidate('last_hopeless', 60);
      }
      // Yakın ara sonuncuysa çok daha zayıf.
      else {
        addCandidate('last_fighting', 30);
      }
    }

    // ============================================================
    // 17. TAMAMEN BOŞ DURUM
    //
    // Burada bile sürekli "götü boklu" dönmemesi için
    // sıralamaya göre makul ama düşük ağırlıklı aday veriyoruz.
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
    //
    // Örneğin:
    //
    // okey_master  = 120
    // last_hopeless = 60
    // middle_silent = 20
    //
    // Burada middle_silent tamamen gereksiz.
    //
    // En güçlü adayın %35'inden düşük olanları atıyoruz.
    // ============================================================

    final maxWeight = candidates.values.reduce((a, b) => a > b ? a : b);

    final minimumUsefulWeight = maxWeight * 0.35;

    candidates.removeWhere((_, weight) => weight < minimumUsefulWeight);

    // ============================================================
    // 19. DETERMİNİSTİK AĞIRLIKLI SEÇİM
    //
    // Random kullanıyoruz ama seed sabit.
    //
    // Dolayısıyla:
    // - build() -> nickname değişmez
    // - aynı tur -> nickname değişmez
    // - sonraki tur -> farklı seçim yapılabilir
    // ============================================================

    var seed =
        id.hashCode ^
        (roundNumber * 7919) ^
        (scores.length * 104729) ^
        (totalScore * 31);

    // Negatif / taşma ihtimaline karşı normalize ediyoruz.
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'seatIndex': seatIndex,
    'scores': scores.map((s) => s.toJson()).toList(),
    'isCiftliGidiyor': isCiftliGidiyor,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    seatIndex: json['seatIndex'],
    scores: (json['scores'] as List)
        .map((s) => ScoreEntry.fromJson(s))
        .toList(),
    isCiftliGidiyor: json['isCiftliGidiyor'] ?? false,
  );
}

/// Takım modeli (karşılıklı oturan 2 oyuncu)
class Team {
  final String id;
  String name;
  final Player player1;
  final Player player2;

  Team({
    required this.id,
    required this.name,
    required this.player1,
    required this.player2,
  });

  int get totalScore => player1.totalScore + player2.totalScore;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'player1': player1.toJson(),
    'player2': player2.toJson(),
  };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'],
    player1: Player.fromJson(json['player1']),
    player2: Player.fromJson(json['player2']),
  );
}

/// Americano tur kuralı modeli
class AmericanoRound {
  final int roundNumber;
  final String titleKey; // Localization anahtarı
  final String emoji;

  const AmericanoRound({
    required this.roundNumber,
    required this.titleKey,
    required this.emoji,
  });

  static const List<AmericanoRound> rounds = [
    AmericanoRound(roundNumber: 1, titleKey: 'americano.round_1', emoji: '🃏'),
    AmericanoRound(roundNumber: 2, titleKey: 'americano.round_2', emoji: '🎴'),
    AmericanoRound(
      roundNumber: 3,
      titleKey: 'americano.round_3',
      emoji: '🃏🃏',
    ),
    AmericanoRound(
      roundNumber: 4,
      titleKey: 'americano.round_4',
      emoji: '🎴🎴',
    ),
    AmericanoRound(
      roundNumber: 5,
      titleKey: 'americano.round_5',
      emoji: '🃏🎴',
    ),
    AmericanoRound(roundNumber: 6, titleKey: 'americano.round_6', emoji: '⬛'),
    AmericanoRound(roundNumber: 7, titleKey: 'americano.round_7', emoji: '📏'),
    AmericanoRound(roundNumber: 8, titleKey: 'americano.round_8', emoji: '⬛⬛'),
    AmericanoRound(
      roundNumber: 9,
      titleKey: 'americano.round_9',
      emoji: '📏📏',
    ),
    AmericanoRound(
      roundNumber: 10,
      titleKey: 'americano.round_10',
      emoji: '⬛📏',
    ),
    AmericanoRound(
      roundNumber: 11,
      titleKey: 'americano.round_11',
      emoji: '📏✨',
    ),
    AmericanoRound(
      roundNumber: 12,
      titleKey: 'americano.round_12',
      emoji: '👑',
    ),
  ];

  static AmericanoRound? forRound(int round) {
    if (round < 1 || round > rounds.length) return null;
    return rounds[round - 1];
  }

  String get title => Localization.t(titleKey);
}

/// Oyun modeli
class Game {
  final String id;
  final DateTime createdAt;
  DateTime? endedAt;
  final Team team1;
  final Team team2;
  int currentRound;
  bool isFinished;
  final GameMode gameMode;

  Game({
    required this.id,
    required this.createdAt,
    this.endedAt,
    required this.team1,
    required this.team2,
    this.currentRound = 1,
    this.isFinished = false,
    this.gameMode = GameMode.okey101,
  });

  List<Player> get allPlayers => [
    team1.player1,
    team1.player2,
    team2.player1,
    team2.player2,
  ];

  Player getPlayerBySeat(int seatIndex) =>
      allPlayers.firstWhere((p) => p.seatIndex == seatIndex);

  Team getTeamForPlayer(Player player) {
    if (team1.player1.id == player.id || team1.player2.id == player.id) {
      return team1;
    }
    return team2;
  }

  Player? get leadingPlayer {
    final sorted = List<Player>.from(allPlayers)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));
    return sorted.isNotEmpty ? sorted.first : null;
  }

  Team? get leadingTeam {
    if (team1.totalScore < team2.totalScore) return team1;
    if (team2.totalScore < team1.totalScore) return team2;
    return null;
  }

  bool get isAmericano =>
      gameMode == GameMode.americano || gameMode == GameMode.americanoSolo;

  bool get isAmericanoSolo => gameMode == GameMode.americanoSolo;

  /// Americano'da maksimum 12 tur var
  bool get isLastAmericanoRound => isAmericano && currentRound >= 12;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'team1': team1.toJson(),
    'team2': team2.toJson(),
    'currentRound': currentRound,
    'isFinished': isFinished,
    'gameMode': gameMode.name,
  };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    team1: Team.fromJson(json['team1']),
    team2: Team.fromJson(json['team2']),
    currentRound: json['currentRound'],
    isFinished: json['isFinished'] ?? false,
    gameMode: _parseGameMode(json['gameMode']),
  );

  /// Geriye dönük uyumluluk: eski kayıtlarda int index, yenilerde String name
  static GameMode _parseGameMode(dynamic raw) {
    if (raw == null) return GameMode.okey101;
    if (raw is int) return GameMode.values[raw];
    try {
      return GameMode.values.byName(raw as String);
    } catch (_) {
      return GameMode.okey101;
    }
  }
}
