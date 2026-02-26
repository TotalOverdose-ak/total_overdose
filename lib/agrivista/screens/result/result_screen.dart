import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/recommendation_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/harvest_recommendation_card.dart';
import '../../widgets/market_card.dart';
import '../../widgets/spoilage_risk_card.dart';
import '../../widgets/preservation_card.dart';
import '../../widgets/weather_strip.dart';
import '../../widgets/confidence_score_badge.dart';
import '../../widgets/floating_mic_button.dart';
import '../../widgets/motivational_quote_card.dart';

class ResultScreen extends StatefulWidget {
  final RecommendationResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardFades;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Staggered fade-in for each card
    _cardFades = List.generate(5, (i) {
      final start = i * 0.12;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsible App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: ConfidenceScoreBadge(
                    confidencePct: r.overallConfidencePct,
                    large: true,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 0, 14),
              title: Text(
                r.cropName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.homeGradient,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Recommendation',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.cropName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            r.location,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Content ──────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Weather strip
                WeatherStrip(
                  condition: r.weather.condition,
                  tempCelsius: r.weather.tempCelsius,
                  humidityPct: r.weather.humidityPct,
                  rainForecast: r.weather.rainForecast,
                  iconEmoji: r.weather.iconEmoji,
                ),
                const SizedBox(height: 14),
                // Harvest recommendation
                FadeTransition(
                  opacity: _cardFades[0],
                  child: HarvestRecommendationCard(
                    harvestWindow: r.harvestWindow,
                    cropName: r.cropName,
                  ),
                ),
                const SizedBox(height: 14),
                // Market card
                FadeTransition(
                  opacity: _cardFades[1],
                  child: MarketCard(mandi: r.bestMandi),
                ),
                const SizedBox(height: 14),
                // Spoilage risk
                FadeTransition(
                  opacity: _cardFades[2],
                  child: SpoilageRiskCard(
                    risk: r.spoilageRisk,
                    riskScore: r.spoilageRiskScore,
                  ),
                ),
                const SizedBox(height: 14),
                // Preservation suggestions
                FadeTransition(
                  opacity: _cardFades[3],
                  child: PreservationCard(
                    suggestions: r.preservationSuggestions,
                  ),
                ),
                const SizedBox(height: 14),
                // Motivational quote
                FadeTransition(
                  opacity: _cardFades[4],
                  child: MotivationalQuoteCard(quote: r.motivationalQuote),
                ),
                const SizedBox(height: 20),
                // Share / Save buttons
                _ActionButtonRow(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingMicButton(
        onMicTap: () {},
        onPlaybackTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🔊 Playing voice explanation…',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: Text(
              'Share',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.bookmark_outline),
            label: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Recommendation saved!',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF22223B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
