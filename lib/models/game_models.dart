/// Skor giriş türleri
enum ScoreType {
  islekAtti, // +101 İşlek attı
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

  /// Oyuncunun mevcut oyun istatistiklerine göre dinamik bir lakap (nickname) üretir
  String getNickname(List<Player> allPlayers, int roundNumber) {
    final scores = this.scores;
    final totalScore = this.totalScore;

    // İstatistiksel veriler
    int okeyBitti = scores
        .where((s) => s.type == ScoreType.okeyAtarakBitti)
        .length;
    int eldenBitti = scores.where((s) => s.type == ScoreType.eldenBitti).length;
    int islekAtti = scores.where((s) => s.type == ScoreType.islekAtti).length;
    int yanlisEl = scores.where((s) => s.type == ScoreType.yanlisElActi).length;
    int acamadi = scores.where((s) => s.type == ScoreType.acamadi).length;

    // Ceza analizi
    int penaltiesCaused = 0;
    int penaltiesReceived = scores
        .where((s) => s.causedByPlayerId != null && s.causedByPlayerId != id)
        .length;
    for (final p in allPlayers) {
      if (p.id == id) continue;
      penaltiesCaused += p.scores.where((s) => s.causedByPlayerId == id).length;
    }

    // Sıralama analizi
    final sorted = List<Player>.from(allPlayers)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));
    final myRank = sorted.indexWhere(
      (p) => p.id == id,
    ); // 0 = birinci (en az puan)
    final isLeader = myRank == 0;
    final isLast = myRank == sorted.length - 1;
    final isSecondLast = myRank == sorted.length - 2;

    // Birinci ile fark
    final leaderScore = sorted.first.totalScore;
    final scoreDiff = totalScore - leaderScore; // pozitif = geride

    // Erken oyun (1-3 el) — hafif dokunuşlar
    if (roundNumber <= 3) {
      if (yanlisEl >= 1) return '🤨 Acemi misin';
      if (islekAtti >= 1) return '🎁 Eli Açık';
      if (acamadi >= 2) return '🧐 Çalışıyor...';
      if (okeyBitti >= 1) return '⚡ Hızlı Başlangıç';
      if (eldenBitti >= 1) return '🤫 Sessiz Tehlike';
      if (isLeader) return '📈 Şimdilik Önde';
      if (isLast) return '🐌 Isınıyor';
      return '🃏 Oyuncu';
    }

    // Orta oyun (4-7 el) — dişler görünmeye başlar
    if (roundNumber <= 7) {
      if (yanlisEl >= 3) return '🤡 El Açma Uzmanı';
      if (yanlisEl >= 2) return '💀 İki Kez Mahvoldu';
      if (islekAtti >= 3) return '🎪 Hayır Kurumu Başkanı';
      if (acamadi >= 4) return '🧱 Beton Kafası';
      if (isLast && scoreDiff > 200) return '🚑 Ambulans Çağırın';
      if (isLast && scoreDiff > 100) return '💸 Para Yakıyor';
      if (okeyBitti >= 3) return '🎰 Slotuna Basan';
      if (okeyBitti >= 2) return '🔫 İki El Ateş';
      if (eldenBitti >= 2) return '👻 Görünmez Bıçak';
      if (penaltiesCaused >= 4) return '☠️ Tablo Katili';
      if (penaltiesCaused >= 2) return '🐍 Zehirli Dil';
      if (penaltiesReceived >= 3) return '🎯 Herkesin Hedefi';
      if (isLeader && scoreDiff < -150) return '🦅 Tepede Tek';
      if (isLeader) return '😏 Şimdilik Güvendeyim';
      if (isSecondLast) return '😰 Kıl Payı';
      return '🃏 Orta Yerde';
    }

    // Geç oyun (8+ el) — acımasız değerlendirme
    // 1. Tarihi Felaketler
    if (yanlisEl >= 4) return '🤡 Sirk Direktörü';
    if (yanlisEl >= 3) return '🤡 Milli Rezalet';
    if (yanlisEl >= 2 && isLast) return '💩 İki Kere Battı Bir Kere Görür';
    if (yanlisEl >= 2) return '🤡 Sirk Maymunu';

    if (isLast && totalScore > 600) return '🏦 Banka Mı Açtın';
    if (isLast && totalScore > 400) return '💸 Sponsor';
    if (isLast && scoreDiff > 300) return '🌍 Başka Bir Oyundan Geliyor';

    if (islekAtti >= 4) return '🎪 Martaval Dağıtım A.Ş.';
    if (islekAtti >= 3) return '🎁 Sevgili Baba Noel';
    if (islekAtti >= 2 && penaltiesReceived >= 2) return '😭 Hem Attı Hem Yedi';

    if (acamadi >= 5) return '🧱 Duvar Ustası Usta';
    if (acamadi >= 3 && islekAtti >= 2) return '🪨 Kaya Gibi Oturdu';
    if (acamadi >= 3) return '🧱 Beton';

    // 2. Agresif & Dominans
    if (okeyBitti >= 4) return '🚬 Masayı Yakan';
    if (okeyBitti >= 3 && isLeader) return '💣 Bomba';
    if (okeyBitti >= 2 && isLeader) return '🚬 Masayı Dağıtan';
    if (okeyBitti >= 2) return '🎯 Tetikçi';

    if (eldenBitti >= 3) return '💨 Var mıydı Yok muydu';
    if (eldenBitti >= 2 && isLeader) return '🥷 Suikastçı';
    if (eldenBitti >= 2) return '👻 Hayalet';

    if (penaltiesCaused >= 5) return '☠️ Katliam Makinesi';
    if (penaltiesCaused >= 3 && isLeader) return '😈 Şeytan';
    if (penaltiesCaused >= 3) return '🐍 Engerek';
    if (penaltiesCaused >= 2 && penaltiesReceived == 0) return '🕵️ Dokunulmaz';

    // 3. Puan durumu
    if (isLeader && totalScore < -300) return '🕶️ Kral';
    if (isLeader && totalScore < -150) return '🕶️ Masa Ağası';
    if (isLeader && scoreDiff < -200) return '🏆 Tek';
    if (isLeader) return '😤 Önde Ama Rahat Değil';

    if (totalScore < -100) return '🔥 Alev Alev';
    if (totalScore < 0) return '🔥 Formunda';
    if (totalScore > 500) return '🫁 Suni Solunum';
    if (totalScore > 300) return '🥵 Defibrilatör Lazım';
    if (totalScore > 200) return '😮‍💨 Oksijen Tüpü Lazım';

    if (isLast) return '📉 Dönüşü Olmayan Yol';
    if (isSecondLast) return '🙏 Sondan Bir Önceki';

    return '🃏 Oyuncu';
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
