import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/cloud_service.dart';
import '../models/game_models.dart';
import 'new_game_screen.dart';
import 'past_games_screen.dart';
import 'game_screen.dart';
import 'americano_game_screen.dart';
import '../widgets/developer_info.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import '../services/update_checker_service.dart';
import '../main.dart';

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
    _checkForUpdates();
  }

  void _checkForUpdates() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.check(context);
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
            content: Text(error),
            backgroundColor: AppTheme.dangerRed,
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
            ),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (mounted) setState(() {});
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
            ),
            backgroundColor:
                newGames.isEmpty ? AppTheme.surfaceCard : AppTheme.lightGreen,
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
    final isSignedIn = AuthService.isSignedIn;
    final name = AuthService.displayName;
    final avatarUrl = AuthService.avatarUrl;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (isSignedIn) ...[
              // Profil bilgisi
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.accentGold.withValues(alpha: 0.2),
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          Localization.t('cloud.active'),
                          style: const TextStyle(
                            color: AppTheme.lightGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppTheme.surfaceCardLight),
              const SizedBox(height: 12),
              // Geri yukle
              ListTile(
                leading: const Icon(Icons.cloud_download_rounded,
                    color: AppTheme.lightGreen),
                title: Text(Localization.t('cloud.restore'),
                    style: const TextStyle(color: AppTheme.textPrimary)),
                subtitle: Text(Localization.t('cloud.restore_subtitle'),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _restoreFromCloud();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload_rounded,
                    color: AppTheme.accentAmber),
                title: Text(Localization.t('cloud.push_all'),
                    style: const TextStyle(color: AppTheme.textPrimary)),
                subtitle: Text(Localization.t('cloud.push_all_subtitle'),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _syncAllToCloud();
                },
              ),
              const SizedBox(height: 8),
              // Cikis
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _signOut();
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.dangerRed, size: 18),
                  label: Text(Localization.t('cloud.sign_out'),
                      style: const TextStyle(color: AppTheme.dangerRed)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppTheme.dangerRed.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              // Giris ekrani
              const Icon(Icons.cloud_off_rounded,
                  color: AppTheme.textMuted, size: 48),
              const SizedBox(height: 12),
              Text(
                Localization.t('cloud.title'),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                Localization.t('cloud.desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              // Google ile giris
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _signInWithGoogle();
                  },
                  icon: const Text('👀', style: TextStyle(fontSize: 18)),
                  label: Text(
                    Localization.t('cloud.sign_in_google'),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettings() async {
    bool isVibrationEnabled = SettingsService.getVibrationEnabled();
    bool isSoundEnabled = SettingsService.getSoundEnabled();
    bool isTelemetryEnabled = SettingsService.getTelemetryEnabled();
    bool isToxicNicknamesEnabled = SettingsService.getToxicNicknamesEnabled();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  Localization.t('settings.title'),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppTheme.accentGold,
                  ),
                  title: Text(
                    Localization.t('settings.language'),
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: DropdownButton<String>(
                    value: Localization.currentLanguage,
                    dropdownColor: AppTheme.surfaceDark,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.accentGold,
                    ),
                    items: Localization.supportedLanguages.map((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(Localization.getDisplayName(lang)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null &&
                          newValue != Localization.currentLanguage) {
                        await SettingsService.setLanguage(newValue);
                        await Localization.changeLanguage(newValue);
                        if (context.mounted) {
                          Navigator.pop(context);
                          OkeyDefteriApp.restartApp(context);
                        }
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.vibration,
                    color: AppTheme.accentGold,
                  ),
                  title: Text(
                    Localization.t('settings.vibration'),
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: Switch(
                    value: isVibrationEnabled,
                    onChanged: (v) async {
                      await SettingsService.setVibrationEnabled(v);
                      setBottomSheetState(() {
                        isVibrationEnabled = v;
                      });
                      if (v) {
                        AudioVibrationService.vibrate();
                      }
                    },
                    activeThumbColor: AppTheme.accentGold,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.volume_up,
                    color: AppTheme.accentGold,
                  ),
                  title: Text(
                    Localization.t('settings.sound_effects'),
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: Switch(
                    value: isSoundEnabled,
                    onChanged: (v) async {
                      await SettingsService.setSoundEnabled(v);
                      setBottomSheetState(() {
                        isSoundEnabled = v;
                      });
                      if (v) {
                        AudioVibrationService.playClickSound();
                      }
                    },
                    activeThumbColor: AppTheme.accentGold,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.security,
                    color: AppTheme.accentGold,
                  ),
                  title: Text(
                    Localization.t('settings.telemetry'),
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: Switch(
                    value: isTelemetryEnabled,
                    onChanged: (v) async {
                      if (!v) {
                        final shouldDisable = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.surfaceDark,
                            title: Text(
                              Localization.t('settings.are_you_sure'),
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            content: Text(
                              Localization.t('settings.telemetry_message'),
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  Localization.t('settings.disable_anyway'),
                                  style: TextStyle(
                                    color: AppTheme.warningOrange,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentGold,
                                ),
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  Localization.t('settings.keep_enabled'),
                                  style: TextStyle(
                                    color: AppTheme.backgroundDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldDisable != true) return;
                      }

                      await SettingsService.setTelemetryEnabled(v);
                      setBottomSheetState(() {
                        isTelemetryEnabled = v;
                      });
                    },
                    activeThumbColor: AppTheme.accentGold,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.face_retouching_off,
                    color: AppTheme.accentGold,
                  ),
                  title: Text(
                    Localization.t('settings.toxic_nicknames'),
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: Switch(
                    value: isToxicNicknamesEnabled,
                    onChanged: (v) async {
                      await SettingsService.setToxicNicknamesEnabled(v);
                      setBottomSheetState(() {
                        isToxicNicknamesEnabled = v;
                      });
                    },
                    activeThumbColor: AppTheme.accentGold,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppTheme.accentGold,
                  ),
                  title: Text(
                    Localization.t('settings.about'),
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    DeveloperInfo.show(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.import_export,
                    color: AppTheme.accentGold,
                  ),
                  title: Text(
                    Localization.t('settings.import_export'),
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showImportExportDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  void _showImportExportDialog() async {
    final data = await StorageService.exportData();
    final controller = TextEditingController(text: data);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          Localization.t('settings.import_export'),
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 15,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: Localization.t('settings.import_export_info'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: controller.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Localization.t('settings.all_data_copied')),
                ),
              );
            },
            child: Text(
              Localization.t('settings.copy_all'),
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
            ),
            onPressed: () async {
              try {
                await StorageService.importData(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Localization.t('settings.data_successfully_updated'),
                      ),
                    ),
                  );
                  OkeyDefteriApp.restartApp(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(Localization.t('settings.invalid_json')),
                    ),
                  );
                }
              }
            },
            child: Text(
              Localization.t('common.save'),
              style: TextStyle(
                color: AppTheme.backgroundDark,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                        _buildActiveGameCard(),

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
                      const SizedBox(height: 40),

                      // Kısa bilgi
                      _buildInfoSection(),
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
              child: const Center(
                child: Text('🎴', style: TextStyle(fontSize: 54)),
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

  Widget _buildActiveGameCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A3A1F), Color(0xFF1A2E1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppTheme.accentGold,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.dangerRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Localization.t('home.active_game'),
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_activeGame!.team1.name} vs ${_activeGame!.team2.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'El ${_activeGame!.currentRound}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.accentGold,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.accentGold,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                Localization.t('home.quick_tips'),
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.touch_app_rounded,
            Localization.t('home.quick_tips_1'),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.undo_rounded, Localization.t('home.quick_tips_2')),
          const SizedBox(height: 12),
          _infoRow(
            Icons.calculate_rounded,
            Localization.t('home.quick_tips_3'),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.groups_rounded, Localization.t('home.quick_tips_4')),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
