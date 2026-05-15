import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class TeamScoreBar extends StatelessWidget {
  final Team team1;
  final Team team2;

  const TeamScoreBar({
    super.key,
    required this.team1,
    required this.team2,
  });

  @override
  Widget build(BuildContext context) {
    final team1Leading = team1.totalScore < team2.totalScore;
    final team2Leading = team2.totalScore < team1.totalScore;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Takım 1
          Expanded(
            child: _buildTeamInfo(team1, team1Leading, true),
          ),
          // Ortadaki alan (VS ve Fark)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if ((team1.totalScore - team2.totalScore).abs() > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Fark: ${(team1.totalScore - team2.totalScore).abs()}',
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          // Takım 2
          Expanded(
            child: _buildTeamInfo(team2, team2Leading, false),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(Team team, bool isLeading, bool isLeft) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment:
              isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (isLeading && isLeft)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.emoji_events,
                    color: AppTheme.accentGold, size: 16),
              ),
            Flexible(
              child: Text(
                team.name,
                style: TextStyle(
                  color: isLeading
                      ? AppTheme.accentGold
                      : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLeading && !isLeft)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.emoji_events,
                    color: AppTheme.accentGold, size: 16),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${team.totalScore}',
          style: TextStyle(
            color: team.totalScore < 0
                ? AppTheme.successGreen
                : team.totalScore > 0
                    ? AppTheme.dangerRed
                    : AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
          textAlign: isLeft ? TextAlign.left : TextAlign.right,
        ),
        Text(
          '${team.player1.name} + ${team.player2.name}',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isLeft ? TextAlign.left : TextAlign.right,
        ),
      ],
    );
  }
}
