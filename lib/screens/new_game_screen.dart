import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen>
    with SingleTickerProviderStateMixin {
  final _team1NameController = TextEditingController(text: 'Takım 1');
  final _team2NameController = TextEditingController(text: 'Takım 2');
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  final _player3Controller = TextEditingController();
  final _player4Controller = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _team1NameController.dispose();
    _team2NameController.dispose();
    _player1Controller.dispose();
    _player2Controller.dispose();
    _player3Controller.dispose();
    _player4Controller.dispose();
    super.dispose();
  }

  void _startGame() {
    // Boş isim kontrolü
    final p1 = _player1Controller.text.trim();
    final p2 = _player2Controller.text.trim();
    final p3 = _player3Controller.text.trim();
    final p4 = _player4Controller.text.trim();
    final t1 = _team1NameController.text.trim();
    final t2 = _team2NameController.text.trim();

    if (p1.isEmpty || p2.isEmpty || p3.isEmpty || p4.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tüm oyuncu isimlerini giriniz!'),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Takım 1: Üst (seat 0) ve Alt (seat 2) - karşılıklı
    // Takım 2: Sağ (seat 1) ve Sol (seat 3) - karşılıklı
    final game = Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      team1: Team(
        id: 'team1_${DateTime.now().millisecondsSinceEpoch}',
        name: t1.isNotEmpty ? t1 : 'Takım 1',
        player1: Player(
          id: 'p1_${DateTime.now().millisecondsSinceEpoch}',
          name: p1,
          seatIndex: 0, // Üst
        ),
        player2: Player(
          id: 'p3_${DateTime.now().millisecondsSinceEpoch}',
          name: p3,
          seatIndex: 2, // Alt
        ),
      ),
      team2: Team(
        id: 'team2_${DateTime.now().millisecondsSinceEpoch}',
        name: t2.isNotEmpty ? t2 : 'Takım 2',
        player1: Player(
          id: 'p2_${DateTime.now().millisecondsSinceEpoch}',
          name: p2,
          seatIndex: 1, // Sağ
        ),
        player2: Player(
          id: 'p4_${DateTime.now().millisecondsSinceEpoch}',
          name: p4,
          seatIndex: 3, // Sol
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Yeni Oyun',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Masa düzeni açıklaması
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Masa Düzeni',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Karşılıklı oturan oyuncular takım arkadaşıdır.\nOyuncu 1 (üst) ↔ Oyuncu 3 (alt) = Takım 1\nOyuncu 2 (sağ) ↔ Oyuncu 4 (sol) = Takım 2',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Takım 1
              _buildTeamSection(
                teamName: 'Takım 1',
                teamController: _team1NameController,
                player1Label: 'Oyuncu 1 (Üst)',
                player2Label: 'Oyuncu 3 (Alt)',
                player1Controller: _player1Controller,
                player2Controller: _player3Controller,
                color: AppTheme.lightGreen,
              ),
              const SizedBox(height: 24),

              // Takım 2
              _buildTeamSection(
                teamName: 'Takım 2',
                teamController: _team2NameController,
                player1Label: 'Oyuncu 2 (Sağ)',
                player2Label: 'Oyuncu 4 (Sol)',
                player1Controller: _player2Controller,
                player2Controller: _player4Controller,
                color: AppTheme.accentAmber,
              ),
              const SizedBox(height: 32),

              // Mini önizleme
              _buildTablePreview(),
              const SizedBox(height: 32),

              // Başla butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'OYUNU BAŞLAT',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection({
    required String teamName,
    required TextEditingController teamController,
    required String player1Label,
    required String player2Label,
    required TextEditingController player1Controller,
    required TextEditingController player2Controller,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Takım ismi
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.groups_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: teamController,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Takım İsmi',
                    labelStyle: TextStyle(color: color.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: AppTheme.surfaceCardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Oyuncu 1
          TextField(
            controller: player1Controller,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              labelText: player1Label,
              prefixIcon: Icon(
                Icons.person,
                color: color.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppTheme.surfaceCardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Oyuncu 2
          TextField(
            controller: player2Controller,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              labelText: player2Label,
              prefixIcon: Icon(
                Icons.person,
                color: color.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppTheme.surfaceCardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablePreview() {
    final p1 = _player1Controller.text.isEmpty
        ? 'Oyuncu 1'
        : _player1Controller.text;
    final p2 = _player2Controller.text.isEmpty
        ? 'Oyuncu 2'
        : _player2Controller.text;
    final p3 = _player3Controller.text.isEmpty
        ? 'Oyuncu 3'
        : _player3Controller.text;
    final p4 = _player4Controller.text.isEmpty
        ? 'Oyuncu 4'
        : _player4Controller.text;

    return Container(
      height: 240, // Yükseklik artırıldı ki oyuncular sığsın
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.15)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Masa
          Container(
            width: 125,
            height: 125,
            decoration: BoxDecoration(
              gradient: AppTheme.tableGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('🎴', style: TextStyle(fontSize: 28)),
            ),
          ),
          // Üst
          Positioned(top: 0, child: _miniPlayer(p1, AppTheme.lightGreen)),
          // Sağ
          Positioned(right: 0, child: _miniPlayer(p2, AppTheme.accentAmber)),
          // Alt
          Positioned(bottom: 0, child: _miniPlayer(p3, AppTheme.lightGreen)),
          // Sol
          Positioned(left: 0, child: _miniPlayer(p4, AppTheme.accentAmber)),
        ],
      ),
    );
  }

  Widget _miniPlayer(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        name.length > 8 ? '${name.substring(0, 8)}...' : name,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
