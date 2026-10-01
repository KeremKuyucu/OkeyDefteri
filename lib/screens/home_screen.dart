import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/cloud_service.dart';
import '../models/game_models.dart';
import 'new_game_screen.dart';
import 'past_games_screen.dart';
import 'career_screen.dart';
import 'game_rules_screen.dart';
import 'game_screen.dart';
import 'americano_game_screen.dart';
import '../widgets/cloud_backup_sheet.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/active_game_card.dart';
import '../widgets/home_quick_tips_widget.dart';
import '../services/localization_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  Game? _activeGame;
  int _totalGames = 0;
  bool _isSyncing = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
    _loadData();
    _authSub = AuthService.authStateChanges.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _autoSyncOnSignIn();
      } else if (data.event == AuthChangeEvent.signedOut) {
        if (mounted) {
          _loadData();
          setState(() {});
        }
      }
    });
  }

  Future<void> _loadData() async {
    final activeGame = await StorageService.getActiveGame();
    final games = await StorageService.getSavedGames();
    if (mounted) {
      // Bitmiş oyunu aktif olarak gösterme, kaydı da temizle
      if (activeGame != null && activeGame.isFinished) {
        await StorageService.clearActiveGame();
        setState(() {
          _activeGame = null;
          _totalGames = games.length;
        });
      } else {
        setState(() {
          _activeGame = activeGame;
          _totalGames = games.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Cloud / Auth Metodlari
  // ──────────────────────────────────────────────

  Future<void> _signInWithGoogle() async {
    try {
      final error = await AuthService.signInWithGoogle();
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localization.t('cloud.sign_in_error', args: [e.toString()]),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSyncing = true);
    try {
      await AuthService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localization.t('cloud.signed_out'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.surfaceCardLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        await _loadData();
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _autoSyncOnSignIn() async {
    if (!AuthService.isSignedIn) return;
    if (mounted) setState(() => _isSyncing = true);
    try {
      final localGames = await StorageService.getSavedGames();
      final newGames = await CloudService.fetchAndMerge(localGames);
      for (final game in newGames) {
        await StorageService.saveGame(game);
      }
      if (!mounted) return;
      await _loadData();
      if (!mounted) return;
      if (newGames.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localization.t('cloud.auto_sync_success',
                  args: [newGames.length.toString()]),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.lightGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Auto-sync on sign-in error: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _restoreFromCloud() async {
    if (!AuthService.isSignedIn) return;
    setState(() => _isSyncing = true);
    try {
      final localGames = await StorageService.getSavedGames();
      final newGames = await CloudService.fetchAndMerge(localGames);
      for (final game in newGames) {
        await StorageService.saveGame(game);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newGames.isEmpty
                  ? Localization.t('cloud.up_to_date')
                  : Localization.t(
                      'cloud.restore_success',
                      args: [newGames.length.toString()],
                    ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor:
                newGames.isEmpty ? AppTheme.surfaceCardLight : AppTheme.lightGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        await _loadData();
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _syncAllToCloud() async {
    if (!AuthService.isSignedIn) return;
    setState(() => _isSyncing = true);
    try {
      final games = await StorageService.getSavedGames();
      final count = await CloudService.pushLocalGames(games);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localization.t('cloud.push_success', args: [count.toString()]),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.lightGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showCloudMenu(BuildContext context) {
    CloudBackupSheet.show(
      context,
      onRestore: _restoreFromCloud,
      onSyncAll: _syncAllToCloud,
      onSignOut: _signOut,
      onSignInWithGoogle: _signInWithGoogle,
    );
  }

  void _showSettings() {
    SettingsSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Logo ve Başlık
                      _buildHeader(),
                      const SizedBox(height: 40),

                      // Aktif oyun kartı
                      if (_activeGame != null && !_activeGame!.isFinished)
                        ActiveGameCard(
                          game: _activeGame!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _activeGame!.isAmericano
                                    ? AmericanoGameScreen(game: _activeGame!)
                                    : GameScreen(game: _activeGame!),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),

                      // Ana butonlar
                      _buildMainButton(
                        icon: Icons.add_circle_rounded,
                        label: Localization.t('home.new_game'),
                        subtitle: Localization.t('home.new_game_subtitle'),
                        gradient: AppTheme.goldGradient,
                        textColor: Colors.black,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewGameScreen(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                      const SizedBox(height: 14),

                      _buildMainButton(
                        icon: Icons.history_rounded,
                        label: Localization.t('home.past_games'),
                        subtitle: Localization.t(
                          'home.past_games_info',
                          args: [_totalGames],
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.surfaceCard,
                            AppTheme.surfaceCardLight,
                          ],
                        ),
                        textColor: AppTheme.textPrimary,
                        borderColor: AppTheme.lightGreen.withValues(alpha: 0.2),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PastGamesScreen(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                      const SizedBox(height: 14),

                      _buildMainButton(
                        icon: Icons.emoji_events_rounded,
                        label: Localization.t('home.career'),
                        subtitle: Localization.t('home.career_subtitle'),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF233B27),
                            Color(0xFF192B1C),
                          ],
                        ),
                        textColor: AppTheme.accentGold,
                        borderColor: AppTheme.accentGold.withValues(alpha: 0.3),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CareerScreen(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                      const SizedBox(height: 14),

                      _buildMainButton(
                        icon: Icons.auto_stories_rounded,
                        label: Localization.t('home.rules'),
                        subtitle: Localization.t('home.rules_subtitle'),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E2836),
                            Color(0xFF151C26),
                          ],
                        ),
                        textColor: const Color(0xFF64B5F6),
                        borderColor:
                            const Color(0xFF64B5F6).withValues(alpha: 0.25),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameRulesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 36),

                      // Kısa bilgi
                      const HomeQuickTipsWidget(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                // Ayarlar (sag ust)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: AppTheme.textSecondary,
                      size: 28,
                    ),
                    onPressed: _showSettings,
                  ),
                ),
                // Bulut / Profil butonu (sol ust)
                Positioned(
                  top: 16,
                  left: 8,
                  child: StreamBuilder<AuthState>(
                    stream: AuthService.authStateChanges,
                    builder: (context, _) {
                      final isSignedIn = AuthService.isSignedIn;
                      final avatarUrl = AuthService.avatarUrl;
                      return GestureDetector(
                        onTap: () => _showCloudMenu(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSignedIn
                                ? AppTheme.lightGreen.withValues(alpha: 0.15)
                                : AppTheme.surfaceCard,
                            border: Border.all(
                              color: isSignedIn
                                  ? AppTheme.lightGreen.withValues(alpha: 0.4)
                                  : AppTheme.surfaceCardLight,
                            ),
                          ),
                          child: _isSyncing
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.accentGold,
                                  ),
                                )
                              : isSignedIn && avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    avatarUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => const Icon(
                                      Icons.person_rounded,
                                      color: AppTheme.lightGreen,
                                      size: 22,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isSignedIn
                                      ? Icons.cloud_done_rounded
                                      : Icons.cloud_off_rounded,
                                  color: isSignedIn
                                      ? AppTheme.lightGreen
                                      : AppTheme.textMuted,
                                  size: 22,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Okey taşı ikonu - daha büyük ve premium
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withValues(alpha: 0.05),
              ),
            ),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: AppTheme.tableGradient,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.5),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.goldGradient.createShader(bounds),
          child: Text(
            Localization.t('home.okey_defteri'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Gradient gradient,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: textColor == Colors.black
                        ? Colors.black.withValues(alpha: 0.1)
                        : AppTheme.lightGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: textColor, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: textColor.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
