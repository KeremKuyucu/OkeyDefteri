
/// Skor giriş türleri
enum ScoreType {
  islekAtti, // +101 İşlek attı
  okeyiniAldilar, // +101 Okeyini aldılar
  yanlisElActi, // +101 Yanlış el açtı
  eldenBitti, // -101 Elden bitti
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
      case ScoreType.eldenBitti:
        return 'Elden Bitti';
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
      case ScoreType.eldenBitti:
        return '🏆';
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
      case ScoreType.eldenBitti:
        return -101;
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
}

/// Bir skor girişi
class ScoreEntry {
  final String id;
  final ScoreType type;
  final int points;
  final bool isCiftli; // Çiftli gitti ise
  final DateTime timestamp;
  final int roundNumber;

  ScoreEntry({
    required this.id,
    required this.type,
    required this.points,
    this.isCiftli = false,
    required this.timestamp,
    required this.roundNumber,
  });

  int get effectivePoints => isCiftli ? points * 2 : points;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'points': points,
        'isCiftli': isCiftli,
        'timestamp': timestamp.toIso8601String(),
        'roundNumber': roundNumber,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        id: json['id'],
        type: ScoreType.values[json['type']],
        points: json['points'],
        isCiftli: json['isCiftli'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
        roundNumber: json['roundNumber'],
      );
}

/// Oyuncu modeli
class Player {
  final String id;
  String name;
  final int seatIndex; // 0: üst, 1: sağ, 2: alt, 3: sol
  List<ScoreEntry> scores;

  Player({
    required this.id,
    required this.name,
    required this.seatIndex,
    List<ScoreEntry>? scores,
  }) : scores = scores ?? [];

  int get totalScore =>
      scores.fold(0, (sum, entry) => sum + entry.effectivePoints);

  int get penaltyCount =>
      scores.where((s) => s.effectivePoints > 0).length;

  int get winCount =>
      scores.where((s) => s.type == ScoreType.eldenBitti).length;

  Map<ScoreType, int> get scoreBreakdown {
    final breakdown = <ScoreType, int>{};
    for (final entry in scores) {
      breakdown[entry.type] =
          (breakdown[entry.type] ?? 0) + entry.effectivePoints;
    }
    return breakdown;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'seatIndex': seatIndex,
        'scores': scores.map((s) => s.toJson()).toList(),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'],
        seatIndex: json['seatIndex'],
        scores: (json['scores'] as List)
            .map((s) => ScoreEntry.fromJson(s))
            .toList(),
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

  List<Player> get allPlayers =>
      [team1.player1, team1.player2, team2.player1, team2.player2];

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
        endedAt:
            json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
        team1: Team.fromJson(json['team1']),
        team2: Team.fromJson(json['team2']),
        currentRound: json['currentRound'],
        isFinished: json['isFinished'] ?? false,
      );
}
