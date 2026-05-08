import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/player_card.dart';
import '../widgets/team_score_bar.dart';
import '../widgets/score_input_dialog.dart';
import 'score_history_screen.dart';
import 'stats_screen.dart';

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
    _pulseAnimation =
        Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveGame() async {
    await StorageService.saveActiveGame(_game);
  }

  Future<void> _openScoreDialog(Player player) async {
    final result = await showDialog<ScoreEntry>(
      context: context,
      builder: (context) => ScoreInputDialog(
        player: player,
        currentRound: _game.currentRound,
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
    if (player.scores.isEmpty) return;

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
          '${player.name} için son girilen puanı (${player.scores.last.effectivePoints}) geri almak istediğinize emin misiniz?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.textSecondary)),
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

  void _nextRound() {
    setState(() {
      _game.currentRound++;
    });
    _saveGame();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'El ${_game.currentRound} başladı!',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.lightGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Oyunu Bitir',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Oyunu bitirmek istediğinize emin misiniz? Skorlar kaydedilecektir.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.textSecondary)),
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
            child: const Text('Bitir'),
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
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppTheme.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Okey 101',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'El ${_game.currentRound}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon:
                const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            itemBuilder: (context) => [
              _popupItem('history', Icons.history, 'Skor Geçmişi'),
              _popupItem('stats', Icons.analytics, 'İstatistikler'),
              _popupItem('end', Icons.flag, 'Oyunu Bitir'),
            ],
            onSelected: (value) {
              switch (value) {
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScoreHistoryScreen(game: _game),
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

  PopupMenuItem<String> _popupItem(
      String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildGameTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Masa boyutunu hesapla
        final tableSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth * 0.42
            : constraints.maxHeight * 0.35;

        return Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
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
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.primaryGreen.withValues(alpha: 0.3),
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
                              'El ${_game.currentRound}',
                              style: TextStyle(
                                color: AppTheme.textPrimary.withValues(alpha: 0.7),
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

                // Üst oyuncu (seat 0) - Takım 1 Oyuncu 1
                Positioned(
                  top: 4,
                  left: constraints.maxWidth * 0.15,
                  right: constraints.maxWidth * 0.15,
                  child: Center(
                    child: GestureDetector(
                      onLongPress: () =>
                          _undoLastScore(_game.team1.player1),
                      child: PlayerCard(
                        player: _game.team1.player1,
                        team: _game.team1,
                        position: 0,
                        onTap: () =>
                            _openScoreDialog(_game.team1.player1),
                      ),
                    ),
                  ),
                ),

                // Sağ oyuncu (seat 1) - Takım 2 Oyuncu 1
                Positioned(
                  right: 4,
                  top: constraints.maxHeight * 0.25,
                  bottom: constraints.maxHeight * 0.25,
                  child: Center(
                    child: GestureDetector(
                      onLongPress: () =>
                          _undoLastScore(_game.team2.player1),
                      child: PlayerCard(
                        player: _game.team2.player1,
                        team: _game.team2,
                        position: 1,
                        onTap: () =>
                            _openScoreDialog(_game.team2.player1),
                      ),
                    ),
                  ),
                ),

                // Alt oyuncu (seat 2) - Takım 1 Oyuncu 2
                Positioned(
                  bottom: 4,
                  left: constraints.maxWidth * 0.15,
                  right: constraints.maxWidth * 0.15,
                  child: Center(
                    child: GestureDetector(
                      onLongPress: () =>
                          _undoLastScore(_game.team1.player2),
                      child: PlayerCard(
                        player: _game.team1.player2,
                        team: _game.team1,
                        position: 2,
                        onTap: () =>
                            _openScoreDialog(_game.team1.player2),
                      ),
                    ),
                  ),
                ),

                // Sol oyuncu (seat 3) - Takım 2 Oyuncu 2
                Positioned(
                  left: 4,
                  top: constraints.maxHeight * 0.25,
                  bottom: constraints.maxHeight * 0.25,
                  child: Center(
                    child: GestureDetector(
                      onLongPress: () =>
                          _undoLastScore(_game.team2.player2),
                      child: PlayerCard(
                        player: _game.team2.player2,
                        team: _game.team2,
                        position: 3,
                        onTap: () =>
                            _openScoreDialog(_game.team2.player2),
                      ),
                    ),
                  ),
                ),
              ],
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
            label: 'Geçmiş',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScoreHistoryScreen(game: _game),
              ),
            ),
          ),
          _bottomButton(
            icon: Icons.skip_next_rounded,
            label: 'Sonraki El',
            onTap: _nextRound,
            isPrimary: true,
          ),
          _bottomButton(
            icon: Icons.flag_rounded,
            label: 'Bitir',
            onTap: _endGame,
            isDanger: true,
          ),
          _bottomButton(
            icon: Icons.analytics_outlined,
            label: 'İstatistik',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatsScreen(game: _game),
              ),
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
