import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'americano_game_screen.dart';
import '../services/localization_service.dart';
import '../services/career_service.dart';
import '../widgets/game_mode_selector.dart';
import '../widgets/quick_player_chips.dart';
import '../widgets/table_preview_widget.dart';
import '../widgets/team_form_card.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen>
    with SingleTickerProviderStateMixin {
  final _team1NameController = TextEditingController(
    text: Localization.t('new_game.team_1'),
  );
  final _team2NameController = TextEditingController(
    text: Localization.t('new_game.team_2'),
  );
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  final _player3Controller = TextEditingController();
  final _player4Controller = TextEditingController();
  GameMode _selectedMode = GameMode.okey101;
  List<String> _knownPlayers = [];

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
    CareerService.getKnownPlayerNames().then((names) {
      if (mounted) setState(() => _knownPlayers = names);
    });
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
          content: Text(
            Localization.t('new_game.player_name_required'),
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
      return;
    }

    // Takım 1: Üst (seat 0) ve Alt (seat 2) - karşılıklı
    // Takım 2: Sağ (seat 1) ve Sol (seat 3) - karşılıklı
    final game = Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      gameMode: _selectedMode,
      team1: Team(
        id: 'team1_${DateTime.now().millisecondsSinceEpoch}',
        name: t1.isNotEmpty ? t1 : 'Takım 1',
        player1: Player(
          id: 'p1_${DateTime.now().millisecondsSinceEpoch}',
          name: p1,
          seatIndex: 0,
        ),
        player2: Player(
          id: 'p3_${DateTime.now().millisecondsSinceEpoch}',
          name: p3,
          seatIndex: 2,
        ),
      ),
      team2: Team(
        id: 'team2_${DateTime.now().millisecondsSinceEpoch}',
        name: t2.isNotEmpty ? t2 : Localization.t('new_game.team_2'),
        player1: Player(
          id: 'p2_${DateTime.now().millisecondsSinceEpoch}',
          name: p2,
          seatIndex: 1,
        ),
        player2: Player(
          id: 'p4_${DateTime.now().millisecondsSinceEpoch}',
          name: p4,
          seatIndex: 3,
        ),
      ),
    );

    if (_selectedMode == GameMode.americano ||
        _selectedMode == GameMode.americanoSolo) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AmericanoGameScreen(game: game)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameScreen(game: game)),
      );
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
          Localization.t('new_game.title'),
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
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          Localization.t('new_game.table_layout'),
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
                      Localization.t('new_game.table_layout_info'),
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Oyun modu seçimi
              GameModeSelector(
                selectedMode: _selectedMode,
                onModeChanged: (mode) => setState(() => _selectedMode = mode),
              ),
              const SizedBox(height: 20),

              // Kayıtlı oyuncular hızlı seçim
              if (_knownPlayers.isNotEmpty)
                QuickPlayerChips(
                  knownPlayers: _knownPlayers,
                  isPlayerSelected: (name) =>
                      _player1Controller.text == name ||
                      _player2Controller.text == name ||
                      _player3Controller.text == name ||
                      _player4Controller.text == name,
                  onPlayerTapped: _fillNextAvailablePlayer,
                ),

              // Takım 1
              TeamFormCard(
                teamController: _team1NameController,
                player1Label: Localization.t('new_game.player_1_top'),
                player2Label: Localization.t('new_game.player_3_bottom'),
                player1Controller: _player1Controller,
                player2Controller: _player3Controller,
                color: AppTheme.lightGreen,
              ),
              const SizedBox(height: 24),

              // Takım 2
              TeamFormCard(
                teamController: _team2NameController,
                player1Label: Localization.t('new_game.player_2_right'),
                player2Label: Localization.t('new_game.player_4_left'),
                player1Controller: _player2Controller,
                player2Controller: _player4Controller,
                color: AppTheme.accentAmber,
              ),
              const SizedBox(height: 24),

              // Mini önizleme
              ListenableBuilder(
                listenable: Listenable.merge([
                  _player1Controller,
                  _player2Controller,
                  _player3Controller,
                  _player4Controller,
                ]),
                builder: (context, _) => TablePreviewWidget(
                  player1Name: _player1Controller.text,
                  player2Name: _player2Controller.text,
                  player3Name: _player3Controller.text,
                  player4Name: _player4Controller.text,
                ),
              ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            Localization.t('new_game.start_game'),
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

  void _fillNextAvailablePlayer(String name) {
    if (_player1Controller.text.isEmpty) {
      _player1Controller.text = name;
    } else if (_player2Controller.text.isEmpty &&
        _player1Controller.text != name) {
      _player2Controller.text = name;
    } else if (_player3Controller.text.isEmpty &&
        _player1Controller.text != name &&
        _player2Controller.text != name) {
      _player3Controller.text = name;
    } else if (_player4Controller.text.isEmpty &&
        _player1Controller.text != name &&
        _player2Controller.text != name &&
        _player3Controller.text != name) {
      _player4Controller.text = name;
    } else {
      _player1Controller.text = name;
    }
    setState(() {});
  }
}
