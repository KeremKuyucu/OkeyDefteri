/// Oyuncu profili ve istatistik modelleri
class PartnerSynergy {
  final String partnerName;
  final int gamesTogether;
  final int winsTogether;

  PartnerSynergy({
    required this.partnerName,
    required this.gamesTogether,
    required this.winsTogether,
  });

  double get winRate =>
      gamesTogether > 0 ? (winsTogether / gamesTogether) * 100 : 0.0;
}

class PlayerProfile {
  final String name;
  final int gamesPlayed;
  final int gamesWon;
  final int totalPenalties;
  final int totalOkeyFinishes;
  final int totalIslekAtti;
  final int totalPoints;
  final List<PartnerSynergy> bestPartners;
  final List<int> recentScores;

  PlayerProfile({
    required this.name,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.totalPenalties,
    required this.totalOkeyFinishes,
    required this.totalIslekAtti,
    required this.totalPoints,
    required this.bestPartners,
    this.recentScores = const [],
  });

  double get winRate =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

  double get averageScore =>
      gamesPlayed > 0 ? (totalPoints / gamesPlayed) : 0.0;

  double get penaltiesPerGame =>
      gamesPlayed > 0 ? (totalPenalties / gamesPlayed) : 0.0;

  PartnerSynergy? get topPartner =>
      bestPartners.isNotEmpty ? bestPartners.first : null;
}
