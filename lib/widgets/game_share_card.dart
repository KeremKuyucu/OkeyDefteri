import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/localization_service.dart';

/// Paylaşım için render edilen zengin oyun sonuç kartı.
/// RepaintBoundary içinde çizilip yüksek çözünürlüklü PNG'ye dönüştürülür.
class GameShareCard extends StatelessWidget {
  final Game game;

  const GameShareCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final winTeam = game.leadingTeam;
    final winPlayer = game.isAmericanoSolo ? game.leadingPlayer : null;
    final duration = game.endedAt != null
        ? game.endedAt!.difference(game.createdAt)
        : DateTime.now().difference(game.createdAt);

    return Container(
      width: 400,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF08170A),
            Color(0xFF102416),
            Color(0xFF0A1C0E),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Başlık Barı ──
          _buildHeader(game),

          // ── 2. Kazanan Banner ──
          if (winTeam != null || winPlayer != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildWinnerBanner(winTeam, winPlayer),
            ),
          ],

          const SizedBox(height: 10),

          // ── 3. Skor Alanı ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: game.isAmericanoSolo
                ? _buildSoloScores(game)
                : _buildTeamScores(game),
          ),

          const SizedBox(height: 10),

          // ── 4. Maç Özet Çubuğu ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildMatchSummaryBar(game),
          ),

          const SizedBox(height: 12),

          // ── 5. Detaylı Puan Kırılımı Başlığı ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildSectionTitle(
              '📊 ${Localization.t('stats.detailed_score_breakdown')}',
            ),
          ),

          const SizedBox(height: 8),

          // ── 6. Oyuncu / Takım Detaylı Puan Kırılımları ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildDetailedBreakdown(game),
          ),

          const SizedBox(height: 12),

          // ── 7. Alt Bilgi Çubuğu ──
          _buildFooter(game, duration),
        ],
      ),
    );
  }

  // ── Başlık ────────────────────────────────────────────────────────────────

  Widget _buildHeader(Game game) {
    final modeLabel = game.isAmericano
        ? '🃏 ${Localization.t('game_modes.americano')}'
        : game.isNormalOkey
            ? '🀄 ${Localization.t('game_modes.normal_okey')}'
            : '🀄 ${Localization.t('game_modes.okey_101')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('🎴', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localization.t('app.name'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
              Text(
                modeLabel,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 13, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  Localization.t('past_games.round',
                      args: [game.currentRound.toString()]),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Kazanan Banner ────────────────────────────────────────────────────────

  Widget _buildWinnerBanner(Team? winTeam, Player? winPlayer) {
    final name = winTeam?.name ?? winPlayer?.name ?? '';
    final subText = winTeam != null
        ? '${winTeam.player1.name} & ${winTeam.player2.name}'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF283A1E), Color(0xFF1B2D1C)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Localization.t('game_share.winner', args: [name]),
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              if (subText != null)
                Text(
                  subText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Takım Skorları (101 / Normal Okey / Americano Takım) ───────────────────

  Widget _buildTeamScores(Game game) {
    final winTeam = game.leadingTeam;
    final isTeam1Win = winTeam?.id == game.team1.id;
    final isTeam2Win = winTeam?.id == game.team2.id;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.lightGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTeamCard(game.team1, isTeam1Win)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Expanded(child: _buildTeamCard(game.team2, isTeam2Win)),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team, bool isWinner) {
    final score = team.totalScore;
    final scoreColor = score < 0
        ? AppTheme.successGreen
        : score > 0
            ? AppTheme.dangerRed
            : AppTheme.textPrimary;

    final winCount = team.player1.winCount + team.player2.winCount;
    final penaltyCount = team.player1.penaltyCount + team.player2.penaltyCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isWinner
            ? AppTheme.accentGold.withValues(alpha: 0.08)
            : AppTheme.surfaceCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWinner
              ? AppTheme.accentGold.withValues(alpha: 0.4)
              : AppTheme.lightGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isWinner)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('👑', style: TextStyle(fontSize: 12)),
                ),
              Flexible(
                child: Text(
                  team.name,
                  style: TextStyle(
                    color: isWinner ? AppTheme.accentGold : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${team.player1.name} & ${team.player2.name}',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: TextStyle(
              color: scoreColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🏆 $winCount',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '⚠️ $penaltyCount',
                style: const TextStyle(
                  color: AppTheme.dangerRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Solo Skorlar ──────────────────────────────────────────────────────────

  Widget _buildSoloScores(Game game) {
    final sorted = List<Player>.from(game.allPlayers)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));
    final medals = ['🥇', '🥈', '🥉', '4️⃣'];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.lightGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: sorted.asMap().entries.map((e) {
          final rank = e.key;
          final player = e.value;
          final isFirst = rank == 0;
          final score = player.totalScore;
          final scoreColor = score < 0
              ? AppTheme.successGreen
              : score > 0
                  ? AppTheme.dangerRed
                  : AppTheme.textPrimary;

          return Container(
            margin: EdgeInsets.only(bottom: rank < 3 ? 6 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isFirst
                  ? AppTheme.accentGold.withValues(alpha: 0.08)
                  : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFirst
                    ? AppTheme.accentGold.withValues(alpha: 0.35)
                    : AppTheme.lightGreen.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Text(medals[rank], style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    player.name,
                    style: TextStyle(
                      color: isFirst ? AppTheme.accentGold : AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${player.winCount}${Localization.t('game_share.win_abbr')} • ${player.penaltyCount}${Localization.t('game_share.penalty_abbr')}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$score',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Maç Özet Çubuğu ───────────────────────────────────────────────────────

  Widget _buildMatchSummaryBar(Game game) {
    final totalWins = game.allPlayers.fold(0, (sum, p) => sum + p.winCount);
    final totalPenalties =
        game.allPlayers.fold(0, (sum, p) => sum + p.penaltyCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.lightGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat('🏆 ${Localization.t('game_share.total_finishes')}', '$totalWins'),
          Container(
            width: 1,
            height: 14,
            color: AppTheme.lightGreen.withValues(alpha: 0.2),
          ),
          _buildMiniStat('⚠️ ${Localization.t('game_share.total_penalties')}', '$totalPenalties'),
          Container(
            width: 1,
            height: 14,
            color: AppTheme.lightGreen.withValues(alpha: 0.2),
          ),
          _buildMiniStat('🎯 ${Localization.t('game_share.round_count')}', '${game.currentRound}'),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ── Başlık Barı ───────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ── Detaylı Puan Kırılımı ──────────────────────────────────────────────────

  Widget _buildDetailedBreakdown(Game game) {
    final players = game.allPlayers;

    return Column(
      children: players.map((player) {
        final breakdown = player.scoreBreakdown;
        final score = player.totalScore;
        final scoreColor = score < 0
            ? AppTheme.successGreen
            : score > 0
                ? AppTheme.dangerRed
                : AppTheme.textPrimary;

        final team = game.getTeamForPlayer(player);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.lightGreen.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Oyuncu Başlık Satırı
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        player.name.isNotEmpty
                            ? player.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!game.isAmericanoSolo)
                          Text(
                            team.name,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: score < 0
                          ? AppTheme.successGreen.withValues(alpha: 0.15)
                          : AppTheme.dangerRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: score < 0
                            ? AppTheme.successGreen.withValues(alpha: 0.3)
                            : AppTheme.dangerRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${score > 0 ? "+" : ""}$score',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              // Puan Kırılım Satırları
              if (breakdown.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  Localization.t('stats.no_scores'),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: breakdown.entries.map((e) {
                      final type = e.key;
                      final total = e.value;
                      final count =
                          player.scores.where((s) => s.type == type).length;

                      final causerCounts = <String, int>{};
                      if (type.hasCausedBy) {
                        for (final s in player.scores.where((s) => s.type == type)) {
                          if (s.causedByPlayerId != null) {
                            try {
                              final causer = game.allPlayers
                                  .firstWhere((p) => p.id == s.causedByPlayerId);
                              if (causer.id != player.id) {
                                causerCounts[causer.name] =
                                    (causerCounts[causer.name] ?? 0) + 1;
                              }
                            } catch (_) {}
                          }
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${type.label}${count > 1 ? " (×$count)" : ""}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (causerCounts.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        '(${causerCounts.entries.map((c) => '${c.key}: ${c.value}x').join(', ')})',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 9,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${total > 0 ? "+" : ""}$total',
                              style: TextStyle(
                                color: total > 0
                                    ? AppTheme.dangerRed
                                    : AppTheme.successGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Alt Bilgi Çubuğu ──────────────────────────────────────────────────────

  Widget _buildFooter(Game game, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationStr = hours > 0
        ? Localization.t('past_games.hour_minute',
            args: [hours.toString(), minutes.toString()])
        : Localization.t('past_games.minute', args: [minutes.toString()]);

    final dateStr = game.endedAt != null
        ? _formatDate(game.endedAt!)
        : _formatDate(game.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: AppTheme.accentGold.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppTheme.textMuted, size: 12),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  color: AppTheme.textMuted, size: 12),
              const SizedBox(width: 4),
              Text(
                durationStr,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            Localization.t('app.name'),
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

