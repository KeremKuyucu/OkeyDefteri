import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class TeamFormCard extends StatelessWidget {
  final TextEditingController teamController;
  final String player1Label;
  final String player2Label;
  final TextEditingController player1Controller;
  final TextEditingController player2Controller;
  final Color color;

  const TeamFormCard({
    super.key,
    required this.teamController,
    required this.player1Label,
    required this.player2Label,
    required this.player1Controller,
    required this.player2Controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Takım ismi
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.groups_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: teamController,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: Localization.t('new_game.team_name'),
                    labelStyle: TextStyle(color: color.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: AppTheme.surfaceCardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Oyuncu 1
          TextField(
            controller: player1Controller,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              labelText: player1Label,
              prefixIcon: Icon(
                Icons.person,
                color: color.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppTheme.surfaceCardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Oyuncu 2
          TextField(
            controller: player2Controller,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              labelText: player2Label,
              prefixIcon: Icon(
                Icons.person,
                color: color.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppTheme.surfaceCardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
