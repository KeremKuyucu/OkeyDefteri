import 'score_models.dart';
import 'game_rules_models.dart';
import '../services/toxic_nickname_service.dart';

export 'score_models.dart';
export 'game_rules_models.dart';

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
    return ToxicNicknameService.getNickname(this, allPlayers, roundNumber);
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
  final GameMode gameMode;
  GameRules rules;

  Game({
    required this.id,
    required this.createdAt,
    this.endedAt,
    required this.team1,
    required this.team2,
    this.currentRound = 1,
    this.isFinished = false,
    this.gameMode = GameMode.okey101,
    GameRules? rules,
  }) : rules = rules ?? GameRules();

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
      ..sort((a, b) => isNormalOkey
          ? b.totalScore.compareTo(a.totalScore)
          : a.totalScore.compareTo(b.totalScore));
    return sorted.isNotEmpty ? sorted.first : null;
  }

  Team? get leadingTeam {
    if (isNormalOkey) {
      if (team1.totalScore > team2.totalScore) return team1;
      if (team2.totalScore > team1.totalScore) return team2;
      return null;
    }
    if (team1.totalScore < team2.totalScore) return team1;
    if (team2.totalScore < team1.totalScore) return team2;
    return null;
  }

  bool get isNormalOkey => gameMode == GameMode.normalOkey;

  bool get isAmericano =>
      gameMode == GameMode.americano || gameMode == GameMode.americanoSolo;

  bool get isAmericanoSolo => gameMode == GameMode.americanoSolo;

  /// Americano'da maksimum 12 tur var
  bool get isLastAmericanoRound => isAmericano && currentRound >= 12;

  /// Katlamalı barajını güncelle (örn: 104 puanla açıldı -> yeni baraj 105)
  void updateKatlamaliThreshold(int newThreshold) {
    if (newThreshold > rules.currentKatlamaliThreshold) {
      rules.currentKatlamaliThreshold = newThreshold;
    }
  }

  /// Yeni tura geçerken katlamalı barajını sıfırla
  void resetKatlamaliThreshold() {
    rules.currentKatlamaliThreshold = 101;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'team1': team1.toJson(),
    'team2': team2.toJson(),
    'currentRound': currentRound,
    'isFinished': isFinished,
    'gameMode': gameMode.name,
    'rules': rules.toJson(),
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
    rules: GameRules.fromJson(json['rules'] as Map<String, dynamic>?),
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
