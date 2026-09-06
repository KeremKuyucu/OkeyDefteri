import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/localization_service.dart';

/// Americano tur sonu puan giriş dialogu.
/// Kazanan seçilir, diğer oyuncular için kart değerleri ve cezalar girilir.
class AmericanoRoundScoreDialog extends StatefulWidget {
  final List<Player> players;
  final int roundNumber;

  const AmericanoRoundScoreDialog({
    super.key,
    required this.players,
    required this.roundNumber,
  });

  @override
  State<AmericanoRoundScoreDialog> createState() =>
      _AmericanoRoundScoreDialogState();
}

class _AmericanoRoundScoreDialogState
    extends State<AmericanoRoundScoreDialog> {
  bool _noWinner = false;
  String? _winnerId;
  final Map<String, TextEditingController> _cardControllers = {};
  final Map<String, bool> _islekFlags = {};
  final Map<String, bool> _hileFlags = {};
  final Map<String, bool> _takimYokOkeyAldiFlags = {};
  final Map<String, bool> _okeyAttiFlags = {};
  final Map<String, bool> _yanlisElActiFlags = {};
  final Map<String, bool> _islekAtarakBittiFlags = {};

  @override
  void initState() {
    super.initState();
    for (final p in widget.players) {
      _cardControllers[p.id] = TextEditingController();
      _islekFlags[p.id] = false;
      _hileFlags[p.id] = false;
      _takimYokOkeyAldiFlags[p.id] = false;
      _okeyAttiFlags[p.id] = false;
      _yanlisElActiFlags[p.id] = false;
      _islekAtarakBittiFlags[p.id] = false;
    }
  }

  @override
  void dispose() {
    for (final c in _cardControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<MapEntry<String, List<ScoreEntry>>> _buildResults() {
    final now = DateTime.now();
    final results = <MapEntry<String, List<ScoreEntry>>>[];

    for (final p in widget.players) {
      final entries = <ScoreEntry>[];

      if (!_noWinner && p.id == _winnerId) {
        entries.add(ScoreEntry(
          id: '${now.millisecondsSinceEpoch}_${p.id}_win',
          type: ScoreType.americanoKazandi,
          points: -50,
          timestamp: now,
          roundNumber: widget.roundNumber,
        ));
      } else {
        final raw = int.tryParse(_cardControllers[p.id]?.text ?? '') ?? 0;
        if (raw > 0) {
          entries.add(ScoreEntry(
            id: '${now.millisecondsSinceEpoch}_${p.id}_cards',
            type: ScoreType.americanoEldeKalan,
            points: raw,
            timestamp: now,
            roundNumber: widget.roundNumber,
          ));
        }
      }

      if (_islekFlags[p.id] == true) {
        entries.add(ScoreEntry(
          id: '${now.millisecondsSinceEpoch}_${p.id}_islek',
          type: ScoreType.americanoIslek,
          points: 50,
          timestamp: now,
          roundNumber: widget.roundNumber,
        ));
      }
      if (_hileFlags[p.id] == true) {
        entries.add(ScoreEntry(
          id: '${now.millisecondsSinceEpoch}_${p.id}_hile',
          type: ScoreType.americanoHile,
          points: 50,
          timestamp: now,
          roundNumber: widget.roundNumber,
        ));
      }
      if (_takimYokOkeyAldiFlags[p.id] == true) {
        entries.add(ScoreEntry(
          id: '${now.millisecondsSinceEpoch}_${p.id}_takim_yok',
          type: ScoreType.americanoTakimYokOkeyAldi,
          points: 50,
          timestamp: now,
          roundNumber: widget.roundNumber,
        ));
      }
      if (_okeyAttiFlags[p.id] == true) {
        entries.add(ScoreEntry(
          id: '${now.millisecondsSinceEpoch}_${p.id}_okey_atti',
          type: ScoreType.americanoOkeyAtti,
          points: 50,
          timestamp: now,
          roundNumber: widget.roundNumber,
        ));
      }
      if (_yanlisElActiFlags[p.id] == true) {
        entries.add(ScoreEntry(
          id: '${now.millisecondsSinceEpoch}_${p.id}_yanlis_el',
          type: ScoreType.americanoYanlisElActi,
          points: 50,
          timestamp: now,
          roundNumber: widget.roundNumber,
        ));
      }
      if (_islekAtarakBittiFlags[p.id] == true) {
        entries.add(ScoreEntry(
          id: '${now.millisecondsSinceEpoch}_${p.id}_islek_atarak',
          type: ScoreType.americanoIslekAtarakBitti,
          points: 100,
          timestamp: now,
          roundNumber: widget.roundNumber,
        ));
      }

      results.add(MapEntry(p.id, entries));
    }
    return results;
  }

  bool get _canSave {
    if (_noWinner) return true;
    if (_winnerId == null) return false;
    for (final p in widget.players) {
      if (p.id == _winnerId) continue;
      final text = _cardControllers[p.id]?.text ?? '';
      if (text.isEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 620),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🏆', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Localization.t('americano.round_end_title',
                                args: [widget.roundNumber]),
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${Localization.t('americano.round_rule')}: '
                            '${AmericanoRound.forRound(widget.roundNumber)?.title ?? ''}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                                    color: !_noWinner ? Colors.black : AppTheme.textMuted,
                                    fontWeight: !_noWinner ? FontWeight.w800 : FontWeight.w600,
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
                                      color: AppTheme.warningOrange.withValues(alpha: 0.6),
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
                                    color: _noWinner ? AppTheme.warningOrange : AppTheme.textMuted,
                                    fontWeight: _noWinner ? FontWeight.w800 : FontWeight.w600,
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
                  // Kazananı seç
                  Text(
                    Localization.t('americano.who_finished'),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.players.map((p) {
                      final isSelected = _winnerId == p.id;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _winnerId = p.id;
                          _cardControllers[p.id]?.clear();
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppTheme.goldGradient : null,
                            color: isSelected ? null : AppTheme.surfaceCardLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accentGold
                                  : AppTheme.textMuted.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Text('🏆',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              Text(
                                p.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : AppTheme.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                const Divider(color: AppTheme.surfaceCardLight),
                const SizedBox(height: 12),

                Text(
                  Localization.t('americano.remaining_cards'),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Joker = 50 puan',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 12),

                ...widget.players.map((p) => _buildPlayerRow(p)),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSave
                        ? () => Navigator.pop(context, _buildResults())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSave
                          ? AppTheme.lightGreen
                          : AppTheme.surfaceCardLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      Localization.t('americano.save_round'),
                      style: TextStyle(
                        color: _canSave ? Colors.white : AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow(Player player) {
    final isWinner = !_noWinner && _winnerId == player.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWinner
              ? AppTheme.accentGold.withValues(alpha: 0.08)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isWinner
                ? AppTheme.accentGold.withValues(alpha: 0.3)
                : AppTheme.surfaceCardLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isWinner ? '🏆 ' : '🃏 ',
                  style: const TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    player.name,
                    style: TextStyle(
                      color: isWinner
                          ? AppTheme.accentGold
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${player.totalScore} puan',
                  style: TextStyle(
                    color: player.totalScore > 200
                        ? AppTheme.dangerRed
                        : AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (!isWinner) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _cardControllers[player.id],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style:
                    const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: Localization.t('americano.remaining_cards_hint'),
                  labelStyle:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppTheme.surfaceCardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppTheme.lightGreen, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  suffixText: 'puan',
                  suffixStyle: const TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _penaltyChip(
                  label: Localization.t('americano.islek'),
                  emoji: '🎯',
                  isSelected: _islekFlags[player.id] ?? false,
                  onTap: () => setState(() =>
                      _islekFlags[player.id] =
                          !(_islekFlags[player.id] ?? false)),
                ),
                _penaltyChip(
                  label: Localization.t('americano.hile'),
                  emoji: '🚫',
                  isSelected: _hileFlags[player.id] ?? false,
                  onTap: () => setState(() =>
                      _hileFlags[player.id] =
                          !(_hileFlags[player.id] ?? false)),
                ),
                _penaltyChip(
                  label: Localization.t('americano.takim_yok_okey_aldi'),
                  emoji: '🃏⚠️',
                  isSelected: _takimYokOkeyAldiFlags[player.id] ?? false,
                  onTap: () => setState(() =>
                      _takimYokOkeyAldiFlags[player.id] =
                          !(_takimYokOkeyAldiFlags[player.id] ?? false)),
                ),
                _penaltyChip(
                  label: Localization.t('americano.okey_atti'),
                  emoji: '🃏❌',
                  isSelected: _okeyAttiFlags[player.id] ?? false,
                  onTap: () => setState(() =>
                      _okeyAttiFlags[player.id] =
                          !(_okeyAttiFlags[player.id] ?? false)),
                ),
                _penaltyChip(
                  label: Localization.t('americano.yanlis_el_acti'),
                  emoji: '❌',
                  isSelected: _yanlisElActiFlags[player.id] ?? false,
                  onTap: () => setState(() =>
                      _yanlisElActiFlags[player.id] =
                          !(_yanlisElActiFlags[player.id] ?? false)),
                ),
                _penaltyChip(
                  label: Localization.t('americano.islek_atarak_bitti'),
                  emoji: '🎯🏁',
                  isSelected: _islekAtarakBittiFlags[player.id] ?? false,
                  onTap: () => setState(() =>
                      _islekAtarakBittiFlags[player.id] =
                          !(_islekAtarakBittiFlags[player.id] ?? false)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _penaltyChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.dangerRed.withValues(alpha: 0.2)
              : AppTheme.surfaceCardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.dangerRed.withValues(alpha: 0.6)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.dangerRed : AppTheme.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
