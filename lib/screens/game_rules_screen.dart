import 'package:flutter/material.dart';
import '../models/game_rules_models.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class GameRulesScreen extends StatefulWidget {
  final int initialTabIndex;

  const GameRulesScreen({super.key, this.initialTabIndex = 0});

  @override
  State<GameRulesScreen> createState() => _GameRulesScreenState();
}

class _GameRulesScreenState extends State<GameRulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              color: AppTheme.accentGold,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              Localization.t('home.rules'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          indicatorWeight: 3,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: Localization.t('rules.tab_101')),
            Tab(text: Localization.t('rules.tab_americano')),
            Tab(text: Localization.t('rules.tab_classic')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _build101Rules(),
          _buildAmericanoRules(),
          _buildClassicRules(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 101 Okey Kuralları
  // ──────────────────────────────────────────────
  Widget _build101Rules() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(
          title: Localization.t('rules.okey101_objective_title'),
          icon: Icons.flag_rounded,
          accentColor: AppTheme.lightGreen,
          content: Localization.t('rules.okey101_objective_desc'),
        ),
        _sectionHeader(Localization.t('rules.sec_opening')),
        _ruleTile(
          title: Localization.t('rules.okey101_serial_title'),
          badge: Localization.t('rules.okey101_serial_badge'),
          badgeColor: AppTheme.lightGreen,
          description: Localization.t('rules.okey101_serial_desc'),
        ),
        _ruleTile(
          title: Localization.t('rules.okey101_pairs_title'),
          badge: Localization.t('rules.okey101_pairs_badge'),
          badgeColor: AppTheme.accentAmber,
          description: Localization.t('rules.okey101_pairs_desc'),
        ),
        _ruleTile(
          title: Localization.t('rules.okey101_fold_title'),
          badge: Localization.t('rules.okey101_fold_badge'),
          badgeColor: AppTheme.warningOrange,
          description: Localization.t('rules.okey101_fold_desc'),
        ),
        _sectionHeader(Localization.t('rules.sec_ground_and_meld')),
        _ruleTile(
          title: Localization.t('rules.okey101_ground_title'),
          badge: Localization.t('rules.okey101_ground_badge'),
          badgeColor: AppTheme.accentGold,
          description: Localization.t('rules.okey101_ground_desc'),
        ),
        _ruleTile(
          title: Localization.t('rules.okey101_meld_title'),
          badge: Localization.t('rules.okey101_meld_badge'),
          badgeColor: AppTheme.lightGreen,
          description: Localization.t('rules.okey101_meld_desc'),
        ),
        _sectionHeader(Localization.t('rules.sec_finishes')),
        _scoreRow(
          Localization.t('rules.score_normal_finish'),
          Localization.t('rules.pts_minus_101'),
          AppTheme.lightGreen,
        ),
        _scoreRow(
          Localization.t('rules.score_hand_finish'),
          Localization.t('rules.pts_minus_202'),
          AppTheme.lightGreen,
        ),
        _scoreRow(
          Localization.t('rules.score_okey_finish'),
          Localization.t('rules.pts_minus_202'),
          AppTheme.lightGreen,
        ),
        _scoreRow(
          Localization.t('rules.score_okey_hand_finish'),
          Localization.t('rules.pts_minus_404'),
          AppTheme.lightGreen,
        ),
        _sectionHeader(Localization.t('rules.sec_penalties')),
        _scoreRow(
          Localization.t('rules.score_cant_open'),
          Localization.t('rules.pts_plus_202'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_islek_penalty'),
          Localization.t('rules.pts_plus_101'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_okey_penalty'),
          Localization.t('rules.pts_plus_101'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_wrong_hand'),
          Localization.t('rules.pts_plus_101'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_remaining_tiles'),
          Localization.t('rules.pts_remaining_sum'),
          AppTheme.dangerRed,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Americano Okey Kuralları
  // ──────────────────────────────────────────────
  Widget _buildAmericanoRules() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(
          title: Localization.t('rules.americano_about_title'),
          icon: Icons.style_rounded,
          accentColor: AppTheme.accentGold,
          content: Localization.t('rules.americano_about_desc'),
        ),
        _sectionHeader(Localization.t('rules.sec_scoring_rules')),
        _ruleTile(
          title: Localization.t('rules.americano_finish_title'),
          badge: Localization.t('rules.americano_finish_badge'),
          badgeColor: AppTheme.lightGreen,
          description: Localization.t('rules.americano_finish_desc'),
        ),
        _ruleTile(
          title: Localization.t('rules.americano_team_title'),
          badge: Localization.t('rules.americano_team_badge'),
          badgeColor: AppTheme.accentGold,
          description: Localization.t('rules.americano_team_desc'),
        ),
        _ruleTile(
          title: Localization.t('rules.americano_okey_hand_title'),
          badge: Localization.t('rules.americano_okey_hand_badge'),
          badgeColor: AppTheme.dangerRed,
          description: Localization.t('rules.americano_okey_hand_desc'),
        ),
        _ruleTile(
          title: Localization.t('rules.americano_ground_title'),
          badge: Localization.t('rules.americano_ground_badge'),
          badgeColor: AppTheme.accentAmber,
          description: Localization.t('rules.americano_ground_desc'),
        ),
        _sectionHeader(Localization.t('rules.sec_penalties')),
        _scoreRow(
          Localization.t('rules.score_americano_okey_hand'),
          Localization.t('rules.pts_plus_30_hand'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_americano_islek'),
          Localization.t('rules.pts_plus_50'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_americano_cheat'),
          Localization.t('rules.pts_plus_50'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_americano_wrong_hand'),
          Localization.t('rules.pts_plus_50'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_americano_okey_throw'),
          Localization.t('rules.pts_plus_50'),
          AppTheme.dangerRed,
        ),
        _scoreRow(
          Localization.t('rules.score_americano_islek_finish'),
          Localization.t('rules.pts_plus_100'),
          AppTheme.dangerRed,
        ),
        _sectionHeader(Localization.t('rules.sec_americano_rounds')),
        ...AmericanoRound.rounds.map((round) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.surfaceCardLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${round.roundNumber}',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(round.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      round.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 30),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Klasik (Normal) Okey Kuralları
  // ──────────────────────────────────────────────
  Widget _buildClassicRules() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(
          title: Localization.t('rules.classic_about_title'),
          icon: Icons.casino_rounded,
          accentColor: AppTheme.accentAmber,
          content: Localization.t('rules.classic_about_desc'),
        ),
        _sectionHeader(Localization.t('rules.sec_classic_rules')),
        _ruleTile(
          title: Localization.t('rules.classic_deal_title'),
          badge: Localization.t('rules.classic_deal_badge'),
          badgeColor: AppTheme.lightGreen,
          description: Localization.t('rules.classic_deal_desc'),
        ),
        _ruleTile(
          title: Localization.t('rules.classic_pairs_title'),
          badge: Localization.t('rules.classic_pairs_badge'),
          badgeColor: AppTheme.accentAmber,
          description: Localization.t('rules.classic_pairs_desc'),
        ),
        _sectionHeader(Localization.t('rules.sec_classic_scores')),
        _scoreRow(
          Localization.t('rules.score_classic_normal'),
          Localization.t('rules.pts_minus_1'),
          AppTheme.lightGreen,
        ),
        _scoreRow(
          Localization.t('rules.score_classic_okey'),
          Localization.t('rules.pts_minus_2'),
          AppTheme.lightGreen,
        ),
        _scoreRow(
          Localization.t('rules.score_classic_pairs'),
          Localization.t('rules.pts_minus_2'),
          AppTheme.lightGreen,
        ),
        _scoreRow(
          Localization.t('rules.score_classic_both'),
          Localization.t('rules.pts_minus_4'),
          AppTheme.accentGold,
        ),
        _scoreRow(
          Localization.t('rules.score_classic_draw'),
          Localization.t('rules.pts_zero_unchanged'),
          AppTheme.textMuted,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Yardımcı Widget'lar
  // ──────────────────────────────────────────────
  Widget _infoCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accentGold,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _ruleTile({
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceCardLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceCardLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
