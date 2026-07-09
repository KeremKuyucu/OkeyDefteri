import 'package:okey_defteri/services/settings_service.dart';
import '../services/localization_service.dart';

/// Oyun modu
enum GameMode { okey101, americano }

/// Skor giriş türleri
enum ScoreType {
  islekAtti, // +101 İşlek attı
  okeyAtti, // +101 Okey attı
  okeyiniAldilar, // +101 Okeyini aldılar
  yanlisElActi, // +101 Yanlış el açtı
  normalBitti, // -101 Normal bitti (elle kapattı)
  eldenBitti, // -101 Elden bitti
  okeyAtarakBitti, // -101 Okey atarak bitti
  okeyAtarakEldenBitti, // 2x + -101 Okey atarak elden bitti
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
    }
  }

  bool get isManual {
    return this == ScoreType.attigiTasiAldilar ||
        this == ScoreType.eldeKalanTaslar ||
        this == ScoreType.americanoEldeKalan;
  }

  /// Americano'ya mı özel?
  bool get isAmericano {
    return this == ScoreType.americanoEldeKalan ||
        this == ScoreType.americanoIslek ||
        this == ScoreType.americanoHile ||
        this == ScoreType.americanoKazandi;
  }

  /// Bu tür bir bitirme türü mü?
  bool get isFinishType {
    return this == ScoreType.normalBitti ||
        this == ScoreType.eldenBitti ||
        this == ScoreType.okeyAtarakBitti ||
        this == ScoreType.okeyAtarakEldenBitti;
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
    'type': type.index,
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
    type: ScoreType.values[json['type']],
    points: json['points'],
    isCiftli: json['isCiftli'] ?? false,
    isOkeyFinish: json['isOkeyFinish'] ?? false,
    isCauserCiftli: json['isCauserCiftli'] ?? false,
    timestamp: DateTime.parse(json['timestamp']),
    roundNumber: json['roundNumber'],
    causedByPlayerId: json['causedByPlayerId'],
  );
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
    bool isCiftliGidiyor = false,
  }) : _isCiftliGidiyor = isCiftliGidiyor,
       scores = scores ?? [];

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

  /// Oyuncunun mevcut oyun istatistiklerine göre dinamik lakap üretir
  String getNickname(List<Player> allPlayers, int roundNumber) {
    if (!SettingsService.getToxicNicknamesEnabled()) return '';

    final scores = this.scores;
    final totalScore = this.totalScore;

    int okeyBitti = scores
        .where((s) => s.type == ScoreType.okeyAtarakBitti)
        .length;
    int okeyEldenBitti = scores
        .where((s) => s.type == ScoreType.okeyAtarakEldenBitti)
        .length;
    int eldenBitti = scores.where((s) => s.type == ScoreType.eldenBitti).length;
    int normalBitti = scores
        .where((s) => s.type == ScoreType.normalBitti)
        .length;
    int toplamBitirme = okeyBitti + okeyEldenBitti + eldenBitti + normalBitti;

    int islekAtti = scores.where((s) => s.type == ScoreType.islekAtti).length;
    int okeyAtti = scores.where((s) => s.type == ScoreType.okeyAtti).length;
    int yanlisEl = scores.where((s) => s.type == ScoreType.yanlisElActi).length;
    int acamadi = scores.where((s) => s.type == ScoreType.acamadi).length;

    int okeyiniAldilar = scores
        .where((s) => s.type == ScoreType.okeyiniAldilar)
        .length;
    int toplamCeza = islekAtti + okeyAtti + yanlisEl + acamadi + okeyiniAldilar;

    int penaltiesCaused = 0;
    int penaltiesReceived = scores
        .where((s) => s.causedByPlayerId != null && s.causedByPlayerId != id)
        .length;

    for (final p in allPlayers) {
      if (p.id == id) continue;
      penaltiesCaused += p.scores.where((s) => s.causedByPlayerId == id).length;
    }

    final sorted = List<Player>.from(allPlayers)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));
    final myRank = sorted.indexWhere((p) => p.id == id);
    final isLeader = myRank == 0;
    final isLast = myRank == sorted.length - 1;
    final isSecondLast = myRank == sorted.length - 2;

    final scoreDiff = totalScore - sorted.first.totalScore;
    final diffFromLast = sorted.last.totalScore - totalScore;

    final recentScores = scores.length >= 3
        ? scores.sublist(scores.length - 3)
        : scores;
    final isOnFire =
        recentScores.where((s) => s.effectivePoints < 0).length >= 3;
    final isSinking =
        recentScores.where((s) => s.effectivePoints > 0).length >= 3;

    // ============================================================
    // ERKEN OYUN
    // ============================================================
    if (roundNumber <= 3) {
      if (yanlisEl >= 2) return Localization.t('nicknames.early_yanlis_el');
      if (okeyAtti >= 1) return Localization.t('nicknames.early_okey_atti');
      if (islekAtti >= 1) return Localization.t('nicknames.early_islek_atti');
      if (okeyiniAldilar >= 1)
        return Localization.t('nicknames.early_okeyini_aldilar');

      if (okeyEldenBitti >= 1)
        return Localization.t('nicknames.early_okey_elden_bitti');
      if (okeyBitti >= 1) return Localization.t('nicknames.early_okey_bitti');
      if (penaltiesCaused >= 1)
        return Localization.t('nicknames.early_penalties_caused');

      if (isLeader) return Localization.t('nicknames.early_leader');
      if (isLast) return Localization.t('nicknames.early_last');
      return Localization.t('nicknames.early_default');
    }

    // ============================================================
    // ORTA OYUN
    // ============================================================
    if (roundNumber <= 7) {
      if (yanlisEl >= 3) return Localization.t('nicknames.mid_yanlis_el');
      if (acamadi >= 4) return Localization.t('nicknames.mid_acamadi');
      if ((islekAtti + okeyAtti) >= 4)
        return Localization.t('nicknames.mid_tas_dagitma');

      if (isLast && scoreDiff > 250)
        return Localization.t('nicknames.mid_last_far');
      if (okeyEldenBitti >= 1)
        return Localization.t('nicknames.mid_okey_elden_bitti');
      if (penaltiesCaused >= 4)
        return Localization.t('nicknames.mid_penalties_caused');
      if (penaltiesReceived >= 3)
        return Localization.t('nicknames.mid_penalties_received');
      if (isOnFire) return Localization.t('nicknames.mid_on_fire');
      if (isLeader) return Localization.t('nicknames.mid_leader');

      return Localization.t('nicknames.mid_default');
    }

    // ============================================================
    // GEÇ OYUN (En sert kısım)
    // ============================================================

    // Felaketler
    if (yanlisEl >= 4) return Localization.t('nicknames.late_yanlis_el');
    if (acamadi >= 5) return Localization.t('nicknames.late_acamadi');
    if (okeyiniAldilar >= 3)
      return Localization.t('nicknames.late_okeyini_aldilar');

    // İyi olanlar (zorba + erotik)
    if (penaltiesCaused >= 6)
      return Localization.t('nicknames.late_penalties_caused');
    if (okeyEldenBitti >= 2)
      return Localization.t('nicknames.late_okey_elden_bitti');
    if (okeyBitti >= 4) return Localization.t('nicknames.late_okey_bitti');
    if (eldenBitti >= 3) return Localization.t('nicknames.late_elden_bitti');

    if (isOnFire && isLeader)
      return Localization.t('nicknames.late_on_fire_leader');

    final double winLossRatio = (roundNumber - toplamBitirme) > 0
        ? (toplamBitirme / (roundNumber - toplamBitirme))
        : toplamBitirme.toDouble();
    if (winLossRatio >= 3.0 && isLeader)
      return Localization.t('nicknames.late_win_ratio_leader');

    // Puan durumu
    if (isLast && totalScore > 700)
      return Localization.t('nicknames.late_last_very_far');
    if (isLast) return Localization.t('nicknames.late_last');

    if (isLeader && totalScore < -500)
      return Localization.t('nicknames.late_leader_very_far');
    if (isLeader) return Localization.t('nicknames.late_leader');

    if (totalScore > 500) return Localization.t('nicknames.late_score_500');
    if (totalScore > 300) return Localization.t('nicknames.late_score_300');

    return Localization.t('nicknames.late_default');
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

  bool get isAmericano => gameMode == GameMode.americano;

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
    'gameMode': gameMode.index,
  };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    team1: Team.fromJson(json['team1']),
    team2: Team.fromJson(json['team2']),
    currentRound: json['currentRound'],
    isFinished: json['isFinished'] ?? false,
    gameMode: json['gameMode'] != null
        ? GameMode.values[json['gameMode']]
        : GameMode.okey101,
  );
}
