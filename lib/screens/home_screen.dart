import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../models/game_models.dart';
import 'new_game_screen.dart';
import 'past_games_screen.dart';
import 'game_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: SingleChildScrollView(
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
                    label: 'Yeni Oyun',
                    subtitle: 'Yeni bir 101 oyunu başlat',
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
                    label: 'Geçmiş Oyunlar',
                    subtitle: '$_totalGames oyun kayıtlı',
                    gradient: const LinearGradient(
                      colors: [AppTheme.surfaceCard, AppTheme.surfaceCardLight],
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
          child: const Text(
            'OKEY 101',
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
          child: const Text(
            'PREMIUM SKOR DEFTERİ',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
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
                builder: (context) => GameScreen(game: _activeGame!),
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
                          const Text(
                            'Devam Eden Oyun',
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
              const Text(
                'Hızlı İpuçları',
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
          _infoRow(Icons.touch_app_rounded, 'Oyuncuya dokunarak puan ekle'),
          const SizedBox(height: 12),
          _infoRow(Icons.undo_rounded, 'Uzun basarak son puanı geri al'),
          const SizedBox(height: 12),
          _infoRow(
            Icons.calculate_rounded,
            'Hesap makinesi ile kalan taşları hesapla',
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.groups_rounded, 'Karşılıklı oturanlar takım arkadaşı'),
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
