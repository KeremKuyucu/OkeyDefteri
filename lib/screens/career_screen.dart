import 'package:flutter/material.dart';
import '../models/player_profile_models.dart';
import '../services/career_service.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  bool _isLoading = true;
  List<PlayerProfile> _profiles = [];
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: Galibiyet, 1: Kazanma %, 2: En Az Ceza

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final profiles = await CareerService.getAllProfiles();
    if (mounted) {
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    }
  }

  List<PlayerProfile> get _filteredProfiles {
    var list = _profiles.where((p) {
      if (_searchQuery.trim().isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase().trim());
    }).toList();

    switch (_selectedFilterIndex) {
      case 0: // En çok kazanan
        list.sort((a, b) => b.gamesWon.compareTo(a.gamesWon));
        break;
      case 1: // Kazanma oranı
        list.sort((a, b) => b.winRate.compareTo(a.winRate));
        break;
      case 2: // En az ceza (ortalama)
        list.sort((a, b) => a.averageScore.compareTo(b.averageScore));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          Localization.t('career.title'),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold),
            )
          : _profiles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppTheme.accentGold,
                  backgroundColor: AppTheme.surfaceDark,
                  onRefresh: _loadProfiles,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rekorlar & Masa Liderleri (Hall of Fame)
                        _buildSectionTitle(Localization.t('career.hall_of_fame')),
                        const SizedBox(height: 12),
                        _buildHallOfFame(),
                        const SizedBox(height: 24),

                        // En Uyumlu Eşler (Duo Synergy)
                        _buildSectionTitle(Localization.t('career.best_partners')),
                        const SizedBox(height: 12),
                        _buildTopDuos(),
                        const SizedBox(height: 24),

                        // Arama & Filtreleme
                        _buildSectionTitle(Localization.t('career.player_list')),
                        const SizedBox(height: 12),
                        _buildSearchAndFilters(),
                        const SizedBox(height: 12),

                        // Oyuncu Kartları
                        ..._filteredProfiles.map((p) => _buildPlayerCard(p)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Localization.t('career.no_data_title'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Localization.t('career.no_data_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHallOfFame() {
    // MVP
    final mvp = List<PlayerProfile>.from(_profiles)
      ..sort((a, b) => b.gamesWon.compareTo(a.gamesWon));
    final topWinner = mvp.isNotEmpty && mvp.first.gamesWon > 0 ? mvp.first : null;

    // Okey Üstadı
    final okeyMasters = List<PlayerProfile>.from(_profiles)
      ..sort((a, b) => b.totalOkeyFinishes.compareTo(a.totalOkeyFinishes));
    final topOkey = okeyMasters.isNotEmpty && okeyMasters.first.totalOkeyFinishes > 0
        ? okeyMasters.first
        : null;

    // Ceza Rekortmeni
    final penaltyKings = List<PlayerProfile>.from(_profiles)
      ..sort((a, b) => b.totalPenalties.compareTo(a.totalPenalties));
    final topPenalty = penaltyKings.isNotEmpty && penaltyKings.first.totalPenalties > 0
        ? penaltyKings.first
        : null;

    return Row(
      children: [
        if (topWinner != null)
          Expanded(
            child: _buildFameCard(
              emoji: '👑',
              badge: Localization.t('career.mvp'),
              name: topWinner.name,
              value: '${topWinner.gamesWon} ${Localization.t('stats.wins')}',
              color: AppTheme.accentGold,
            ),
          ),
        if (topWinner != null && (topOkey != null || topPenalty != null))
          const SizedBox(width: 8),
        if (topOkey != null)
          Expanded(
            child: _buildFameCard(
              emoji: '🃏',
              badge: Localization.t('career.okey_master'),
              name: topOkey.name,
              value: '${topOkey.totalOkeyFinishes} Okey',
              color: const Color(0xFFBA68C8),
            ),
          ),
        if (topOkey != null && topPenalty != null) const SizedBox(width: 8),
        if (topPenalty != null)
          Expanded(
            child: _buildFameCard(
              emoji: '💣',
              badge: Localization.t('career.punished_king'),
              name: topPenalty.name,
              value: '${topPenalty.totalPenalties} Ceza',
              color: AppTheme.dangerRed,
            ),
          ),
      ],
    );
  }

  Widget _buildFameCard({
    required String emoji,
    required String badge,
    required String name,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            badge,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDuos() {
    // Tüm ikili kombinasyonlarını topla
    final duos = <String, _DuoRecord>{};

    for (final p in _profiles) {
      for (final partner in p.bestPartners) {
        if (partner.gamesTogether < 1) continue;
        final key = [p.name, partner.partnerName]..sort();
        final duoKey = '${key[0]} & ${key[1]}';

        if (!duos.containsKey(duoKey)) {
          duos[duoKey] = _DuoRecord(
            player1: key[0],
            player2: key[1],
            gamesTogether: partner.gamesTogether,
            winsTogether: partner.winsTogether,
          );
        }
      }
    }

    final duoList = duos.values.toList()
      ..sort((a, b) {
        final rateCmp = b.winRate.compareTo(a.winRate);
        if (rateCmp != 0) return rateCmp;
        return b.gamesTogether.compareTo(a.gamesTogether);
      });

    if (duoList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          Localization.t('career.no_duo_yet'),
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: duoList.take(6).length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final duo = duoList[index];
          return Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A24), Color(0xFF16281B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.lightGreen.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handshake_rounded,
                        color: AppTheme.lightGreen, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${duo.player1} & ${duo.player2}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '%${duo.winRate.toStringAsFixed(0)} Uyum',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${duo.winsTogether}/${duo.gamesTogether} Galibiyet',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: Localization.t('career.search_hint'),
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
            filled: true,
            fillColor: AppTheme.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(0, Localization.t('career.filter_wins')),
              const SizedBox(width: 8),
              _buildFilterChip(1, Localization.t('career.filter_rate')),
              const SizedBox(width: 8),
              _buildFilterChip(2, Localization.t('career.filter_least_penalty')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final selected = _selectedFilterIndex == index;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? Colors.black : AppTheme.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      selectedColor: AppTheme.accentGold,
      backgroundColor: AppTheme.surfaceCard,
      onSelected: (_) => setState(() => _selectedFilterIndex = index),
    );
  }

  Widget _buildPlayerCard(PlayerProfile player) {
    final topPartner = player.topPartner;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.accentGold.withValues(alpha: 0.15),
                child: Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${player.gamesPlayed} Maç • ${player.gamesWon} Galibiyet (%${player.winRate.toStringAsFixed(0)})',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.lightGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Ort. ${player.averageScore.toStringAsFixed(0)}p',
                  style: const TextStyle(
                    color: AppTheme.lightGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.surfaceCardLight, height: 1),
          const SizedBox(height: 10),

          // İstatistik ikonları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statMiniBadge('🎯 İşlek', '${player.totalIslekAtti}', AppTheme.accentAmber),
              _statMiniBadge('🃏 Okey', '${player.totalOkeyFinishes}', const Color(0xFFBA68C8)),
              _statMiniBadge('💣 Ceza', '${player.totalPenalties}', AppTheme.dangerRed),
            ],
          ),

          if (topPartner != null && topPartner.gamesTogether > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCardLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('🤝', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    'En uyumlu eş: ',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                  Text(
                    '${topPartner.partnerName} (%${topPartner.winRate.toStringAsFixed(0)} galibiyet)',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statMiniBadge(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DuoRecord {
  final String player1;
  final String player2;
  final int gamesTogether;
  final int winsTogether;

  _DuoRecord({
    required this.player1,
    required this.player2,
    required this.gamesTogether,
    required this.winsTogether,
  });

  double get winRate =>
      gamesTogether > 0 ? (winsTogether / gamesTogether) * 100 : 0.0;
}
