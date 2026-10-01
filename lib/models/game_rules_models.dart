import '../services/localization_service.dart';
import 'score_models.dart';

/// Oyun modu
enum GameMode { okey101, americano, americanoSolo, normalOkey }

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

/// Masa kuralları ve puan çarpanları
class GameRules {
  final bool isKatlamali;
  final int penaltyPoints; // Standart 101
  final int cantOpenPoints; // Standart 202
  final int finishPoints; // Standart -101
  int currentKatlamaliThreshold; // Katlamalı için güncel baraj puanı (başlangıç 101)
  final int? targetScore; // İsteğe bağlı hedef puan limiti

  GameRules({
    this.isKatlamali = false,
    this.penaltyPoints = 101,
    this.cantOpenPoints = 202,
    this.finishPoints = -101,
    this.currentKatlamaliThreshold = 101,
    this.targetScore,
  });

  /// Puan türüne göre kuraldaki uygun temel puanı döndürür
  int getPointsFor(ScoreType type) {
    switch (type) {
      case ScoreType.islekAtti:
      case ScoreType.okeyAtti:
      case ScoreType.okeyiniAldilar:
      case ScoreType.yanlisElActi:
        return penaltyPoints;
      case ScoreType.acamadi:
        return cantOpenPoints;
      case ScoreType.normalBitti:
        return finishPoints;
      case ScoreType.eldenBitti:
      case ScoreType.okeyAtarakBitti:
        return finishPoints * 2;
      case ScoreType.okeyAtarakEldenBitti:
        return finishPoints * 4;
      default:
        return type.defaultPoints;
    }
  }

  Map<String, dynamic> toJson() => {
    'isKatlamali': isKatlamali,
    'penaltyPoints': penaltyPoints,
    'cantOpenPoints': cantOpenPoints,
    'finishPoints': finishPoints,
    'currentKatlamaliThreshold': currentKatlamaliThreshold,
    if (targetScore != null) 'targetScore': targetScore,
  };

  factory GameRules.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GameRules();
    return GameRules(
      isKatlamali: json['isKatlamali'] ?? false,
      penaltyPoints: json['penaltyPoints'] ?? 101,
      cantOpenPoints: json['cantOpenPoints'] ?? 202,
      finishPoints: json['finishPoints'] ?? -101,
      currentKatlamaliThreshold: json['currentKatlamaliThreshold'] ?? 101,
      targetScore: json['targetScore'] as int?,
    );
  }

  GameRules copyWith({
    bool? isKatlamali,
    int? penaltyPoints,
    int? cantOpenPoints,
    int? finishPoints,
    int? currentKatlamaliThreshold,
    int? targetScore,
  }) {
    return GameRules(
      isKatlamali: isKatlamali ?? this.isKatlamali,
      penaltyPoints: penaltyPoints ?? this.penaltyPoints,
      cantOpenPoints: cantOpenPoints ?? this.cantOpenPoints,
      finishPoints: finishPoints ?? this.finishPoints,
      currentKatlamaliThreshold:
          currentKatlamaliThreshold ?? this.currentKatlamaliThreshold,
      targetScore: targetScore ?? this.targetScore,
    );
  }
}
