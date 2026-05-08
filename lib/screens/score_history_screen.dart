import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class ScoreHistoryScreen extends StatelessWidget {
  final Game game;

  const ScoreHistoryScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Tüm skorları topla ve zamana göre sırala
    final allScores = <MapEntry<Player, ScoreEntry>>[];
    for (final player in game.allPlayers) {
      for (final score in player.scores) {
        allScores.add(MapEntry(player, score));
      }
    }
    allScores.sort(
        (a, b) => b.value.timestamp.compareTo(a.value.timestamp));

    // Ellere göre grupla
    final roundGroups = <int, List<MapEntry<Player, ScoreEntry>>>{};
    for (final entry in allScores) {
      final round = entry.value.roundNumber;
      roundGroups.putIfAbsent(round, () => []);
      roundGroups[round]!.add(entry);
    }

    final sortedRounds = roundGroups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Skor Geçmişi',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: allScores.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history,
                      size: 64,
                      color: AppTheme.textMuted.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz skor girişi yok',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedRounds.length,
              itemBuilder: (context, index) {
                final round = sortedRounds[index];
                final entries = roundGroups[round]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // El başlığı
                    Container(
                      margin: const EdgeInsets.only(bottom: 8, top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'El $round',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // Skorlar
                    ...entries.map((entry) => _buildScoreItem(
                          entry.key,
                          entry.value,
                        )),
                    if (index < sortedRounds.length - 1)
                      Divider(
                        color: AppTheme.lightGreen.withValues(alpha: 0.1),
                        height: 24,
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildScoreItem(Player player, ScoreEntry score) {
    final isPositive = score.effectivePoints > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? AppTheme.dangerRed.withValues(alpha: 0.15)
              : AppTheme.successGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Oyuncu avatarı
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                player.name.isNotEmpty
                    ? player.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Detaylar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${score.type.emoji} ${score.type.label}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    if (score.isCiftli) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'x2 ÇİFTLİ',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Puan
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppTheme.dangerRed.withValues(alpha: 0.15)
                  : AppTheme.successGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${isPositive ? "+" : ""}${score.effectivePoints}',
              style: TextStyle(
                color: isPositive
                    ? AppTheme.dangerRed
                    : AppTheme.successGreen,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
