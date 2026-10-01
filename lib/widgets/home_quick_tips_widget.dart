import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class HomeQuickTipsWidget extends StatelessWidget {
  const HomeQuickTipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentGold,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                Localization.t('home.quick_tips'),
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.touch_app_rounded,
            Localization.t('home.quick_tips_1'),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.undo_rounded, Localization.t('home.quick_tips_2')),
          const SizedBox(height: 12),
          _infoRow(
            Icons.calculate_rounded,
            Localization.t('home.quick_tips_3'),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.groups_rounded, Localization.t('home.quick_tips_4')),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
