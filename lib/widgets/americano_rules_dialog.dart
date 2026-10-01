import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class AmericanoRulesDialog extends StatelessWidget {
  final int? currentRound;

  const AmericanoRulesDialog({
    super.key,
    this.currentRound,
  });

  static void show(BuildContext context, {int? currentRound}) {
    showDialog(
      context: context,
      builder: (ctx) => AmericanoRulesDialog(currentRound: currentRound),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Text('🃏', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            Localization.t('americano.game_rules'),
            style: const TextStyle(color: AppTheme.accentGold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.t('americano.rules_text'),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.surfaceCardLight),
            const SizedBox(height: 12),
            ...AmericanoRound.rounds.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: currentRound == r.roundNumber
                              ? AppTheme.accentGold
                              : AppTheme.surfaceCardLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${r.roundNumber}',
                          style: TextStyle(
                            color: currentRound == r.roundNumber
                                ? Colors.black
                                : AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r.title,
                          style: TextStyle(
                            color: currentRound == r.roundNumber
                                ? AppTheme.textPrimary
                                : AppTheme.textMuted,
                            fontSize: 13,
                            fontWeight: currentRound == r.roundNumber
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightGreen,
          ),
          child: Text(Localization.t('common.close')),
        ),
      ],
    );
  }
}
