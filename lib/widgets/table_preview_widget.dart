import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class TablePreviewWidget extends StatelessWidget {
  final String player1Name;
  final String player2Name;
  final String player3Name;
  final String player4Name;

  const TablePreviewWidget({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.player3Name,
    required this.player4Name,
  });

  @override
  Widget build(BuildContext context) {
    final p1 = player1Name.isEmpty
        ? Localization.t('new_game.player_1')
        : player1Name;
    final p2 = player2Name.isEmpty
        ? Localization.t('new_game.player_2')
        : player2Name;
    final p3 = player3Name.isEmpty
        ? Localization.t('new_game.player_3')
        : player3Name;
    final p4 = player4Name.isEmpty
        ? Localization.t('new_game.player_4')
        : player4Name;

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.15)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Masa
          Container(
            width: 125,
            height: 125,
            decoration: BoxDecoration(
              gradient: AppTheme.tableGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('🎴', style: TextStyle(fontSize: 28)),
            ),
          ),
          // Üst (Takım 1, Oyuncu 1)
          Positioned(top: 0, child: _miniPlayer(p1, AppTheme.lightGreen)),
          // Sağ (Takım 2, Oyuncu 1)
          Positioned(right: 0, child: _miniPlayer(p2, AppTheme.accentAmber)),
          // Alt (Takım 1, Oyuncu 2)
          Positioned(bottom: 0, child: _miniPlayer(p3, AppTheme.lightGreen)),
          // Sol (Takım 2, Oyuncu 2)
          Positioned(left: 0, child: _miniPlayer(p4, AppTheme.accentAmber)),
        ],
      ),
    );
  }

  Widget _miniPlayer(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        name.length > 8 ? '${name.substring(0, 8)}...' : name,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
