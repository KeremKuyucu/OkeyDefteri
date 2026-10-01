import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class AmericanoPenaltyDialog extends StatefulWidget {
  final Player player;

  const AmericanoPenaltyDialog({
    super.key,
    required this.player,
  });

  static Future<Map<String, bool>?> show(
    BuildContext context, {
    required Player player,
  }) {
    return showDialog<Map<String, bool>>(
      context: context,
      builder: (ctx) => AmericanoPenaltyDialog(player: player),
    );
  }

  @override
  State<AmericanoPenaltyDialog> createState() => _AmericanoPenaltyDialogState();
}

class _AmericanoPenaltyDialogState extends State<AmericanoPenaltyDialog> {
  bool islek = false;
  bool hile = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.player.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            value: islek,
            onChanged: (v) => setState(() => islek = v ?? false),
            title: Text(
              Localization.t('americano.islek'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            activeColor: AppTheme.dangerRed,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: hile,
            onChanged: (v) => setState(() => hile = v ?? false),
            title: Text(
              Localization.t('americano.hile'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            activeColor: AppTheme.dangerRed,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            Localization.t('common.cancel'),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {'islek': islek, 'hile': hile}),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.dangerRed,
          ),
          child: Text(Localization.t('common.save')),
        ),
      ],
    );
  }
}
