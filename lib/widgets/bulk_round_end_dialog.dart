import 'package:flutter/material.dart';
import '../../models/game_models.dart';
import '../../theme/app_theme.dart';
import '../../services/localization_service.dart';

/// Toplu tur sonu puan giriş dialogu
class BulkRoundEndDialog extends StatefulWidget {
  final Game game;

  const BulkRoundEndDialog({super.key, required this.game});

  @override
  State<BulkRoundEndDialog> createState() => _BulkRoundEndDialogState();
}

class _BulkRoundEndDialogState extends State<BulkRoundEndDialog> {
  bool _noWinner = false;
  String? _winnerId;
  ScoreType _finishType = ScoreType.normalBitti;
  final Map<String, TextEditingController> _controllers = {};

  static const _finishTypes = [
    ScoreType.normalBitti,
    ScoreType.eldenBitti,
    ScoreType.okeyAtarakBitti,
    ScoreType.okeyAtarakEldenBitti,
  ];

  static const _finishColors = {
    ScoreType.normalBitti: Color(0xFF4CAF50),
    ScoreType.eldenBitti: Color(0xFF42A5F5),
    ScoreType.okeyAtarakBitti: Color(0xFF7E57C2),
    ScoreType.okeyAtarakEldenBitti: Color(0xFFFF7043),
  };

  @override
  void initState() {
    super.initState();
    for (final p in widget.game.allPlayers) {
      _controllers[p.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isTeammateOfWinner(Player p) {
    if (_noWinner || _winnerId == null) return false;
    if (_winnerId == p.id) return false;
    final winner = widget.game.allPlayers.firstWhere(
      (pl) => pl.id == _winnerId,
    );
    final winnerTeam = widget.game.getTeamForPlayer(winner);
    return winnerTeam.player1.id == p.id || winnerTeam.player2.id == p.id;
  }

  bool get _canSave {
    if (_noWinner) {
      return true;
    }
    if (_winnerId == null) return false;
    for (final p in widget.game.allPlayers) {
      if (p.id == _winnerId) continue;
      if (_isTeammateOfWinner(p)) continue;
      final text = _controllers[p.id]?.text ?? '';
      if (text.isEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _noWinner
        ? AppTheme.warningOrange
        : (_finishColors[_finishType] ?? AppTheme.successGreen);

    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 650),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  const Text('🎴', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${Localization.t('game.round', args: [widget.game.currentRound])} — ${Localization.t('game.end_game')}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Biri Bitirdi / Kimse Bitmedi Seçim Tab'i
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightGreen.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _noWinner = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: !_noWinner ? AppTheme.goldGradient : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                Localization.t('game.round_winner_mode'),
                                style: TextStyle(
                                  color: !_noWinner
                                      ? Colors.black
                                      : AppTheme.textMuted,
                                  fontWeight: !_noWinner
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _noWinner = true;
                          _winnerId = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _noWinner
                                ? AppTheme.warningOrange.withValues(alpha: 0.25)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: _noWinner
                                ? Border.all(
                                    color: AppTheme.warningOrange.withValues(
                                      alpha: 0.6,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🛑', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                Localization.t('game.round_no_winner_mode'),
                                style: TextStyle(
                                  color: _noWinner
                                      ? AppTheme.warningOrange
                                      : AppTheme.textMuted,
                                  fontWeight: _noWinner
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (!_noWinner) ...[
                // Bitirme Türü Seçimi
                Text(
                  Localization.t('game.how_finished'),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _finishTypes.map((type) {
                    final selected = _finishType == type;
                    final color = _finishColors[type] ?? AppTheme.successGreen;
                    final points = widget.game.rules.getPointsFor(type);
                    return GestureDetector(
                      onTap: () => setState(() => _finishType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.25)
                              : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? color
                                : AppTheme.lightGreen.withValues(alpha: 0.2),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              type.label,
                              style: TextStyle(
                                color: selected ? color : AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$points',
                              style: TextStyle(
                                color: selected
                                    ? color.withValues(alpha: 0.8)
                                    : AppTheme.textMuted,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Kazanan Seçimi
                Text(
                  Localization.t('game.who_finished'),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                // Kimse Bitmedi Bilgilendirmesi
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.warningOrange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.warningOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          Localization.t('game.no_winner_desc'),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Oyuncular Listesi
              ...widget.game.allPlayers.map((p) {
                final isWinner = !_noWinner && _winnerId == p.id;
                final isTeammate = !_noWinner && _isTeammateOfWinner(p);
                final color = _noWinner
                    ? AppTheme.warningOrange
                    : (_finishColors[_finishType] ?? AppTheme.successGreen);
                final finishPoints = widget.game.rules.getPointsFor(_finishType);
                final cantOpenPoints = widget.game.rules.cantOpenPoints;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isWinner
                        ? color.withValues(alpha: 0.15)
                        : AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: !_noWinner
                          ? () => setState(() => _winnerId = p.id)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: isWinner
                                    ? AppTheme.goldGradient
                                    : null,
                                color: isWinner
                                    ? null
                                    : AppTheme.surfaceCardLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: isWinner
                                    ? const Icon(
                                        Icons.emoji_events,
                                        color: Colors.black,
                                        size: 18,
                                      )
                                    : Text(
                                        p.name.isNotEmpty
                                            ? p.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      p.name,
                                      style: TextStyle(
                                        color: isWinner
                                            ? color
                                            : AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (p.isCiftliGidiyor) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGold.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppTheme.accentGold.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '2x',
                                        style: TextStyle(
                                          color: AppTheme.accentGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (isTeammate) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightGreen.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppTheme.lightGreen.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        Localization.t('game.teammate_badge'),
                                        style: const TextStyle(
                                          color: AppTheme.lightGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isWinner)
                              Text(
                                '$finishPoints',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            if (!isWinner)
                              if (isTeammate)
                                Container(
                                  width: 70,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightGreen.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.lightGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        color: AppTheme.lightGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                              else ...[
                                // Hızlı Açamadı butonu
                                if (_noWinner)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _controllers[p.id]?.text = '$cantOpenPoints';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.dangerRed.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.dangerRed
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          '$cantOpenPoints',
                                          style: const TextStyle(
                                            color: AppTheme.dangerRed,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  width: 70,
                                  child: TextField(
                                    controller: _controllers[p.id],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: const TextStyle(
                                        color: AppTheme.textMuted,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                      filled: true,
                                      fillColor: AppTheme.surfaceCardLight,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _canSave
                      ? () {
                          if (_noWinner) {
                            final scores = <String, int>{};
                            for (final p in widget.game.allPlayers) {
                              scores[p.id] =
                                  int.tryParse(
                                    _controllers[p.id]?.text ?? '',
                                  ) ??
                                  0;
                            }
                            Navigator.pop(context, {
                              'noWinner': true,
                              'scores': scores,
                            });
                          } else {
                            final scores = <String, int>{};
                            for (final p in widget.game.allPlayers) {
                              if (p.id == _winnerId) continue;
                              if (_isTeammateOfWinner(p)) {
                                scores[p.id] = 0;
                              } else {
                                scores[p.id] =
                                    int.tryParse(
                                      _controllers[p.id]?.text ?? '',
                                    ) ??
                                    0;
                              }
                            }
                            Navigator.pop(context, {
                              'noWinner': false,
                              'winnerId': _winnerId,
                              'finishType': _finishType,
                              'scores': scores,
                            });
                          }
                        }
                      : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    Localization.t('common.save'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.surfaceCard,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
