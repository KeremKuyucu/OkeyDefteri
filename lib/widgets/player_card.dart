import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final Team team;
  final int position; // 0: üst, 1: sağ, 2: alt, 3: sol
  final VoidCallback onTap;
  final bool isHighlighted;

  const PlayerCard({
    super.key,
    required this.player,
    required this.team,
    required this.position,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = player.totalScore < 0;
    final isVertical = position == 1 || position == 3;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: AppTheme.playerCardDecoration(isHighlighted),
        padding: EdgeInsets.symmetric(
          horizontal: isVertical ? 10 : 14,
          vertical: isVertical ? 14 : 10,
        ),
        child: isVertical
            ? _buildVerticalLayout(isNegative)
            : _buildHorizontalLayout(isNegative),
      ),
    );
  }

  Widget _buildHorizontalLayout(bool isNegative) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar ve isim
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(size: 32),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Puan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isNegative
                ? AppTheme.successGreen.withValues(alpha: 0.15)
                : player.totalScore > 0
                    ? AppTheme.dangerRed.withValues(alpha: 0.15)
                    : AppTheme.surfaceCardLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${player.totalScore}',
            style: TextStyle(
              color: isNegative
                  ? AppTheme.successGreen
                  : player.totalScore > 0
                      ? AppTheme.dangerRed
                      : AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Mini istatistik
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _miniStat('🏆', '${player.winCount}'),
            const SizedBox(width: 6),
            _miniStat('⚠️', '${player.penaltyCount}'),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(bool isNegative) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(size: 28),
        const SizedBox(height: 4),
        Text(
          player.name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isNegative
                ? AppTheme.successGreen.withValues(alpha: 0.15)
                : player.totalScore > 0
                    ? AppTheme.dangerRed.withValues(alpha: 0.15)
                    : AppTheme.surfaceCardLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${player.totalScore}',
            style: TextStyle(
              color: isNegative
                  ? AppTheme.successGreen
                  : player.totalScore > 0
                      ? AppTheme.dangerRed
                      : AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _miniStat('🏆', '${player.winCount}'),
            const SizedBox(width: 4),
            _miniStat('⚠️', '${player.penaltyCount}'),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Center(
        child: Text(
          player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.black,
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String emoji, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
