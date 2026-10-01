import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class QuickPlayerChips extends StatelessWidget {
  final List<String> knownPlayers;
  final bool Function(String) isPlayerSelected;
  final ValueChanged<String> onPlayerTapped;

  const QuickPlayerChips({
    super.key,
    required this.knownPlayers,
    required this.isPlayerSelected,
    required this.onPlayerTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (knownPlayers.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_outline_rounded,
                color: AppTheme.accentGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                Localization.t('new_game.quick_select_players'),
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: knownPlayers.map((name) {
              final isUsed = isPlayerSelected(name);

              return ActionChip(
                backgroundColor: isUsed
                    ? AppTheme.accentGold.withValues(alpha: 0.2)
                    : AppTheme.surfaceCardLight,
                side: BorderSide(
                  color: isUsed
                      ? AppTheme.accentGold
                      : AppTheme.textMuted.withValues(alpha: 0.2),
                ),
                avatar: isUsed
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppTheme.accentGold,
                      )
                    : null,
                label: Text(
                  name,
                  style: TextStyle(
                    color: isUsed ? AppTheme.accentGold : AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: isUsed ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                onPressed: () => onPlayerTapped(name),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
