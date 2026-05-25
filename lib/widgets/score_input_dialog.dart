import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class CalculatorDialog extends StatefulWidget {
  final String title;

  const CalculatorDialog({super.key, required this.title});

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  final List<int> _numbers = [];
  String _currentInput = '';

  int get _total => _numbers.fold(0, (sum, n) => sum + n);

  void _addNumber() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _numbers.add(int.parse(_currentInput));
        _currentInput = '';
      });
    }
  }

  void _removeLastNumber() {
    if (_numbers.isNotEmpty) {
      setState(() {
        _numbers.removeLast();
      });
    }
  }

  void _onDigit(String digit) {
    setState(() {
      _currentInput += digit;
    });
  }

  void _onBackspace() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _currentInput = '';
      _numbers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  color: AppTheme.accentGold,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
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
            const SizedBox(height: 16),

            // Girilen sayılar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightGreen.withValues(alpha: 0.2),
                ),
              ),
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (int i = 0; i < _numbers.length; i++)
                      Chip(
                        label: Text(
                          '${_numbers[i]}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: AppTheme.surfaceCardLight,
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppTheme.dangerRed,
                        ),
                        onDeleted: () {
                          setState(() => _numbers.removeAt(i));
                        },
                        side: BorderSide(
                          color: AppTheme.lightGreen.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Mevcut giriş ve toplam
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCardLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentInput.isEmpty ? '0' : _currentInput,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Σ $_total',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Numpad
            _buildNumpad(),

            const SizedBox(height: 16),

            // Onay butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Mevcut girişi de ekle
                  int finalTotal = _total;
                  if (_currentInput.isNotEmpty) {
                    finalTotal += int.parse(_currentInput);
                  }
                  Navigator.pop(context, finalTotal);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'Onayla (${_total + (_currentInput.isNotEmpty ? int.tryParse(_currentInput) ?? 0 : 0)} puan)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightGreen,
                  foregroundColor: Colors.white,
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
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          children: [
            _numButton('1'),
            _numButton('2'),
            _numButton('3'),
            _actionButton(
              Icons.backspace_outlined,
              _onBackspace,
              AppTheme.warningOrange,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _numButton('4'),
            _numButton('5'),
            _numButton('6'),
            _actionButton(
              Icons.add_circle_outline,
              _addNumber,
              AppTheme.lightGreen,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _numButton('7'),
            _numButton('8'),
            _numButton('9'),
            _actionButton(
              Icons.remove_circle_outline,
              _removeLastNumber,
              AppTheme.dangerRed,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _actionButton(Icons.clear_all, _onClear, AppTheme.textMuted),
            _numButton('0'),
            Expanded(flex: 2, child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _numButton(String digit) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onDigit(digit),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                digit,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skor giriş dialogu
class ScoreInputDialog extends StatefulWidget {
  final Player player;
  final int currentRound;
  final List<Player> allPlayers;

  const ScoreInputDialog({
    super.key,
    required this.player,
    required this.currentRound,
    required this.allPlayers,
  });

  @override
  State<ScoreInputDialog> createState() => _ScoreInputDialogState();
}

class _ScoreInputDialogState extends State<ScoreInputDialog> {
  final TextEditingController _manualController = TextEditingController();
  late bool _isOkeyFinish;

  @override
  void initState() {
    super.initState();
    // Eğer aynı elde herhangi biri okey atarak bittiyse varsayılan olarak true olsun
    _isOkeyFinish = widget.allPlayers.any(
      (p) => p.scores.any(
        (s) =>
            s.roundNumber == widget.currentRound &&
            (s.type == ScoreType.okeyAtarakBitti || s.type == ScoreType.okeyAtarakEldenBitti),
      ),
    );
  }

  void _addScore(
    ScoreType type, {
    int? manualPoints,
    String? causedByPlayerId,
    bool isCauserCiftli = false,
  }) {
    final points = manualPoints ?? type.defaultPoints;
    // Çiftli otomatik uygulanır: elde kalan taşlar için isCiftliGidiyor'a bak
    final isCiftli =
        type == ScoreType.eldeKalanTaslar && widget.player.isCiftliGidiyor;
    final isOkey =
        !type.isFinishType &&
        _isOkeyFinish; // Sadece bitirme olmayan skorlar okey çarpanından etkilenir

    final entry = ScoreEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      points: points,
      isCiftli: isCiftli,
      isOkeyFinish: isOkey,
      isCauserCiftli: isCauserCiftli,
      timestamp: DateTime.now(),
      roundNumber: widget.currentRound,
      causedByPlayerId: causedByPlayerId,
    );
    Navigator.pop(context, entry);
  }

  /// hasCausedBy türleri için: önce kimin yaptığını sor, sonra skoru ekle
  Future<void> _addScoreWithCausedBy(
    ScoreType type, {
    int? manualPoints,
  }) async {
    if (!type.hasCausedBy) {
      _addScore(type, manualPoints: manualPoints);
      return;
    }

    // Sadece rakipleri göster (kendi takımı arkadaşı hariç)
    // Karşılıklı oturanlar aynı takımdır (0 ve 2, 1 ve 3).
    // Yani seatIndex'in 2'ye bölümünden kalanı farklı olanlar rakiptir.
    final opponents = widget.allPlayers
        .where((p) => p.seatIndex % 2 != widget.player.seatIndex % 2)
        .toList();

    final selectedPlayerId = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.causedByLabel,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...opponents.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context, p.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  p.name.isNotEmpty
                                      ? p.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.textMuted,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'İptal',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedPlayerId != null && mounted) {
      final causer = widget.allPlayers.firstWhere(
        (p) => p.id == selectedPlayerId,
      );
      final isCauserCiftli = causer.isCiftliGidiyor;
      _addScore(
        type,
        manualPoints: manualPoints,
        causedByPlayerId: selectedPlayerId,
        isCauserCiftli: isCauserCiftli,
      );
    }
  }

  Future<void> _showManualInput(ScoreType type) async {
    if (type == ScoreType.eldeKalanTaslar) {
      // Hesap makinesi veya manuel giriş seçeneği
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Taş Hesaplama Yöntemi',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _methodButton(
                  icon: Icons.calculate_rounded,
                  label: 'Hesap Makinesi',
                  subtitle: 'Taşları tek tek girin, otomatik toplanır',
                  onTap: () => Navigator.pop(context, 'calculator'),
                ),
                const SizedBox(height: 10),
                _methodButton(
                  icon: Icons.edit_rounded,
                  label: 'Direkt Giriş',
                  subtitle: 'Toplam puanı kendiniz yazın',
                  onTap: () => Navigator.pop(context, 'manual'),
                ),
              ],
            ),
          ),
        ),
      );

      if (choice == null) return;

      if (choice == 'calculator') {
        if (!mounted) return;
        final calcResult = await showDialog<int>(
          context: context,
          builder: (context) =>
              const CalculatorDialog(title: 'Kalan Taşları Hesapla'),
        );
        if (calcResult != null && mounted) {
          _addScore(type, manualPoints: calcResult);
        }
      } else {
        if (!mounted) return;
        await _showDirectInput(type);
      }
    } else {
      if (!mounted) return;
      await _showDirectInput(type);
    }
  }

  Future<void> _showDirectInput(ScoreType type) async {
    _manualController.clear();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          type.label,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _manualController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Puan giriniz',
                suffixText: 'puan',
                suffixStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
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
              final value = int.tryParse(_manualController.text);
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (type.hasCausedBy) {
        _addScoreWithCausedBy(type, manualPoints: result);
      } else {
        _addScore(type, manualPoints: result);
      }
    }
  }

  Widget _methodButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.lightGreen, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Oyuncu başlığı
              Row(
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
                        widget.player.name.isNotEmpty
                            ? widget.player.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.player.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Puan: ${widget.player.totalScore} • El ${widget.currentRound}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
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
              const SizedBox(height: 12),

              // Çiftli toggle göstergesi
              if (widget.player.isCiftliGidiyor)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.double_arrow_rounded,
                        color: AppTheme.accentGold,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Çiftli Gidiyor — Taş puanı ×2 uygulanacak',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // BİTİRME bölümü
              _buildSectionDivider('BİTİRME'),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.normalBitti,
                color: AppTheme.successGreen,
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.eldenBitti,
                color: AppTheme.successGreen,
                icon: Icons.emoji_events_rounded,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.okeyAtarakBitti,
                color: const Color(0xFF7E57C2),
                icon: Icons.style_rounded,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.okeyAtarakEldenBitti,
                color: const Color(0xFF673AB7),
                icon: Icons.military_tech_rounded,
              ),
              const SizedBox(height: 16),

              // CEZA bölümü
              _buildSectionDivider('CEZA'),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Rakip Okey Atarak Bitirdi\n(Cezalar x2)',
                    style: TextStyle(
                      color: AppTheme.warningOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isOkeyFinish,
                  onChanged: (v) => setState(() => _isOkeyFinish = v),
                  activeColor: AppTheme.warningOrange,
                ),
              ),
              _buildScoreButton(
                ScoreType.islekAtti,
                color: AppTheme.warningOrange,
                icon: Icons.gps_fixed_rounded,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.okeyAtti,
                color: AppTheme.warningOrange,
                icon: Icons.style_rounded,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.okeyiniAldilar,
                color: AppTheme.warningOrange,
                icon: Icons.style_rounded,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.yanlisElActi,
                color: AppTheme.dangerRed,
                icon: Icons.error_outline_rounded,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.acamadi,
                color: AppTheme.dangerRed,
                icon: Icons.block_rounded,
              ),
              const SizedBox(height: 16),

              // MANUEL GİRİŞ bölümü
              _buildSectionDivider('MANUEL GİRİŞ'),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.attigiTasiAldilar,
                color: AppTheme.accentAmber,
                icon: Icons.swap_horiz_rounded,
                isManual: true,
              ),
              const SizedBox(height: 8),
              _buildScoreButton(
                ScoreType.eldeKalanTaslar,
                color: AppTheme.accentAmber,
                icon: Icons.back_hand_rounded,
                isManual: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppTheme.lightGreen.withValues(alpha: 0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppTheme.lightGreen.withValues(alpha: 0.2)),
        ),
      ],
    );
  }

  Widget _buildScoreButton(
    ScoreType type, {
    required Color color,
    required IconData icon,
    bool isManual = false,
  }) {
    final isNegative = type.defaultPoints < 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (isManual) {
            _showManualInput(type);
          } else if (type.hasCausedBy) {
            _addScoreWithCausedBy(type);
          } else {
            _addScore(type);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${type.emoji} ${type.label}',
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isManual)
                      Text(
                        '${isNegative ? "" : "+"}${type.defaultPoints} puan',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    if (isManual)
                      Text(
                        type == ScoreType.eldeKalanTaslar
                            ? 'Hesap makinesi veya direkt giriş'
                            : 'Puanı manuel giriniz',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                isManual ? Icons.edit_rounded : Icons.add_circle_rounded,
                color: color.withValues(alpha: 0.7),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }
}
