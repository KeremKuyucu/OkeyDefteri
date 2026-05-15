import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  final Game game;

  const StatsScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final players = game.allPlayers;
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'İstatistikler',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Takım karşılaştırması
            _buildSectionTitle('Takım Karşılaştırması'),
            const SizedBox(height: 8),
            _buildTeamComparison(),
            const SizedBox(height: 24),

            // Oyuncu sıralaması
            _buildSectionTitle('Oyuncu Sıralaması'),
            const SizedBox(height: 8),
            ...sortedPlayers
                .asMap()
                .entries
                .map((e) => _buildPlayerRankCard(e.key, e.value)),

            const SizedBox(height: 24),

            // Detaylı kırılım
            _buildSectionTitle('Detaylı Puan Kırılımı'),
            const SizedBox(height: 8),
            ...players.map((p) => _buildPlayerBreakdown(p)),

            const SizedBox(height: 24),

            // Hata analizi
            _buildSectionTitle('Hata Analizi'),
            const SizedBox(height: 8),
            _buildErrorAnalysis(),

          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamComparison() {
    final team1Score = game.team1.totalScore;
    final team2Score = game.team2.totalScore;
    final maxAbsScore = [team1Score.abs(), team2Score.abs(), 1]
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          _buildTeamBar(game.team1, team1Score, maxAbsScore,
              team1Score < team2Score),
          const SizedBox(height: 16),
          _buildTeamBar(game.team2, team2Score, maxAbsScore,
              team2Score < team1Score),
        ],
      ),
    );
  }

  Widget _buildTeamBar(
      Team team, int score, int maxScore, bool isLeading) {
    final barWidth = maxScore > 0 ? (score.abs() / maxScore) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (isLeading)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.emoji_events,
                        color: AppTheme.accentGold, size: 18),
                  ),
                Text(
                  team.name,
                  style: TextStyle(
                    color: isLeading
                        ? AppTheme.accentGold
                        : AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '$score',
              style: TextStyle(
                color: score < 0
                    ? AppTheme.successGreen
                    : score > 0
                        ? AppTheme.dangerRed
                        : AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: barWidth.clamp(0.0, 1.0),
            backgroundColor: AppTheme.surfaceCardLight,
            valueColor: AlwaysStoppedAnimation(
              score < 0 ? AppTheme.successGreen : AppTheme.dangerRed,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${team.player1.name} (${team.player1.totalScore}) + ${team.player2.name} (${team.player2.totalScore})',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRankCard(int rank, Player player) {
    final medals = ['🥇', '🥈', '🥉', '💃'];
    final isFirst = rank == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isFirst
            ? const LinearGradient(
                colors: [Color(0xFF2A3A1F), Color(0xFF1A2E1F)],
              )
            : null,
        color: isFirst ? null : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: isFirst
            ? Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3))
            : Border.all(
                color: AppTheme.lightGreen.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(
            medals[rank],
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    color: isFirst
                        ? AppTheme.accentGold
                        : AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${player.winCount} galibiyet • ${player.penaltyCount} ceza',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: player.totalScore < 0
                  ? AppTheme.successGreen.withValues(alpha: 0.15)
                  : player.totalScore > 0
                      ? AppTheme.dangerRed.withValues(alpha: 0.15)
                      : AppTheme.surfaceCardLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${player.totalScore}',
              style: TextStyle(
                color: player.totalScore < 0
                    ? AppTheme.successGreen
                    : player.totalScore > 0
                        ? AppTheme.dangerRed
                        : AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBreakdown(Player player) {
    final breakdown = player.scoreBreakdown;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(8),
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
              Text(
                player.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Toplam: ${player.totalScore}',
                style: TextStyle(
                  color: player.totalScore < 0
                      ? AppTheme.successGreen
                      : AppTheme.dangerRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (breakdown.isEmpty)
            const Text(
              'Henüz skor girişi yok',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            )
          else
            ...breakdown.entries.map((e) {
              final type = e.key;
              final total = e.value;
              final count = player.scores
                  .where((s) => s.type == type)
                  .length;

              final causerCounts = <String, int>{};
              if (type.hasCausedBy) {
                for (final score in player.scores.where((s) => s.type == type)) {
                  if (score.causedByPlayerId != null) {
                    try {
                      final causer = game.allPlayers.firstWhere((p) => p.id == score.causedByPlayerId);
                      if (causer.id != player.id) {
                        causerCounts[causer.name] = (causerCounts[causer.name] ?? 0) + 1;
                      }
                    } catch (_) {}
                  }
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${type.emoji} ',
                            style: const TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            '${type.label} (×$count)',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${total > 0 ? "+" : ""}$total',
                          style: TextStyle(
                            color: total > 0
                                ? AppTheme.dangerRed
                                : AppTheme.successGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (causerCounts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 2),
                        child: Text(
                          causerCounts.entries.map((c) => '${c.key}: ${c.value}x').join(' • '),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildErrorAnalysis() {
    final errorTypes = [
      ScoreType.islekAtti,
      ScoreType.okeyiniAldilar,
      ScoreType.yanlisElActi,
      ScoreType.acamadi,
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Başlık satırı
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'Hata Türü',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...game.allPlayers.map((p) => Expanded(
                    flex: 2,
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            ],
          ),
          Divider(color: AppTheme.lightGreen.withValues(alpha: 0.1)),
          // Hata satırları
          ...errorTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${type.emoji} ${type.label}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...game.allPlayers.map((p) {
                    final count = p.scores
                        .where((s) => s.type == type)
                        .length;
                    return Expanded(
                      flex: 2,
                      child: Text(
                        count > 0 ? '$count' : '-',
                        style: TextStyle(
                          color: count > 0
                              ? AppTheme.dangerRed
                              : AppTheme.textMuted,
                          fontSize: 14,
                          fontWeight:
                              count > 0 ? FontWeight.w700 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          Divider(color: AppTheme.lightGreen.withValues(alpha: 0.1)),
          // Galibiyet satırı
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  '🏆 Galibiyet',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              ...game.allPlayers.map((p) => Expanded(
                    flex: 2,
                    child: Text(
                      '${p.winCount}',
                      style: TextStyle(
                        color: p.winCount > 0
                            ? AppTheme.successGreen
                            : AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: p.winCount > 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

}
