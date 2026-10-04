import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../widgets/game_share_card.dart';
import '../services/share_service.dart';
import 'game_screen.dart';
import 'americano_game_screen.dart';
import '../services/localization_service.dart';

class PastGamesScreen extends StatefulWidget {
  const PastGamesScreen({super.key});

  @override
  State<PastGamesScreen> createState() => _PastGamesScreenState();
}

class _PastGamesScreenState extends State<PastGamesScreen> {
  List<Game> _games = [];
  bool _loading = true;
  // Her oyun kartı için ayrı bir key tutulur
  final Map<String, GlobalKey> _shareKeys = {};
  final Set<String> _expandedGameIds = {};

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

  GlobalKey _keyForGame(Game game) =>
      _shareKeys.putIfAbsent(game.id, () => GlobalKey());

  Future<void> _shareGame(Game game) async {
    final key = _keyForGame(game);
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -9999,
        top: -9999,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: key,
            child: GameShareCard(game: game),
          ),
        ),
      ),
    );
    overlayState.insert(entry);
    await Future.delayed(const Duration(milliseconds: 200));
    await ShareService.shareGameCard(repaintKey: key, game: game);
    entry.remove();
  }

  Future<void> _deleteGame(Game game) async {
    final isSignedIn = AuthService.isSignedIn;

    if (!isSignedIn) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            Localization.t('past_games.delete_game'),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: Text(
            Localization.t('past_games.delete_game_confirm'),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(Localization.t('common.cancel'),
                  style: const TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
              ),
              child: Text(Localization.t('common.delete')),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await StorageService.deleteGame(game.id, deleteFromCloud: false);
        _loadGames();
      }
      return;
    }

    // Oturum açıksa kullanıcıya bulut ve yerel seçeneklerini sor
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Localization.t('past_games.delete_game'),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          Localization.t('past_games.delete_cloud_confirm'),
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(Localization.t('common.cancel'),
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, 'device_only'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.textMuted),
            ),
            child: Text(Localization.t('past_games.delete_from_device_only'),
                style: const TextStyle(color: AppTheme.textPrimary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'everywhere'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: Text(Localization.t('past_games.delete_everywhere')),
          ),
        ],
      ),
    );

    if (choice == 'device_only') {
      await StorageService.deleteGame(game.id, deleteFromCloud: false);
      _loadGames();
    } else if (choice == 'everywhere') {
      await StorageService.deleteGame(game.id, deleteFromCloud: true);
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
        title: Text(
          Localization.t('past_games.title'),
          style: const TextStyle(
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
                      Text(
                        Localization.t('past_games.no_games'),
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
    final isExpanded = _expandedGameIds.contains(game.id);
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
                builder: (context) => game.isAmericano
                    ? AmericanoGameScreen(game: game)
                    : GameScreen(game: game),
              ),
            ).then((_) => _loadGames());
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Üst Satır: Durum / Mod / Tur + Aksiyon Butonları ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: game.isFinished
                            ? AppTheme.textMuted.withValues(alpha: 0.15)
                            : AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        game.isFinished
                            ? Localization.t('common.finished')
                            : Localization.t('common.ongoing'),
                        style: TextStyle(
                          color: game.isFinished
                              ? AppTheme.textMuted
                              : AppTheme.accentGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: game.isAmericano
                            ? AppTheme.accentGold.withValues(alpha: 0.12)
                            : AppTheme.lightGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: game.isAmericano
                              ? AppTheme.accentGold.withValues(alpha: 0.35)
                              : AppTheme.lightGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        game.isAmericano ? '🃏 AMR' : '🀄 101',
                        style: TextStyle(
                          color: game.isAmericano
                              ? AppTheme.accentGold
                              : AppTheme.lightGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        Localization.t('past_games.round',
                            args: [game.currentRound.toString()]),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Paylaşım butonu
                    Material(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _shareGame(game),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.share_rounded,
                            color: AppTheme.accentGold,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Sil butonu
                    Material(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _deleteGame(game),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: AppTheme.textMuted,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Skor Tablosu (Boşluksuz, kompakt ve çerçeveli) ──
                if (game.isAmericanoSolo)
                  _buildSoloScoreboard(game)
                else
                  _buildTeamScoreboard(game, winningTeam),

                const SizedBox(height: 10),

                // ── Alt Satır: Tarih, Süre ve Puan Kırılımı Aç/Kapa ──
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppTheme.textMuted, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(game.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.timer_outlined,
                        color: AppTheme.textMuted, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Detaylı Puan Kırılımı Toggle
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedGameIds.remove(game.id);
                          } else {
                            _expandedGameIds.add(game.id);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpanded
                                  ? Localization.t('past_games.hide_breakdown')
                                  : Localization.t('past_games.show_breakdown'),
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.accentGold,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Genişletilmiş Puan Kırılımı Paneli ──
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.lightGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    child: _buildInlineBreakdown(game),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScoreboard(Game game, Team? winningTeam) {
    final isTeam1Win = winningTeam?.id == game.team1.id;
    final isTeam2Win = winningTeam?.id == game.team2.id;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGreen.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTeamCard(game.team1, isTeam1Win)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
          ),
          Expanded(child: _buildTeamCard(game.team2, isTeam2Win)),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team, bool isWinner) {
    final score = team.totalScore;
    final scoreColor = score < 0
        ? AppTheme.successGreen
        : score > 0
            ? AppTheme.dangerRed
            : AppTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isWinner
            ? AppTheme.accentGold.withValues(alpha: 0.08)
            : AppTheme.surfaceCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWinner
              ? AppTheme.accentGold.withValues(alpha: 0.35)
              : AppTheme.lightGreen.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isWinner)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.emoji_events,
                      color: AppTheme.accentGold, size: 14),
                ),
              Flexible(
                child: Text(
                  team.name,
                  style: TextStyle(
                    color:
                        isWinner ? AppTheme.accentGold : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${team.player1.name} & ${team.player2.name}',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: TextStyle(
              color: scoreColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoloScoreboard(Game game) {
    final sorted = List<Player>.from(game.allPlayers)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));
    final medals = ['🥇', '🥈', '🥉', '4️⃣'];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGreen.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: sorted.asMap().entries.map((e) {
          final rank = e.key;
          final player = e.value;
          final score = player.totalScore;
          final scoreColor = score < 0
              ? AppTheme.successGreen
              : score > 0
                  ? AppTheme.dangerRed
                  : AppTheme.textPrimary;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: rank < 3 ? 6 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: rank == 0
                    ? AppTheme.accentGold.withValues(alpha: 0.08)
                    : AppTheme.surfaceCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: rank == 0
                      ? AppTheme.accentGold.withValues(alpha: 0.3)
                      : AppTheme.lightGreen.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Text(medals[rank], style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    player.name,
                    style: TextStyle(
                      color:
                          rank == 0 ? AppTheme.accentGold : AppTheme.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$score',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInlineBreakdown(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              Localization.t('stats.detailed_score_breakdown'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...game.allPlayers.map((player) {
          final breakdown = player.scoreBreakdown;
          final score = player.totalScore;
          final scoreColor = score < 0
              ? AppTheme.successGreen
              : score > 0
                  ? AppTheme.dangerRed
                  : AppTheme.textPrimary;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCardLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${score > 0 ? "+" : ""}$score',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (breakdown.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: breakdown.entries.map((e) {
                      final type = e.key;
                      final total = e.value;
                      final count = player.scores
                          .where((s) => s.type == type)
                          .length;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${type.emoji} ${type.label}${count > 1 ? " ×$count" : ""}: ${total > 0 ? "+" : ""}$total',
                          style: TextStyle(
                            color: total > 0
                                ? AppTheme.dangerRed
                                : AppTheme.successGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    Localization.t('stats.no_scores'),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
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
      return Localization.t('past_games.hour_minute',args:[hours.toString(),minutes.toString()]);
    }
    return Localization.t('past_games.minute',args: [minutes.toString()]);
  }
}
