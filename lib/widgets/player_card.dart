import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final Team team;
  final int position; // 0: üst, 1: sağ, 2: alt, 3: sol
  final VoidCallback onTap;
  final VoidCallback? onToggleCiftli;
  final bool isHighlighted;
  final String? nickname;
  final bool isHigherScoreBetter;
  final bool hideCiftliToggle;

  const PlayerCard({
    super.key,
    required this.player,
    required this.team,
    required this.position,
    required this.onTap,
    this.onToggleCiftli,
    this.isHighlighted = false,
    this.nickname,
    this.isHigherScoreBetter = false,
    this.hideCiftliToggle = false,
  });

  Color _getScoreColor() {
    if (isHigherScoreBetter) {
      if (player.totalScore > 0) return AppTheme.successGreen;
      if (player.totalScore < 0) return AppTheme.dangerRed;
      return AppTheme.textPrimary;
    } else {
      if (player.totalScore < 0) return AppTheme.successGreen;
      if (player.totalScore > 0) return AppTheme.dangerRed;
      return AppTheme.textPrimary;
    }
  }

  Color _getScoreBgColor() {
    if (isHigherScoreBetter) {
      if (player.totalScore > 0) return AppTheme.successGreen.withValues(alpha: 0.15);
      if (player.totalScore < 0) return AppTheme.dangerRed.withValues(alpha: 0.15);
      return AppTheme.surfaceCardLight;
    } else {
      if (player.totalScore < 0) return AppTheme.successGreen.withValues(alpha: 0.15);
      if (player.totalScore > 0) return AppTheme.dangerRed.withValues(alpha: 0.15);
      return AppTheme.surfaceCardLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = position == 1 || position == 3;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          minWidth: isVertical ? 84 : 110,
          maxWidth: isVertical ? 96 : 140,
        ),
        decoration: AppTheme.playerCardDecoration(isHighlighted),
        padding: EdgeInsets.symmetric(
          horizontal: isVertical ? 8 : 12,
          vertical: isVertical ? 10 : 8,
        ),
        child: isVertical
            ? _buildVerticalLayout()
            : _buildHorizontalLayout(),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    final showTeamName = team.name.isNotEmpty && team.name != player.name;

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
                  if (showTeamName)
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
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
            color: _getScoreBgColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${player.totalScore}',
            style: TextStyle(
              color: _getScoreColor(),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Mini istatistik + çiftli toggle
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _miniStat('🏆', '${player.winCount}'),
            const SizedBox(width: 6),
            _miniStat('⚠️', '${player.penaltyCount}'),
            if (!hideCiftliToggle) ...[
              const SizedBox(width: 6),
              _buildCiftliToggle(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    final showTeamName = team.name.isNotEmpty && team.name != player.name;

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
        if (showTeamName) ...[
          const SizedBox(height: 1),
          Text(
            team.name,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _getScoreBgColor(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${player.totalScore}',
            style: TextStyle(
              color: _getScoreColor(),
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
            if (!hideCiftliToggle) ...[
              const SizedBox(width: 4),
              _buildCiftliToggle(small: true),
            ],
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

  Widget _buildCiftliToggle({bool small = false}) {
    final isActive = player.isCiftliGidiyor;
    return GestureDetector(
      onTap: onToggleCiftli,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 4 : 6,
          vertical: small ? 1 : 2,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentGold.withValues(alpha: 0.25)
              : AppTheme.surfaceCardLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive
                ? AppTheme.accentGold.withValues(alpha: 0.6)
                : AppTheme.textMuted.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          '×2',
          style: TextStyle(
            color: isActive ? AppTheme.accentGold : AppTheme.textMuted,
            fontSize: small ? 9 : 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
