import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

/// Masa Muhabbeti / Canlı Spiker Bandı
/// Oyuncuların o anki durumlarına göre üretilen esprili / hicivli
/// replikleri kartları şişirmeden, şık bir bantta gösterir.
/// - Sağa / sola kaydırarak oyuncular arasında geçiş yapılır.
/// - Tıklandığında tam repliği gösteren popup açılır.
class TableBanterBar extends StatefulWidget {
  final List<Player> players;
  final int roundNumber;
  final String? spotlightPlayerId;

  const TableBanterBar({
    super.key,
    required this.players,
    required this.roundNumber,
    this.spotlightPlayerId,
  });

  @override
  State<TableBanterBar> createState() => _TableBanterBarState();
}

class _TableBanterBarState extends State<TableBanterBar> {
  int _currentIndex = 0;
  double _slideDirection = 1.0;

  @override
  void initState() {
    super.initState();
    _pickSpotlightPlayer();
  }

  @override
  void didUpdateWidget(covariant TableBanterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roundNumber != widget.roundNumber ||
        oldWidget.spotlightPlayerId != widget.spotlightPlayerId) {
      _pickSpotlightPlayer();
    }
  }

  void _pickSpotlightPlayer() {
    if (widget.players.isEmpty) return;

    if (widget.spotlightPlayerId != null) {
      final idx =
          widget.players.indexWhere((p) => p.id == widget.spotlightPlayerId);
      if (idx != -1) {
        setState(() => _currentIndex = idx);
        return;
      }
    }

    int bestIdx = 0;
    if (widget.roundNumber > 1) {
      for (int i = 0; i < widget.players.length; i++) {
        final p = widget.players[i];
        if (p.scores.any((s) =>
            s.roundNumber == widget.roundNumber - 1 && s.type.isFinishType)) {
          bestIdx = i;
          break;
        }
      }
    } else {
      bestIdx = widget.roundNumber % widget.players.length;
    }

    setState(() => _currentIndex = bestIdx.clamp(0, widget.players.length - 1));
  }

  void _cycleNext() {
    if (widget.players.isEmpty) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrate();
    setState(() {
      _slideDirection = 1.0;
      _currentIndex = (_currentIndex + 1) % widget.players.length;
    });
  }

  void _cyclePrev() {
    if (widget.players.isEmpty) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrate();
    setState(() {
      _slideDirection = -1.0;
      _currentIndex =
          (_currentIndex - 1 + widget.players.length) % widget.players.length;
    });
  }

  void _showBanterPopup(BuildContext context) {
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrate();

    showDialog(
      context: context,
      builder: (ctx) => _BanterDialog(
        players: widget.players,
        roundNumber: widget.roundNumber,
        initialIndex: _currentIndex,
        onIndexChanged: (newIdx) {
          setState(() => _currentIndex = newIdx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!SettingsService.getToxicNicknamesEnabled()) {
      return const SizedBox.shrink();
    }
    if (widget.players.isEmpty) return const SizedBox.shrink();

    final safeIndex = _currentIndex.clamp(0, widget.players.length - 1);
    final player = widget.players[safeIndex];
    final quote = player.getNickname(widget.players, widget.roundNumber);

    if (quote.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () => _showBanterPopup(context),
        onHorizontalDragEnd: (details) {
          final vx = details.primaryVelocity ?? 0;
          if (vx < -100) {
            _cycleNext(); // Sola kaydırınca sonraki oyuncu
          } else if (vx > 100) {
            _cyclePrev(); // Sağa kaydırınca önceki oyuncu
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.06 * _slideDirection, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Row(
              key: ValueKey<String>(
                  '${player.id}_${widget.roundNumber}_$quote'),
              children: [
                // Spiker / mikrofon ikonu
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCardLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Text('🎙️', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),

                // Oyuncu adı
                Text(
                  player.name,
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  ': ',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Kırpılan Replik
                Expanded(
                  child: Text(
                    quote,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 6),
                // Büyüt / Detay ipucu ikonu
                Icon(
                  Icons.open_in_full_rounded,
                  size: 13,
                  color: AppTheme.accentGold.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tam repliği gösteren ve sağa/sola kaydırarak diğer oyunculara geçilebilen popup dialog
class _BanterDialog extends StatefulWidget {
  final List<Player> players;
  final int roundNumber;
  final int initialIndex;
  final ValueChanged<int> onIndexChanged;

  const _BanterDialog({
    required this.players,
    required this.roundNumber,
    required this.initialIndex,
    required this.onIndexChanged,
  });

  @override
  State<_BanterDialog> createState() => _BanterDialogState();
}

class _BanterDialogState extends State<_BanterDialog> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (page < 0 || page >= widget.players.length) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrate();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppTheme.accentGold.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık ve Kapat Butonu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCardLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text('🎙️', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    Localization.t('game.table_banter'),
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppTheme.textMuted, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Kaydırılabilir Sayfalar (PageView)
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.players.length,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  widget.onIndexChanged(page);
                },
                itemBuilder: (context, index) {
                  final player = widget.players[index];
                  final quote =
                      player.getNickname(widget.players, widget.roundNumber);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Oyuncu avatarı ve ismi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                player.name.isNotEmpty
                                    ? player.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            player.name,
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tam Replik Balonu
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.lightGreen.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Text(
                                quote.isNotEmpty ? quote : '...',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Alt Navigasyon: Önceki, Sayfa Noktaları, Sonraki
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                  color: _currentPage > 0
                      ? AppTheme.accentGold
                      : AppTheme.textMuted.withValues(alpha: 0.3),
                  onPressed:
                      _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
                ),

                // Nokta göstergeleri (Dots)
                Row(
                  children: List.generate(widget.players.length, (idx) {
                    final isCurrent = idx == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCurrent ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.accentGold
                            : AppTheme.surfaceCardLight,
                        borderRadius: BorderRadius.circular(4),
                        border: isCurrent
                            ? null
                            : Border.all(
                                color:
                                    AppTheme.textMuted.withValues(alpha: 0.4),
                              ),
                      ),
                    );
                  }),
                ),

                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  color: _currentPage < widget.players.length - 1
                      ? AppTheme.accentGold
                      : AppTheme.textMuted.withValues(alpha: 0.3),
                  onPressed: _currentPage < widget.players.length - 1
                      ? () => _goTo(_currentPage + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
