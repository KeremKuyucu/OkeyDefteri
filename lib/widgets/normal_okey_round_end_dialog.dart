import 'package:flutter/material.dart';
import '../../models/game_models.dart';
import '../../theme/app_theme.dart';
import '../../services/localization_service.dart';

/// Normal Okey tur sonu bitirme dialogu
class NormalOkeyRoundEndDialog extends StatefulWidget {
  final Game game;
  final String? initialWinnerId;

  const NormalOkeyRoundEndDialog({
    super.key,
    required this.game,
    this.initialWinnerId,
  });

  @override
  State<NormalOkeyRoundEndDialog> createState() =>
      _NormalOkeyRoundEndDialogState();
}

class _NormalOkeyRoundEndDialogState extends State<NormalOkeyRoundEndDialog> {
  bool _noWinner = false;
  String? _winnerId;
  bool _isOkey = false;
  bool _isCift = false;

  @override
  void initState() {
    super.initState();
    _winnerId = widget.initialWinnerId;
  }

  int get _calculatedPoints {
    if (_isOkey && _isCift) {
      return 4; // Çift ve Okey: 2 > 4 katlanır
    } else if (_isOkey || _isCift) {
      return 2; // Okey atma: 2, Çift bitme: 2
    } else {
      return 1; // Normal bitiş: 1
    }
  }

  ScoreType get _calculatedType {
    if (_isOkey && _isCift) {
      return ScoreType.normalOkeyCiftVeOkeyBitti;
    } else if (_isOkey) {
      return ScoreType.normalOkeyAtarakBitti;
    } else if (_isCift) {
      return ScoreType.normalOkeyCiftBitti;
    } else {
      return ScoreType.normalOkeyBitti;
    }
  }

  bool get _canSave {
    if (_noWinner) return true;
    return _winnerId != null;
  }

  @override
  Widget build(BuildContext context) {
    final winner = _winnerId != null
        ? widget.game.allPlayers.firstWhere((p) => p.id == _winnerId)
        : null;

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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🎴', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Localization.t('normal_okey.title')} — ${Localization.t('game.round', args: [widget.game.currentRound])}',
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          Localization.t('game.end_game'),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 18),

              if (!_noWinner) ...[
                // Kim bitirdi?
                Text(
                  Localization.t('game.who_finished'),
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
                  children: widget.game.allPlayers.map((p) {
                    final isSelected = _winnerId == p.id;
                    return GestureDetector(
                      onTap: () => setState(() => _winnerId = p.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.goldGradient : null,
                          color: isSelected ? null : AppTheme.surfaceCardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accentGold
                                : AppTheme.textMuted.withValues(alpha: 0.25),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.accentGold.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Text(
                                  '🏆',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            Text(
                              p.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : AppTheme.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
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

                // Bitirme Şekli Seçenekleri
                if (_winnerId != null) ...[
                  Text(
                    Localization.t('normal_okey.finish_options'),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Okey Atma
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOkey = !_isOkey),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: _isOkey
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF9C27B0),
                                        Color(0xFF673AB7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _isOkey ? null : AppTheme.surfaceCardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isOkey
                                    ? const Color(0xFFBA68C8)
                                    : AppTheme.textMuted.withValues(
                                        alpha: 0.25,
                                      ),
                                width: _isOkey ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '🃏',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        Localization.t(
                                          'normal_okey.okey_finish',
                                        ),
                                        style: TextStyle(
                                          color: _isOkey
                                              ? Colors.white
                                              : AppTheme.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Çift Bitme
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isCift = !_isCift),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: _isCift
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF00897B),
                                        Color(0xFF004D40),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _isCift ? null : AppTheme.surfaceCardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCift
                                    ? const Color(0xFF4DB6AC)
                                    : AppTheme.textMuted.withValues(
                                        alpha: 0.25,
                                      ),
                                width: _isCift ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '👥',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        Localization.t(
                                          'normal_okey.cift_finish',
                                        ),
                                        style: TextStyle(
                                          color: _isCift
                                              ? Colors.white
                                              : AppTheme.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kazanılacak Puan Önizlemesi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: _isOkey && _isCift
                          ? LinearGradient(
                              colors: [
                                AppTheme.accentGold.withValues(alpha: 0.2),
                                const Color(0xFF9C27B0).withValues(alpha: 0.2),
                              ],
                            )
                          : null,
                      color: _isOkey && _isCift ? null : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isOkey && _isCift
                            ? AppTheme.accentGold
                            : AppTheme.lightGreen.withValues(alpha: 0.3),
                        width: _isOkey && _isCift ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '+$_calculatedPoints',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.t(
                                  'normal_okey.points_preview',
                                  args: [
                                    winner?.name ?? '',
                                    '+$_calculatedPoints',
                                  ],
                                ),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isOkey && _isCift
                                    ? Localization.t(
                                        'normal_okey.both_multiplier',
                                      )
                                    : _isOkey
                                    ? Localization.t('normal_okey.okey_finish')
                                    : _isCift
                                    ? Localization.t('normal_okey.cift_finish')
                                    : Localization.t('normal_okey.base_point'),
                                style: TextStyle(
                                  color: _isOkey && _isCift
                                      ? AppTheme.accentGold
                                      : AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: _isOkey && _isCift
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.warningOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          Localization.t('game.no_winner_desc_classic'),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave
                      ? () => Navigator.pop(context, {
                          'noWinner': _noWinner,
                          'winnerId': _winnerId,
                          'scoreType': _calculatedType,
                          'points': _calculatedPoints,
                        })
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
                    Localization.t('common.save'),
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
    );
  }
}
