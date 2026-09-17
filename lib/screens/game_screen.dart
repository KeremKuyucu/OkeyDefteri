import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/player_card.dart';
import '../widgets/team_score_bar.dart';
import '../widgets/score_input_dialog.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/table_banter_bar.dart';
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
    AdService.loadInterstitialAd();
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

  /// Bu oyuncunun mevcut turda zaten bitirme veya kalan taş puanı var mı?
  bool _playerHasTurnEndingScoreInCurrentRound(Player player) {
    return player.scores.any(
      (s) =>
          s.roundNumber == _game.currentRound &&
          (s.type.isFinishType || s.type == ScoreType.eldeKalanTaslar),
    );
  }

  /// Toplu tur sonu dialogu — masaya tıklayınca açılır
  Future<void> _openBulkRoundEndDialog() async {
    if (_game.isFinished) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Localization.t('game.finished'))));
      return;
    }

    if (_game.isNormalOkey) {
      return _openNormalOkeyRoundEndDialog();
    }

    // Turu geçmeyi unuttun mu kontrolü
    if (_hasTurnEndingScoreInCurrentRound()) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.accentGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Localization.t('game.forgot_round_title'),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
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
    AudioVibrationService.vibrateHeavy();

    // Toplu tur sonu dialogunu göster
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BulkRoundEndDialog(game: _game),
    );

    if (!mounted || result == null) return;

    final noWinner = result['noWinner'] == true;
    final winnerId = result['winnerId'] as String?;
    final finishType = result['finishType'] as ScoreType?;
    final scores = result['scores'] as Map<String, int>;

    final now = DateTime.now();
    setState(() {
      if (noWinner || winnerId == null) {
        // Kimse bitmedi
        for (final player in _game.allPlayers) {
          final pts = scores[player.id] ?? 0;
          if (pts > 0) {
            player.scores.add(
              ScoreEntry(
                id: '${now.millisecondsSinceEpoch}_${player.id}_remaining',
                type: ScoreType.eldeKalanTaslar,
                points: pts,
                isCiftli: player.isCiftliGidiyor,
                isOkeyFinish: false,
                timestamp: now,
                roundNumber: _game.currentRound,
              ),
            );
          }
        }
      } else {
        // Kazanan var
        for (final player in _game.allPlayers) {
          if (player.id == winnerId) {
            // Bitiren oyuncuya bitirme puanı
            player.scores.add(
              ScoreEntry(
                id: '${now.millisecondsSinceEpoch}_${player.id}_finish',
                type: finishType!,
                points: finishType.defaultPoints,
                isCiftli: player.isCiftliGidiyor,
                timestamp: now,
                roundNumber: _game.currentRound,
              ),
            );
          } else {
            // Diğer oyunculara elde kalan taş puanı
            final pts = scores[player.id] ?? 0;
            if (pts > 0) {
              final isOkeyFinish =
                  finishType == ScoreType.okeyAtarakBitti ||
                  finishType == ScoreType.okeyAtarakEldenBitti;
              final isEldenFinish =
                  finishType == ScoreType.eldenBitti ||
                  finishType == ScoreType.okeyAtarakEldenBitti;
              player.scores.add(
                ScoreEntry(
                  id: '${now.millisecondsSinceEpoch}_${player.id}_remaining',
                  type: ScoreType.eldeKalanTaslar,
                  points: pts,
                  isCiftli: player.isCiftliGidiyor,
                  isOkeyFinish: isOkeyFinish || isEldenFinish,
                  timestamp: now,
                  roundNumber: _game.currentRound,
                ),
              );
            }
          }
        }
      }
    });
    await _saveGame();

    if (!mounted) return;
    if (noWinner || winnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localization.t('game.no_winner_saved'),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      final winner = _game.allPlayers.firstWhere((p) => p.id == winnerId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${winner.name} ${finishType!.emoji} ${finishType.label}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Normal Okey tur sonu puan giriş dialogunu açar
  Future<void> _openNormalOkeyRoundEndDialog([
    Player? preselectedPlayer,
  ]) async {
    if (_game.isFinished) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Localization.t('game.finished'))));
      return;
    }

    if (_hasTurnEndingScoreInCurrentRound()) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.accentGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Localization.t('game.forgot_round_title'),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
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
    AudioVibrationService.vibrateHeavy();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _NormalOkeyRoundEndDialog(
        game: _game,
        initialWinnerId: preselectedPlayer?.id,
      ),
    );

    if (!mounted || result == null) return;

    final noWinner = result['noWinner'] == true;
    final winnerId = result['winnerId'] as String?;
    final scoreType = result['scoreType'] as ScoreType?;
    final points = result['points'] as int? ?? 1;

    final now = DateTime.now();
    setState(() {
      if (!noWinner && winnerId != null && scoreType != null) {
        final winner = _game.allPlayers.firstWhere((p) => p.id == winnerId);
        winner.scores.add(
          ScoreEntry(
            id: '${now.millisecondsSinceEpoch}_${winner.id}_win',
            type: scoreType,
            points: points,
            timestamp: now,
            roundNumber: _game.currentRound,
          ),
        );
      }
    });
    await _saveGame();

    if (!mounted) return;
    if (noWinner || winnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localization.t('game.no_winner_saved'),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      final winner = _game.allPlayers.firstWhere((p) => p.id == winnerId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${winner.name} ${scoreType!.emoji} ${scoreType.label} (+$points)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _openScoreDialog(Player player) async {
    if (_game.isFinished) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Localization.t('game.finished'))));
      return;
    }

    if (_game.isNormalOkey) {
      return _openNormalOkeyRoundEndDialog(player);
    }

    // Bu oyuncu için turu geçmeyi unuttun mu kontrolü
    if (_playerHasTurnEndingScoreInCurrentRound(player)) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.accentGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Localization.t('game.forgot_round_title'),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
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
        title: Text(
          Localization.t('game.undo_score_title'),
          style: const TextStyle(color: AppTheme.textPrimary),
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
            child: Text(
              Localization.t('common.cancel'),
              style: const TextStyle(color: AppTheme.textSecondary),
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
            child: Text(
              Localization.t('common.undo'),
              style: const TextStyle(color: Colors.white),
            ),
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

  void _advanceRound() {
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _nextRound() {
    if (_game.isFinished) return;
    AudioVibrationService.playClickSound();
    AudioVibrationService.vibrateHeavy();

    AdService.showInterstitialAd(onDismissed: _advanceRound);
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
            TeamScoreBar(
              team1: _game.team1,
              team2: _game.team2,
              isHigherBetter: _game.isNormalOkey,
            ),
            const SizedBox(height: 4),

            // Canlı Masa Muhabbeti / Spiker Bandı
            TableBanterBar(
              players: _game.allPlayers,
              roundNumber: _game.currentRound,
            ),
            const SizedBox(height: 4),

            // Oyun masası
            Expanded(child: _buildGameTable()),

            // AdMob Banner Reklamı
            const AdBannerWidget(),

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
                  _game.isNormalOkey
                      ? Localization.t('normal_okey.title')
                      : Localization.t('game.title'),
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
        // Geniş ekranlarda aşırı büyümeyi önlemek için maksimum genişlik sınırı uygulanır.
        final effectiveWidth = constraints.maxWidth.clamp(0.0, 520.0);
        final tableSize = effectiveWidth * 0.42;
        const double gap = 12.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
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
                        isHigherScoreBetter: _game.isNormalOkey,
                        hideCiftliToggle: _game.isNormalOkey,
                        onTap: () => _openScoreDialog(_game.team1.player1),
                        onToggleCiftli: () =>
                            _toggleCiftli(_game.team1.player1),
                      ),
                    ),

                    const SizedBox(height: gap),

                    // Orta Satır (Sol Oyuncu - Masa - Sağ Oyuncu)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sol oyuncu (seat 3) - Takım 2 Oyuncu 2
                        GestureDetector(
                          onLongPress: () =>
                              _undoLastScore(_game.team2.player2),
                          child: PlayerCard(
                            player: _game.team2.player2,
                            team: _game.team2,
                            position: 3,
                            isHigherScoreBetter: _game.isNormalOkey,
                            hideCiftliToggle: _game.isNormalOkey,
                            onTap: () => _openScoreDialog(_game.team2.player2),
                            onToggleCiftli: () =>
                                _toggleCiftli(_game.team2.player2),
                          ),
                        ),

                        const SizedBox(width: gap),

                        // Masa (ortadaki yeşil alan)
                        GestureDetector(
                          onTap: _openBulkRoundEndDialog,
                          child: AnimatedBuilder(
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
                                          color: AppTheme.textPrimary
                                              .withValues(alpha: 0.7),
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
                        ),

                        const SizedBox(width: gap),

                        // Sağ oyuncu (seat 1) - Takım 2 Oyuncu 1
                        GestureDetector(
                          onLongPress: () =>
                              _undoLastScore(_game.team2.player1),
                          child: PlayerCard(
                            player: _game.team2.player1,
                            team: _game.team2,
                            position: 1,
                            isHigherScoreBetter: _game.isNormalOkey,
                            hideCiftliToggle: _game.isNormalOkey,
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
                        isHigherScoreBetter: _game.isNormalOkey,
                        hideCiftliToggle: _game.isNormalOkey,
                        onTap: () => _openScoreDialog(_game.team1.player2),
                        onToggleCiftli: () =>
                            _toggleCiftli(_game.team1.player2),
                      ),
                    ),
                  ],
                ),
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
            _bottomButton(
              icon: Icons.skip_next_rounded,
              label: Localization.t('game.next_round'),
              onTap: _nextRound,
              onLongPress: _game.currentRound > 1 ? _prevRound : null,
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
    VoidCallback? onLongPress,
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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

/// Normal Okey tur sonu bitirme dialogu
class _NormalOkeyRoundEndDialog extends StatefulWidget {
  final Game game;
  final String? initialWinnerId;

  const _NormalOkeyRoundEndDialog({required this.game, this.initialWinnerId});

  @override
  State<_NormalOkeyRoundEndDialog> createState() =>
      _NormalOkeyRoundEndDialogState();
}

class _NormalOkeyRoundEndDialogState extends State<_NormalOkeyRoundEndDialog> {
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
                                        Color(0xFF2E7D32),
                                        Color(0xFF1B5E20),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _isCift ? null : AppTheme.surfaceCardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCift
                                    ? AppTheme.lightGreen
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

                  // Puan Önizleme Kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: _isOkey && _isCift
                          ? const LinearGradient(
                              colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
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

/// Toplu tur sonu puan giriş dialogu
class _BulkRoundEndDialog extends StatefulWidget {
  final Game game;

  const _BulkRoundEndDialog({required this.game});

  @override
  State<_BulkRoundEndDialog> createState() => _BulkRoundEndDialogState();
}

class _BulkRoundEndDialogState extends State<_BulkRoundEndDialog> {
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
                              '${type.defaultPoints}',
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
                                '${_finishType.defaultPoints}',
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
                                // Hızlı 202 (Açamadı) butonu
                                if (_noWinner)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _controllers[p.id]?.text = '202';
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
                                        child: const Text(
                                          '202',
                                          style: TextStyle(
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
                    _noWinner
                        ? Localization.t('common.save')
                        : Localization.t('common.save'),
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
