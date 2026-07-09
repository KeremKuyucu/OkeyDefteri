import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/player_card.dart';
import '../widgets/team_score_bar.dart';
import '../widgets/score_input_dialog.dart';
import 'score_history_screen.dart';
import 'stats_screen.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Game _game;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveGame() async {
    await StorageService.saveActiveGame(_game);
  }

  /// Mevcut turda bitirme veya elde kalan ceza puanı var mı?
  bool _hasTurnEndingScoreInCurrentRound() {
    for (final p in _game.allPlayers) {
      final hasEnd = p.scores.any(
        (s) =>
            s.roundNumber == _game.currentRound &&
            (s.type.isFinishType || s.type == ScoreType.eldeKalanTaslar),
      );
      if (hasEnd) return true;
    }
    return false;
  }

  Future<void> _openScoreDialog(Player player) async {
    if (_game.isFinished) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Localization.t('game.finished'))));
      return;
    }

    // Turu geçmeyi unuttun mu kontrolü
    if (_hasTurnEndingScoreInCurrentRound()) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.accentGold, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Localization.t('game.forgot_round_title'),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            Localization.t('game.forgot_round_message'),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                Localization.t('common.cancel'),
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
              ),
              child: Text(Localization.t('game.forgot_round_continue')),
            ),
          ],
        ),
      );
      if (shouldContinue != true) return;
    }

    if (!mounted) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrate();
    final result = await showDialog<ScoreEntry>(
      context: context,
      builder: (context) => ScoreInputDialog(
        player: player,
        currentRound: _game.currentRound,
        allPlayers: _game.allPlayers,
      ),
    );

    if (result != null) {
      setState(() {
        player.scores.add(result);
      });
      await _saveGame();
    }
  }

  void _undoLastScore(Player player) {
    if (_game.isFinished) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Localization.t('game.finished'))));
      return;
    }
    if (player.scores.isEmpty) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrateHeavy();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Son Puanı Geri Al',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          Localization.t(
            'game.process_cancel',
            args: [player.name, _game.currentRound],
          ),
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                player.scores.removeLast();
              });
              _saveGame();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Geri Al'),
          ),
        ],
      ),
    );
  }

  void _toggleCiftli(Player player) {
    if (_game.isFinished) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrate();
    setState(() {
      player.isCiftliGidiyor = !player.isCiftliGidiyor;
    });
    _saveGame();
  }

  void _nextRound() {
    if (_game.isFinished) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrateHeavy();
    setState(() {
      _game.currentRound++;
      for (final p in _game.allPlayers) {
        p.isCiftliGidiyor = false;
      }
    });
    _saveGame();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localization.t('game.tour_start_info', args: [_game.currentRound]),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.lightGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _prevRound() {
    if (_game.isFinished) return;
    if (_game.currentRound <= 1) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrateHeavy();

    final prevRound = _game.currentRound - 1;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Localization.t('game.prev_round_confirm_title'),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          Localization.t('game.prev_round_confirm', args: [prevRound]),
          style: const TextStyle(color: AppTheme.textSecondary),
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
            onPressed: () {
              setState(() {
                // Mevcut turdaki tüm puanları sil
                for (final p in _game.allPlayers) {
                  p.scores.removeWhere(
                    (s) => s.roundNumber == _game.currentRound,
                  );
                  p.isCiftliGidiyor = false;
                }
                _game.currentRound = prevRound;
              });
              _saveGame();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    Localization.t('game.round', args: [_game.currentRound]),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppTheme.dangerRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: Text(Localization.t('game.prev_round_undo')),
          ),
        ],
      ),
    );
  }

  void _endGame() {
    if (_game.isFinished) return;
    AudioVibrationService.playClickSound();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Localization.t('game.end_game'),
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          Localization.t('game.end_game_confirm'),
          style: TextStyle(color: AppTheme.textSecondary),
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
            onPressed: () {
              setState(() {
                _game.isFinished = true;
                _game.endedAt = DateTime.now();
              });
              _saveGame();
              StorageService.clearActiveGame();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: Text(Localization.t('common.yes')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Üst bar
            _buildTopBar(),
            const SizedBox(height: 8),

            // Takım skorları
            TeamScoreBar(team1: _game.team1, team2: _game.team2),
            const SizedBox(height: 8),

            // Oyun masası
            Expanded(child: _buildGameTable()),

            // TODO: Banner reklam buraya eklenecek
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: const Text('Banner Ad Placeholder', style: TextStyle(color: Colors.transparent)),
            ),

            // Alt bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  Localization.t('game.title'),
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  Localization.t('game.round', args: [_game.currentRound]),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            itemBuilder: (context) => [
              _popupItem(
                'history',
                Icons.history,
                Localization.t('game.history'),
              ),
              _popupItem(
                'stats',
                Icons.analytics,
                Localization.t('game.stats'),
              ),
              if (!_game.isFinished)
                _popupItem('end', Icons.flag, Localization.t('game.end_game')),
            ],
            onSelected: (value) {
              switch (value) {
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoreHistoryScreen(game: _game),
                    ),
                  );
                  break;
                case 'stats':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatsScreen(game: _game),
                    ),
                  );
                  break;
                case 'end':
                  _endGame();
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _popupItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildGameTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tüm oyuncuların yeşil masaya tam olarak eşit uzaklıkta olmasını sağlamak
        // ve taşmaları önlemek için Column/Row ve FittedBox tabanlı bir düzen kullanıyoruz.
        final tableSize = constraints.maxWidth * 0.42;
        const double gap = 12.0;

        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üst oyuncu (seat 0) - Takım 1 Oyuncu 1
                  GestureDetector(
                    onLongPress: () => _undoLastScore(_game.team1.player1),
                    child: PlayerCard(
                      player: _game.team1.player1,
                      team: _game.team1,
                      position: 0,
                      nickname: _game.team1.player1.getNickname(
                        _game.allPlayers,
                        _game.currentRound,
                      ),
                      onTap: () => _openScoreDialog(_game.team1.player1),
                      onToggleCiftli: () => _toggleCiftli(_game.team1.player1),
                    ),
                  ),

                  const SizedBox(height: gap),

                  // Orta Satır (Sol Oyuncu - Masa - Sağ Oyuncu)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sol oyuncu (seat 3) - Takım 2 Oyuncu 2
                      GestureDetector(
                        onLongPress: () => _undoLastScore(_game.team2.player2),
                        child: PlayerCard(
                          player: _game.team2.player2,
                          team: _game.team2,
                          position: 3,
                          nickname: _game.team2.player2.getNickname(
                            _game.allPlayers,
                            _game.currentRound,
                          ),
                          onTap: () => _openScoreDialog(_game.team2.player2),
                          onToggleCiftli: () =>
                              _toggleCiftli(_game.team2.player2),
                        ),
                      ),

                      const SizedBox(width: gap),

                      // Masa (ortadaki yeşil alan)
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: tableSize,
                            height: tableSize,
                            decoration: BoxDecoration(
                              gradient: AppTheme.tableGradient,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.accentGold.withValues(
                                  alpha: 0.3,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🎴',
                                    style: TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Localization.t(
                                      'game.round',
                                      args: [_game.currentRound],
                                    ),
                                    style: TextStyle(
                                      color: AppTheme.textPrimary.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: gap),

                      // Sağ oyuncu (seat 1) - Takım 2 Oyuncu 1
                      GestureDetector(
                        onLongPress: () => _undoLastScore(_game.team2.player1),
                        child: PlayerCard(
                          player: _game.team2.player1,
                          team: _game.team2,
                          position: 1,
                          nickname: _game.team2.player1.getNickname(
                            _game.allPlayers,
                            _game.currentRound,
                          ),
                          onTap: () => _openScoreDialog(_game.team2.player1),
                          onToggleCiftli: () =>
                              _toggleCiftli(_game.team2.player1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: gap),

                  // Alt oyuncu (seat 2) - Takım 1 Oyuncu 2
                  GestureDetector(
                    onLongPress: () => _undoLastScore(_game.team1.player2),
                    child: PlayerCard(
                      player: _game.team1.player2,
                      team: _game.team1,
                      position: 2,
                      nickname: _game.team1.player2.getNickname(
                        _game.allPlayers,
                        _game.currentRound,
                      ),
                      onTap: () => _openScoreDialog(_game.team1.player2),
                      onToggleCiftli: () => _toggleCiftli(_game.team1.player2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: AppTheme.lightGreen.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomButton(
            icon: Icons.history,
            label: Localization.t('game.history'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScoreHistoryScreen(game: _game),
              ),
            ),
          ),
          if (!_game.isFinished) ...[
            if (_game.currentRound > 1)
              _bottomButton(
                icon: Icons.skip_previous_rounded,
                label: Localization.t('game.prev_round'),
                onTap: _prevRound,
                isDanger: true,
              ),
            _bottomButton(
              icon: Icons.skip_next_rounded,
              label: Localization.t('game.next_round'),
              onTap: _nextRound,
              isPrimary: true,
            ),
            _bottomButton(
              icon: Icons.flag_rounded,
              label: Localization.t('game.end_game'),
              onTap: _endGame,
              isDanger: true,
            ),
          ],
          _bottomButton(
            icon: Icons.analytics_outlined,
            label: Localization.t('game.stats'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StatsScreen(game: _game)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isPrimary
            ? BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : isDanger
            ? BoxDecoration(
                color: AppTheme.dangerRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.dangerRed.withValues(alpha: 0.3),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? Colors.black
                  : isDanger
                  ? AppTheme.dangerRed
                  : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? Colors.black
                    : isDanger
                    ? AppTheme.dangerRed
                    : AppTheme.textMuted,
                fontSize: 10,
                fontWeight: isPrimary || isDanger
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
