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
}

extension ScoreTypeExtension on ScoreType {
  String get label {
    switch (this) {
      case ScoreType.islekAtti:
        return 'İşlek Attı';
      case ScoreType.okeyAtti:
        return 'Okey Attı';
      case ScoreType.okeyiniAldilar:
        return 'Okeyini Aldılar';
      case ScoreType.yanlisElActi:
        return 'Yanlış El Açtı';
      case ScoreType.normalBitti:
        return 'Normal Bitti';
      case ScoreType.eldenBitti:
        return 'Elden Bitti';
      case ScoreType.okeyAtarakBitti:
        return 'Okey Atarak Bitti';
      case ScoreType.okeyAtarakEldenBitti:
        return 'Okey Atarak Elden Bitti';
      case ScoreType.acamadi:
        return 'Açamadı';
      case ScoreType.attigiTasiAldilar:
        return 'Attığı Taşı Aldılar';
      case ScoreType.eldeKalanTaslar:
        return 'Elde Kalan Taşlar';
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
        return 0;
      case ScoreType.eldenBitti:
        return -101;
      case ScoreType.okeyAtarakBitti:
        return 0;
      case ScoreType.okeyAtarakEldenBitti:
        return -101; // Normal elden bittiği gibi, ancak okey cezaları 2'ye katladığı için sadece ekstra çarpan uygulanır
      case ScoreType.acamadi:
        return 202;
      case ScoreType.attigiTasiAldilar:
        return 0; // Manuel giriş
      case ScoreType.eldeKalanTaslar:
        return 0; // Manuel giriş
    }
  }

  bool get isManual {
    return this == ScoreType.attigiTasiAldilar ||
        this == ScoreType.eldeKalanTaslar;
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
        return 'Okeyini kim aldı?';
      case ScoreType.attigiTasiAldilar:
        return 'Attığı taşı kim aldı?';
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

  /// Oyuncunun mevcut oyun istatistiklerine göre dinamik, aşırı toksik + erotik lakap üretir
  String getNickname(List<Player> allPlayers, int roundNumber) {
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

    final winLossRatio = toplamCeza > 0
        ? toplamBitirme / toplamCeza
        : (toplamBitirme > 0 ? 99.0 : 0.0);

    // ============================================================
    // ERKEN OYUN
    // ============================================================
    if (roundNumber <= 3) {
      if (yanlisEl >= 2) return '🤦‍♂️ Daha ilk el amk malı, niye geldin ki?';
      if (okeyAtti >= 1) return '🃏 Okeyi götüne sokup attı orospu';
      if (islekAtti >= 1) return '🫠 Eli kaydı, amına koduğumun salak';
      if (okeyiniAldilar >= 1) return '😤 İlk elde okeyini siktirdin mi piç?';

      if (okeyEldenBitti >= 1) return '👑🔥 Götünden okey sokup kral oldu';
      if (okeyBitti >= 1) return '⚡ Okeyi amına koyup patlattı';
      if (penaltiesCaused >= 1) return '😈 Rakibin okeyini zorla götüne soktu';

      if (isLeader) return '🚀 Masaya roket gibi girdi, hepinizi sikecek';
      if (isLast) return '🐌 Yarrak gibi başladın yine, klasik';
      return '🃏 Yeni gelen amatör yarrak';
    }

    // ============================================================
    // ORTA OYUN
    // ============================================================
    if (roundNumber <= 7) {
      if (yanlisEl >= 3) return '🤡 El açma fahişesi, amk';
      if (acamadi >= 4) return '🧱 Beton göt, hâlâ açamıyor orospu';
      if ((islekAtti + okeyAtti) >= 4) return '🎁 Herkesin amına taş dağıtıyor';

      if (isLast && scoreDiff > 250) return '💸 Masanın top orospusu, para yiyor';
      if (okeyEldenBitti >= 1) return '💎 Okeyi götüne sokup efsane bitirdi';
      if (penaltiesCaused >= 4) return '🏹 Rakibin götünü yırtarak okey çalıyor';
      if (penaltiesReceived >= 3) return '🎯 Herkesin sikiştiği ortak fahişe';
      if (isOnFire) return '🔥 Amına kodumun seri katili, yakıyor';
      if (isLeader) return '😈 Masanın dominantı, hepinizin amına koyuyor';

      return '🃏 Orta oyunda hâlâ götü boklu geziniyor';
    }

    // ============================================================
    // GEÇ OYUN (En sert kısım)
    // ============================================================

    // Felaketler
    if (yanlisEl >= 4) return '🤡 Yanlış el kraliçesi, amına koduğumun geri zekalısı';
    if (acamadi >= 5) return '🧱 Taş gibi göt, hâlâ el açamıyor piç';
    if (okeyiniAldilar >= 3) return '😩 Okeyini herkesin götüne sokturuyor';

    // İyi olanlar (zorba + erotik)
    if (penaltiesCaused >= 6) return '🏹 Okey avcısı, rakibin götünü parçalayan ibne';
    if (okeyEldenBitti >= 2) return '👑 Götünden okey sokarak tahtı sikti';
    if (okeyBitti >= 4) return '🚬 Masayı siker gibi yaktı, kül etti';
    if (eldenBitti >= 3) return '🥷 Sessizce gelip hepinizin götünden bitiriyor';

    if (isOnFire && isLeader) return '🔥 Durdurulamayan am canavarı, masayı sikiyor';
    if (winLossRatio >= 3.0 && isLeader) return '🏆 Masanın siki, tartışmasız dominant';

    // Puan durumu
    if (isLast && totalScore > 700) return '💸 Masanın sokulan orospusu, para yiyor';
    if (isLast) return '📉 Götü boklu sonuncu, yine yedin amk';

    if (isLeader && totalScore < -500) return '🕶️ Masanın mutlak sikici kralı';
    if (isLeader) return '😈 Hepinizin amına koyuyorum, önde geziyorum';

    if (totalScore > 500) return '🥵 Defibrilatörle amını kurtaralım kral';
    if (totalScore > 300) return '😮‍💨 Götün yanıyor ama hâlâ dayanıyorsun';

    return '🃏 Amatör göt, hâlâ bir şey yapamadın';
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

/// Oyun modeli
class Game {
  final String id;
  final DateTime createdAt;
  DateTime? endedAt;
  final Team team1;
  final Team team2;
  int currentRound;
  bool isFinished;

  Game({
    required this.id,
    required this.createdAt,
    this.endedAt,
    required this.team1,
    required this.team2,
    this.currentRound = 1,
    this.isFinished = false,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'team1': team1.toJson(),
    'team2': team2.toJson(),
    'currentRound': currentRound,
    'isFinished': isFinished,
  };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    team1: Team.fromJson(json['team1']),
    team2: Team.fromJson(json['team2']),
    currentRound: json['currentRound'],
    isFinished: json['isFinished'] ?? false,
  );
}
