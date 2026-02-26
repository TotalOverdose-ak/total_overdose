import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/market_recommendation_provider.dart';
import '../providers/language_provider.dart';
import '../services/market_recommendation_service.dart';
import '../services/export_price_service.dart';
import '../services/osrm_distance_service.dart';
import '../theme/app_colors.dart';

class MarketRecommendationScreen extends StatefulWidget {
  const MarketRecommendationScreen({super.key});

  @override
  State<MarketRecommendationScreen> createState() =>
      _MarketRecommendationScreenState();
}

class _MarketRecommendationScreenState
    extends State<MarketRecommendationScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final rec = context.watch<MarketRecommendationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Text(
          '🎯 ${lang.tr('market_rec_title')}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Subtitle ─────────────────────────────────────────
            Text(
              lang.tr('market_rec_subtitle'),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),

            // ── Input Card ──────────────────────────────────────────────
            _buildInputCard(context, lang, rec),
            const SizedBox(height: 16),

            // ── Analyze Button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: rec.isLoading
                    ? null
                    : () => rec.analyze(language: lang.currentLanguage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                icon: rec.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.analytics_rounded, size: 22),
                label: Text(
                  rec.isLoading
                      ? lang.tr('analyzing')
                      : lang.tr('find_best_market'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            // ── Error ───────────────────────────────────────────────────
            if (rec.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  rec.error!,
                  style: GoogleFonts.poppins(
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],

            // ── Top Recommendation Hero Card ────────────────────────────
            if (rec.topRecommendation != null) ...[
              const SizedBox(height: 20),
              _buildHeroCard(context, lang, rec.topRecommendation!),
            ],

            // ── AI Summary ──────────────────────────────────────────────
            if (rec.aiSummary != null) ...[
              const SizedBox(height: 16),
              _buildAISummaryCard(lang, rec.aiSummary!),
            ],

            // ── Score Breakdown (Top Market) ────────────────────────────
            if (rec.topRecommendation != null) ...[
              const SizedBox(height: 16),
              _buildScoreBreakdown(lang, rec.topRecommendation!),
            ],

            // ── Transit Risk Card ───────────────────────────────────────
            if (rec.topRecommendation != null &&
                rec.topRecommendation!.transitHours > 0) ...[
              const SizedBox(height: 16),
              _buildTransitRiskCard(lang, rec.topRecommendation!),
            ],

            // ── Real Road Distance Card (OSRM API — FREE) ──────────────
            if (rec.topMarketRoute != null) ...[
              const SizedBox(height: 16),
              _buildRealDistanceCard(lang, rec.topMarketRoute!),
            ],

            // ── Export Price Card (Frankfurter API — FREE) ──────────────
            if (rec.exportPriceResult != null) ...[
              const SizedBox(height: 16),
              _buildExportPriceCard(lang, rec.exportPriceResult!),
            ],

            // ── "Why This Market?" Explainability Panel ─────────────────
            if (rec.topRecommendation != null) ...[
              const SizedBox(height: 16),
              _buildMarketExplainability(lang, rec.topRecommendation!),
            ],

            // ── All Markets Ranked ──────────────────────────────────────
            if (rec.rankedMarkets.length > 1) ...[
              const SizedBox(height: 20),
              Text(
                '📊 ${lang.tr('all_markets_ranked')}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lang.tr('ranked_explanation'),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              ...rec.rankedMarkets.asMap().entries.map(
                (entry) => _buildMarketRankCard(
                  context,
                  lang,
                  entry.value,
                  entry.key + 1,
                  isTop: entry.key == 0,
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInputCard(
    BuildContext context,
    LanguageProvider lang,
    MarketRecommendationProvider rec,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop selection
          Text(
            '🌾 ${lang.tr('select_crop_to_sell')}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MarketRecommendationProvider.availableCrops.map((crop) {
              final isSelected = rec.selectedCrop == crop;
              return GestureDetector(
                onTap: () => rec.setCrop(crop),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    '${_cropEmoji(crop)} $crop',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Location selection
          Text(
            '📍 ${lang.tr('your_location')}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // State dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButton<String>(
                    value:
                        MarketRecommendationProvider.stateCities.containsKey(
                          rec.userState,
                        )
                        ? rec.userState
                        : 'Maharashtra',
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                    items: MarketRecommendationProvider.stateCities.keys
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Text(
                              state,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (state) {
                      if (state != null) {
                        final cities =
                            MarketRecommendationProvider.stateCities[state]!;
                        rec.setUserLocation(cities.first, state);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // City dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButton<String>(
                    value:
                        (MarketRecommendationProvider.stateCities[rec
                                    .userState] ??
                                [])
                            .contains(rec.userCity)
                        ? rec.userCity
                        : (MarketRecommendationProvider.stateCities[rec
                                      .userState] ??
                                  ['Nagpur'])
                              .first,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                    items:
                        (MarketRecommendationProvider.stateCities[rec
                                    .userState] ??
                                ['Nagpur'])
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(
                                  city,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (city) {
                      if (city != null) {
                        rec.setUserLocation(city, rec.userState);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO RECOMMENDATION CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeroCard(
    BuildContext context,
    LanguageProvider lang,
    MarketScore top,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🏆 ${lang.tr('recommended_market')}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Grade badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _gradeColor(top.grade).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Grade ${top.grade}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Market name
          Text(
            '${top.commodityEmoji} ${top.market} Mandi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${top.district}, ${top.state}',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Key metrics row
          Row(
            children: [
              _heroMetric(
                lang.tr('expected_net'),
                '₹${top.netProfit.toStringAsFixed(0)}',
                '/quintal',
              ),
              const SizedBox(width: 24),
              _heroMetric(
                lang.tr('modal_price'),
                '₹${top.modalPrice.toStringAsFixed(0)}',
                '/quintal',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Secondary metrics
          Row(
            children: [
              _heroChip(
                Icons.local_shipping_rounded,
                '${lang.tr('travel')}: ₹${top.estimatedTravelCost.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 10),
              _heroChip(
                Icons.trending_up_rounded,
                '${top.regionalDiffPercent >= 0 ? '+' : ''}${top.regionalDiffPercent.toStringAsFixed(1)}% vs avg',
              ),
              const SizedBox(width: 10),
              _heroChip(
                Icons.show_chart_rounded,
                '${lang.tr('volatility')}: ${(top.volatility * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Reasons
          if (top.reasons.isNotEmpty)
            ...top.reasons
                .take(3)
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅ ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            r,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

          if (top.warnings.isNotEmpty)
            ...top.warnings
                .take(2)
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            w,
                            style: GoogleFonts.poppins(
                              color: Colors.yellow.shade100,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _heroMetric(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                unit,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AI SUMMARY CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAISummaryCard(LanguageProvider lang, String summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                lang.tr('ai_market_advice'),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCORE BREAKDOWN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildScoreBreakdown(LanguageProvider lang, MarketScore top) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 ${lang.tr('score_breakdown')}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${lang.tr('overall_score')}: ${top.overallScore.toStringAsFixed(0)}/100',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          _scoreBar(
            lang.tr('net_price_score'),
            top.netPriceScore,
            '40%',
            const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 10),
          _scoreBar(
            lang.tr('regional_advantage'),
            top.regionalScore,
            '25%',
            const Color(0xFF1565C0),
          ),
          const SizedBox(height: 10),
          _scoreBar(
            lang.tr('price_stability'),
            top.stabilityScore,
            '20%',
            const Color(0xFFE65100),
          ),
          const SizedBox(height: 10),
          _scoreBar(
            lang.tr('low_competition'),
            top.competitionScore,
            '15%',
            const Color(0xFF6A1B9A),
          ),
        ],
      ),
    );
  }

  Widget _scoreBar(String label, double score, String weight, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label ($weight)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
            Text(
              '${score.toStringAsFixed(0)}/100',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RANKED MARKET CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMarketRankCard(
    BuildContext context,
    LanguageProvider lang,
    MarketScore m,
    int rank, {
    bool isTop = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTop ? AppColors.mintGreen : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isTop
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Rank badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isTop
                      ? const Color(0xFF2E7D32)
                      : rank <= 3
                      ? const Color(0xFF4CAF50)
                      : AppColors.textLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Market name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${m.commodityEmoji} ${m.market}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${m.district}, ${m.state}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _gradeColor(m.grade).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${m.overallScore.toStringAsFixed(0)} pts',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _gradeColor(m.grade),
                      ),
                    ),
                  ),
                  Text(
                    m.gradeLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Metrics row
          Row(
            children: [
              _metricChip(
                '💰',
                '₹${m.netProfit.toStringAsFixed(0)}',
                lang.tr('net'),
              ),
              const SizedBox(width: 10),
              _metricChip(
                '📊',
                '₹${m.modalPrice.toStringAsFixed(0)}',
                lang.tr('modal'),
              ),
              const SizedBox(width: 10),
              _metricChip(
                '🚛',
                '₹${m.estimatedTravelCost.toStringAsFixed(0)}',
                lang.tr('travel'),
              ),
              const SizedBox(width: 10),
              _metricChip(
                '📉',
                '${(m.volatility * 100).toStringAsFixed(0)}%',
                lang.tr('vol'),
              ),
            ],
          ),

          // Top reason
          if (m.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '✅ ${m.reasons.first}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
          if (m.warnings.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '⚠️ ${m.warnings.first}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricChip(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRANSIT RISK CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTransitRiskCard(LanguageProvider lang, MarketScore top) {
    final bool isHighRisk = top.spoilageRiskPercent > 15;
    final bool isMediumRisk = top.spoilageRiskPercent > 5;
    final Color riskColor = isHighRisk
        ? AppColors.riskHigh
        : isMediumRisk
        ? AppColors.riskMedium
        : AppColors.riskLow;
    final String riskEmoji = isHighRisk
        ? '🔴'
        : isMediumRisk
        ? '🟡'
        : '🟢';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚛', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lang.tr('transit_risk'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$riskEmoji ${top.spoilageRiskPercent.toStringAsFixed(1)}% loss',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Transit details row
          Row(
            children: [
              _transitMetric(
                '⏱️',
                '${top.transitHours.toStringAsFixed(1)}h',
                lang.tr('transit_time'),
              ),
              const SizedBox(width: 16),
              _transitMetric(
                top.isPerishable ? '🥬' : '🌾',
                top.isPerishable
                    ? lang.tr('perishable')
                    : lang.tr('non_perishable'),
                lang.tr('crop_type'),
              ),
              const SizedBox(width: 16),
              _transitMetric(
                '📉',
                '~${top.spoilageRiskPercent.toStringAsFixed(1)}%',
                lang.tr('est_spoilage'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Visual risk bar
          Row(
            children: [
              Text(
                lang.tr('spoilage_risk'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (top.spoilageRiskPercent / 50).clamp(0.0, 1.0),
                    backgroundColor: riskColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(riskColor),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${top.spoilageRiskPercent.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: riskColor,
                ),
              ),
            ],
          ),

          // Advisory
          if (isHighRisk) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.riskHigh.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lang.tr('high_spoilage_warning'),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.riskHigh,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _transitMetric(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // "WHY THIS MARKET?" EXPLAINABILITY PANEL
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMarketExplainability(LanguageProvider lang, MarketScore top) {
    // Build structured reasoning from the data
    final reasons = <_MarketExplainPoint>[];

    // 1. Net price reasoning
    reasons.add(
      _MarketExplainPoint(
        icon: '💰',
        category: lang.tr('price_advantage'),
        detail:
            '₹${top.netProfit.toStringAsFixed(0)}/q after ₹${top.estimatedTravelCost.toStringAsFixed(0)} travel cost',
        score: top.netPriceScore,
        weight: '40%',
        isStrong: top.netPriceScore >= 70,
      ),
    );

    // 2. Regional advantage
    reasons.add(
      _MarketExplainPoint(
        icon: '📊',
        category: lang.tr('regional_advantage'),
        detail:
            '${top.regionalDiffPercent >= 0 ? '+' : ''}${top.regionalDiffPercent.toStringAsFixed(1)}% vs ₹${top.regionalAvg.toStringAsFixed(0)} regional avg',
        score: top.regionalScore,
        weight: '25%',
        isStrong: top.regionalScore >= 70,
      ),
    );

    // 3. Price stability
    reasons.add(
      _MarketExplainPoint(
        icon: '📈',
        category: lang.tr('price_stability'),
        detail:
            '${(top.volatility * 100).toStringAsFixed(0)}% volatility — ${top.volatility < 0.1
                ? 'very stable'
                : top.volatility < 0.2
                ? 'stable'
                : 'volatile'}',
        score: top.stabilityScore,
        weight: '20%',
        isStrong: top.stabilityScore >= 70,
      ),
    );

    // 4. Competition
    reasons.add(
      _MarketExplainPoint(
        icon: '🏪',
        category: lang.tr('low_competition'),
        detail:
            '${top.arrivalCount} arrivals/traders — ${top.arrivalCount < 5 ? 'less crowded' : 'competitive'}',
        score: top.competitionScore,
        weight: '15%',
        isStrong: top.competitionScore >= 70,
      ),
    );

    // 5. Transit (if available)
    if (top.transitHours > 0) {
      reasons.add(
        _MarketExplainPoint(
          icon: '🚛',
          category: lang.tr('transit_factor'),
          detail:
              '${top.transitHours.toStringAsFixed(1)}h travel, ~${top.spoilageRiskPercent.toStringAsFixed(1)}% spoilage risk',
          score: top.spoilageRiskPercent < 5
              ? 85
              : top.spoilageRiskPercent < 15
              ? 55
              : 25,
          weight: 'Info',
          isStrong: top.spoilageRiskPercent < 5,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.tr('why_this_market'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      lang.tr('explainability_subtitle'),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Overall verdict
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _gradeColor(top.grade).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${top.overallScore.toStringAsFixed(0)}/100',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _gradeColor(top.grade),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Each reasoning factor
          ...reasons.map((r) => _buildExplainRow(r)),

          // Warnings footer
          if (top.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            ...top.warnings
                .take(3)
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            w,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildExplainRow(_MarketExplainPoint point) {
    final Color barColor = point.isStrong
        ? const Color(0xFF2E7D32)
        : point.score >= 50
        ? AppColors.riskMedium
        : AppColors.riskHigh;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${point.category} (${point.weight})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '${point.score.toStringAsFixed(0)}/100',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  point.detail,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (point.score / 100).clamp(0.0, 1.0),
                    backgroundColor: barColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(barColor),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REAL ROAD DISTANCE CARD (OSRM API — FREE, NO KEY)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRealDistanceCard(LanguageProvider lang, RouteInfo route) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🛣️ Real Road Distance (OSRM Live)',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.gps_fixed, color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route.fromCity} → ${route.toCity}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _osrmChip(Icons.straighten, route.distanceLabel),
                        const SizedBox(width: 10),
                        _osrmChip(Icons.access_time, route.durationLabel),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _osrmChip(
                      Icons.local_shipping,
                      'Est. Transport: ₹${route.estimatedTransportCost.toStringAsFixed(0)}/quintal',
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🗺️', style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by OSRM — Real road routing, not straight-line',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _osrmChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPORT PRICE CARD (Frankfurter API — FREE, NO KEY)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildExportPriceCard(
    LanguageProvider lang,
    ExportPriceResult export,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade800, Colors.orange.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🌍 Export Price Calculator (Live Rates)',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Export demand badge
          Row(
            children: [
              Text(
                '${export.demandEmoji} Export Demand: ${export.exportDemand}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${export.exportPremiumPercent.toStringAsFixed(0)}% premium',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price comparison
          Row(
            children: [
              Expanded(
                child: _exportMetric(
                  'Domestic',
                  '₹${export.domesticPriceInr.toStringAsFixed(0)}',
                  '/quintal',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '→',
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
              ),
              Expanded(
                child: _exportMetric(
                  'Export (USD)',
                  '\$${export.exportPriceUsd.toStringAsFixed(2)}',
                  '/quintal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _exportMetric(
                  'Export Price (INR)',
                  '₹${export.exportPriceInr.toStringAsFixed(0)}',
                  '/quintal',
                ),
              ),
              Expanded(
                child: _exportMetric(
                  'International (USD)',
                  '\$${export.exportPriceUsdPerTon.toStringAsFixed(0)}',
                  '/metric ton',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('📦', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Major Markets: ${export.majorMarkets}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Exchange rates from European Central Bank (Frankfurter API) • ${export.rates.date}',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 9.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportMetric(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFF2E7D32);
      case 'B':
        return const Color(0xFF4CAF50);
      case 'C':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _cropEmoji(String crop) {
    switch (crop.toLowerCase()) {
      case 'tomato':
        return '🍅';
      case 'onion':
        return '🧅';
      case 'potato':
        return '🥔';
      case 'wheat':
        return '🌾';
      case 'rice':
        return '🍚';
      case 'soybean':
        return '🌱';
      case 'cotton':
        return '🧶';
      case 'maize':
        return '🌽';
      case 'groundnut':
        return '🥜';
      case 'chilli':
        return '🌶️';
      default:
        return '🌿';
    }
  }
}

/// Helper data class for market explainability panel
class _MarketExplainPoint {
  final String icon;
  final String category;
  final String detail;
  final double score;
  final String weight;
  final bool isStrong;

  const _MarketExplainPoint({
    required this.icon,
    required this.category,
    required this.detail,
    required this.score,
    required this.weight,
    required this.isStrong,
  });
}
