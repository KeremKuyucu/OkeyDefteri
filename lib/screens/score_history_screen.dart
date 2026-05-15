import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class ScoreHistoryScreen extends StatefulWidget {
  final Game game;

  const ScoreHistoryScreen({super.key, required this.game});

  @override
  State<ScoreHistoryScreen> createState() => _ScoreHistoryScreenState();
}

class _ScoreHistoryScreenState extends State<ScoreHistoryScreen> {
  void _deleteScore(Player player, ScoreEntry score) {
    if (widget.game.isFinished) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu oyun bitmiştir, müdahale edilemez.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('İşlemi Sil', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Bu skor girişini silmek istediğinize emin misiniz?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                player.scores.removeWhere((s) => s.id == score.id);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tüm skorları topla ve zamana göre sırala
    final allScores = <MapEntry<Player, ScoreEntry>>[];
    for (final player in widget.game.allPlayers) {
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
          : Column(
              children: [
                // Kullanıcıya bilgi notu
                if (!widget.game.isFinished)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppTheme.accentGold),
                        const SizedBox(width: 8),
                        const Text(
                          'Silmek istediğiniz işlemin üstüne basılı tutun',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
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
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(Player player, ScoreEntry score) {
    final isPositive = score.effectivePoints > 0;
    return GestureDetector(
      onLongPress: () => _deleteScore(player, score),
      child: Container(
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
                    if (score.isOkeyFinish) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7E57C2).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'x2 OKEY',
                          style: TextStyle(
                            color: Color(0xFF7E57C2),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    if (score.isCauserCiftli) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'x2 RAKİP ÇİFTLİ',
                          style: TextStyle(
                            color: AppTheme.warningOrange,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (score.causedByPlayerId != null)
                  Builder(
                    builder: (context) {
                      final causedBy = widget.game.allPlayers
                          .where((p) => p.id == score.causedByPlayerId)
                          .firstOrNull;
                      if (causedBy == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '⚔️ Alan: ${causedBy.name}',
                          style: const TextStyle(
                            color: AppTheme.warningOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
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
    ),
    );
  }
}
