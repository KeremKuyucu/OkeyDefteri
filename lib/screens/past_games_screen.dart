import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

class PastGamesScreen extends StatefulWidget {
  const PastGamesScreen({super.key});

  @override
  State<PastGamesScreen> createState() => _PastGamesScreenState();
}

class _PastGamesScreenState extends State<PastGamesScreen> {
  List<Game> _games = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    final games = await StorageService.getSavedGames();
    setState(() {
      _games = games..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _loading = false;
    });
  }

  Future<void> _deleteGame(Game game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Oyunu Sil',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Bu oyun kaydını silmek istediğinize emin misiniz?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteGame(game.id);
      _loadGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Geçmiş Oyunlar',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.lightGreen))
          : _games.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_esports_outlined,
                          size: 64,
                          color: AppTheme.textMuted.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz kayıtlı oyun yok',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _games.length,
                  itemBuilder: (context, index) =>
                      _buildGameCard(_games[index]),
                ),
    );
  }

  Widget _buildGameCard(Game game) {
    final winningTeam = game.leadingTeam;
    final duration = game.endedAt != null
        ? game.endedAt!.difference(game.createdAt)
        : DateTime.now().difference(game.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: game.isFinished
              ? AppTheme.lightGreen.withValues(alpha: 0.15)
              : AppTheme.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(game: game),
              ),
            ).then((_) => _loadGames());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst satır - Tarih ve durum
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: game.isFinished
                                ? AppTheme.textMuted.withValues(alpha: 0.15)
                                : AppTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            game.isFinished ? 'BİTTİ' : 'DEVAM EDİYOR',
                            style: TextStyle(
                              color: game.isFinished
                                  ? AppTheme.textMuted
                                  : AppTheme.accentGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${game.currentRound} el',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.textMuted, size: 20),
                      onPressed: () => _deleteGame(game),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Takım skorları
                Row(
                  children: [
                    Expanded(
                      child: _teamScoreInfo(game.team1,
                          winningTeam?.id == game.team1.id),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _teamScoreInfo(game.team2,
                          winningTeam?.id == game.team2.id),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Alt satır - Tarih
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(game.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamScoreInfo(Team team, bool isWinning) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWinning)
              const Icon(Icons.emoji_events,
                  color: AppTheme.accentGold, size: 14),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                team.name,
                style: TextStyle(
                  color: isWinning
                      ? AppTheme.accentGold
                      : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${team.totalScore}',
          style: TextStyle(
            color: team.totalScore < 0
                ? AppTheme.successGreen
                : team.totalScore > 0
                    ? AppTheme.dangerRed
                    : AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    }
    return '${minutes}dk';
  }
}
