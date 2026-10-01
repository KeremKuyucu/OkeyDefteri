import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class GameModeSelector extends StatelessWidget {
  final GameMode selectedMode;
  final ValueChanged<GameMode> onModeChanged;

  const GameModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isAmericanoSelected = selectedMode == GameMode.americano ||
        selectedMode == GameMode.americanoSolo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.t('americano.select_mode'),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _modeChip(GameMode.okey101)),
            const SizedBox(width: 8),
            Expanded(child: _modeChip(GameMode.normalOkey)),
          ],
        ),
        const SizedBox(height: 8),
        _modeChip(GameMode.americano),
        // Americano alt seçeneği: Takımlı vs Tekli
        if (isAmericanoSelected) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localization.t('new_game.americano_mode'),
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _americanoSubChip(
                        mode: GameMode.americano,
                        label: Localization.t('new_game.mode_team'),
                        emoji: '🤝',
                        desc: Localization.t('new_game.mode_team_desc'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _americanoSubChip(
                        mode: GameMode.americanoSolo,
                        label: Localization.t('new_game.mode_solo'),
                        emoji: '👤',
                        desc: Localization.t('new_game.mode_solo_desc'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _americanoSubChip({
    required GameMode mode,
    required String label,
    required String emoji,
    required String desc,
  }) {
    final isSelected = selectedMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGold.withValues(alpha: 0.15)
              : AppTheme.surfaceCardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGold
                : AppTheme.surfaceCardLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accentGold
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: AppTheme.accentGold,
              ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(GameMode mode) {
    // Americano chip: hem americano hem americanoSolo seçildiğinde "aktif" görünsün
    final isSelected = selectedMode == mode ||
        (mode == GameMode.americano &&
            (selectedMode == GameMode.americano ||
                selectedMode == GameMode.americanoSolo));
    final isAmericano = mode == GameMode.americano;
    final isNormalOkey = mode == GameMode.normalOkey;

    final String label;
    final String emoji;
    final String desc;

    if (isAmericano) {
      label = Localization.t('americano.mode_name');
      emoji = '🃏';
      desc = Localization.t('new_game.desc_americano');
    } else if (isNormalOkey) {
      label = Localization.t('normal_okey.mode_name');
      emoji = '🎴';
      desc = Localization.t('new_game.desc_normal_okey');
    } else {
      label = Localization.t('americano.mode_101');
      emoji = '🀄';
      desc = Localization.t('new_game.desc_101');
    }

    return GestureDetector(
      onTap: () {
        if (isAmericano) {
          // Americano seçilince varsayılan takımlı mod
          onModeChanged(GameMode.americano);
        } else {
          onModeChanged(mode);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (isAmericano ? AppTheme.goldGradient : null)
              : null,
          color: isSelected && !isAmericano
              ? (isNormalOkey
                  ? AppTheme.accentGold.withValues(alpha: 0.15)
                  : AppTheme.lightGreen.withValues(alpha: 0.15))
              : isSelected
              ? null
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isAmericano
                    ? AppTheme.accentGold
                    : isNormalOkey
                        ? AppTheme.accentGold
                        : AppTheme.lightGreen)
                : AppTheme.surfaceCardLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isAmericano || isNormalOkey
                            ? AppTheme.accentGold
                            : AppTheme.lightGreen)
                        .withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? (isAmericano
                              ? Colors.black
                              : isNormalOkey
                                  ? AppTheme.accentGold
                                  : AppTheme.lightGreen)
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isSelected
                          ? (isAmericano
                              ? Colors.black54
                              : AppTheme.textMuted)
                          : AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: isAmericano
                    ? Colors.black54
                    : isNormalOkey
                        ? AppTheme.accentGold
                        : AppTheme.lightGreen,
              ),
          ],
        ),
      ),
    );
  }
}
