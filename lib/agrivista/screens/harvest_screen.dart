import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/harvest_provider.dart';
import '../providers/language_provider.dart';
import '../providers/mandi_provider.dart';
import '../providers/weather_provider.dart';
import '../services/harvest_prediction_service.dart';
import '../theme/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Optimal Harvest Window Prediction Screen
/// ─────────────────────────────────────────────────────────────────────────────
/// A full predictive system that recommends when to harvest based on:
///   • Crop maturity timeline
///   • 10-day weather forecast (rain, temp, wind)
///   • Mandi price trend slope
///   • AI reasoning
///
/// Output: "Best harvest window: 14–18 June (High confidence)"
class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});

  @override
  State<HarvestScreen> createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  final _cropController = TextEditingController();
  final _cityController = TextEditingController();
  final _maturityController = TextEditingController();
  String? _selectedCrop;
  DateTime _sowDate = DateTime.now().subtract(const Duration(days: 90));

  static const List<String> _crops = [
    'Wheat', 'Rice', 'Tomato', 'Potato', 'Onion', 'Soybean',
    'Cotton', 'Maize', 'Mustard', 'Gram', 'Bajra', 'Jowar',
    'Sugarcane', 'Chilli', 'Garlic', 'Groundnut', 'Cauliflower',
    'Brinjal', 'Cabbage', 'Carrot', 'Banana', 'Mango', 'Apple',
  ];

  @override
  void initState() {
    super.initState();
    // Use weather provider's city as default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wp = context.read<WeatherProvider>();
      _cityController.text = wp.currentCity;
    });
  }

  @override
  void dispose() {
    _cropController.dispose();
    _cityController.dispose();
    _maturityController.dispose();
    super.dispose();
  }

  void _runPrediction() {
    final harvest = context.read<HarvestProvider>();
    final mandi = context.read<MandiProvider>();
    final lang = context.read<LanguageProvider>().currentLanguage;

    final crop = _selectedCrop ?? _cropController.text.trim();
    if (crop.isEmpty) return;

    final city = _cityController.text.trim().isEmpty
        ? 'Nagpur'
        : _cityController.text.trim();

    // Set up provider
    harvest.setCrop(crop);
    harvest.setCity(city);
    harvest.setSowDate(_sowDate);

    // Custom maturity days
    final customDays = int.tryParse(_maturityController.text.trim()) ?? 0;
    harvest.setCustomMaturityDays(customDays);

    // Extract price trend from loaded mandi prices
    final itemLower = crop.toLowerCase();
    final matchingPrices = mandi.allPrices
        .where((p) =>
            p.commodity.toLowerCase().contains(itemLower) ||
            itemLower.contains(p.commodity.toLowerCase()))
        .toList();

    if (matchingPrices.isNotEmpty) {
      final trend = matchingPrices
          .take(7)
          .map((p) => p.modalPrice)
          .toList();
      harvest.setPriceTrend(trend);
    }

    // Run prediction
    harvest.predict(language: lang);
  }

  Future<void> _pickSowDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sowDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'When did you sow this crop?',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _sowDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final harvest = context.watch<HarvestProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Text(
          '🌾 ${lang.tr('harvest_title')}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate, color: Colors.white),
            tooltip: lang.tr('language'),
            onSelected: (l) => lang.setLanguage(l),
            itemBuilder: (_) => LanguageProvider.supportedLanguages.map((l) {
              final emoji = LanguageProvider.languageEmojis[l] ?? '🌐';
              return PopupMenuItem(
                value: l,
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(l, style: GoogleFonts.poppins(fontSize: 14)),
                    if (lang.currentLanguage == l) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16, color: AppColors.primaryGreen),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subtitle
            Text(
              lang.tr('harvest_subtitle'),
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
            ),
            const SizedBox(height: 14),

            // ── Input Card ───────────────────────────────────────────────
            _buildInputCard(lang),
            const SizedBox(height: 12),

            // ── Predict Button ───────────────────────────────────────────
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: harvest.isLoading ? null : _runPrediction,
                icon: harvest.isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.agriculture, size: 20),
                label: Text(
                  harvest.isLoading ? lang.tr('predicting') : lang.tr('predict_harvest'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ),

            // ── Error ────────────────────────────────────────────────────
            if (harvest.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.riskHigh.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.3)),
                ),
                child: Text(harvest.errorMessage!,
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.riskHigh)),
              ),
            ],

            // ── Best Harvest Window (HERO CARD) ──────────────────────────
            if (harvest.bestWindow != null) ...[
              const SizedBox(height: 16),
              _buildHeroCard(harvest.bestWindow!, lang),
            ],

            // ── Explainability Panel: "Why Harvest Now?" ─────────────────
            if (harvest.bestWindow != null && harvest.dayScores != null) ...[
              const SizedBox(height: 14),
              _buildExplainabilityPanel(harvest, lang),
            ],

            // ── 10-Day Forecast Scores ───────────────────────────────────
            if (harvest.dayScores != null && harvest.dayScores!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildForecastScores(harvest.dayScores!, harvest.bestWindow, lang),
            ],

            // ── AI Summary ───────────────────────────────────────────────
            if (harvest.aiSummary != null) ...[
              const SizedBox(height: 14),
              _buildAISummary(harvest.aiSummary!, lang),
            ],

            // ── Crop Info Card ───────────────────────────────────────────
            if (harvest.cropInfo != null) ...[
              const SizedBox(height: 14),
              _buildCropInfoCard(harvest.cropInfo!, lang),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Input Card ─────────────────────────────────────────────────────────────
  Widget _buildInputCard(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop selector chips
          Text(lang.tr('select_crop'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _crops.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final crop = _crops[i];
                final selected = _selectedCrop == crop;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCrop = crop;
                      _cropController.text = crop;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primaryGreen : AppColors.divider,
                      ),
                    ),
                    child: Text(crop,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.textMedium,
                        )),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Custom crop input
          TextField(
            controller: _cropController,
            onChanged: (v) => setState(() => _selectedCrop = v.isNotEmpty ? v : null),
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: lang.tr('enter_crop'),
              prefixIcon: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 20),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // City + Sow Date row
          Row(
            children: [
              // City
              Expanded(
                child: TextField(
                  controller: _cityController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: lang.tr('city'),
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Sow Date picker
              Expanded(
                child: GestureDetector(
                  onTap: _pickSowDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${_sowDate.day}/${_sowDate.month}/${_sowDate.year}',
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Custom maturity days (optional override)
          TextField(
            controller: _maturityController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: lang.tr('maturity_days_hint'),
              prefixIcon: const Icon(Icons.timer, color: AppColors.primaryGreen, size: 20),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── EXPLAINABILITY PANEL: "Why Harvest Now?" ─────────────────────────────
  Widget _buildExplainabilityPanel(HarvestProvider harvest, LanguageProvider lang) {
    final window = harvest.bestWindow!;
    final scores = harvest.dayScores!;

    // Gather structured data points
    final dataPoints = <_ExplainPoint>[];

    // 1. Weather-based reasoning from day scores
    if (scores.isNotEmpty) {
      // Find avg rain in window
      final windowScores = scores.where((s) =>
          !s.date.isBefore(window.startDate) && !s.date.isAfter(window.endDate)).toList();
      if (windowScores.isNotEmpty) {
        final avgRain = windowScores.map((s) => s.forecast.precipitationMm).reduce((a, b) => a + b) / windowScores.length;
        final avgTemp = windowScores.map((s) => s.forecast.maxTemp).reduce((a, b) => a + b) / windowScores.length;
        final avgWind = windowScores.map((s) => s.forecast.windMaxKmh).reduce((a, b) => a + b) / windowScores.length;

        if (avgRain < 2) {
          dataPoints.add(_ExplainPoint(
            icon: '☀️',
            title: lang.tr('low_rain_window'),
            detail: '${avgRain.toStringAsFixed(1)} mm/day avg rainfall in window',
            isPositive: true,
          ));
        } else if (avgRain > 8) {
          dataPoints.add(_ExplainPoint(
            icon: '🌧️',
            title: lang.tr('rain_risk'),
            detail: '${avgRain.toStringAsFixed(1)} mm/day avg — harvest quickly',
            isPositive: false,
          ));
        }

        if (avgTemp >= 20 && avgTemp <= 35) {
          dataPoints.add(_ExplainPoint(
            icon: '🌡️',
            title: lang.tr('temp_suitable'),
            detail: '${avgTemp.toStringAsFixed(1)}°C avg — good for harvest',
            isPositive: true,
          ));
        } else if (avgTemp > 40) {
          dataPoints.add(_ExplainPoint(
            icon: '🔥',
            title: lang.tr('extreme_heat'),
            detail: '${avgTemp.toStringAsFixed(1)}°C — harvest early morning',
            isPositive: false,
          ));
        }

        if (avgWind < 20) {
          dataPoints.add(_ExplainPoint(
            icon: '🍃',
            title: lang.tr('calm_wind'),
            detail: '${avgWind.toStringAsFixed(0)} km/h avg wind — safe conditions',
            isPositive: true,
          ));
        } else {
          dataPoints.add(_ExplainPoint(
            icon: '💨',
            title: lang.tr('high_wind'),
            detail: '${avgWind.toStringAsFixed(0)} km/h wind — potential crop damage',
            isPositive: false,
          ));
        }
      }

      // 2. Check rain in days after window (post-harvest risk)
      final postWindowScores = scores.where((s) => s.date.isAfter(window.endDate)).toList();
      if (postWindowScores.isNotEmpty) {
        final postRain = postWindowScores.map((s) => s.forecast.precipitationMm).reduce((a, b) => a + b) / postWindowScores.length;
        if (postRain > 5) {
          dataPoints.add(_ExplainPoint(
            icon: '⛈️',
            title: lang.tr('rain_after_window'),
            detail: '${postRain.toStringAsFixed(1)} mm/day expected after — harvest before!',
            isPositive: false,
          ));
        }
      }
    }

    // 3. Price trend reasoning
    if (harvest.priceTrend != null && harvest.priceTrend!.length >= 3) {
      final prices = harvest.priceTrend!;
      final recent = prices.take(3).reduce((a, b) => a + b) / 3;
      final older = prices.skip(prices.length ~/ 2).take(3).reduce((a, b) => a + b) / 3;
      final pctChange = ((recent - older) / older * 100);
      if (pctChange > 2) {
        dataPoints.add(_ExplainPoint(
          icon: '📈',
          title: lang.tr('price_rising'),
          detail: '${pctChange.toStringAsFixed(1)}% price increase — sell soon for profit',
          isPositive: true,
        ));
      } else if (pctChange < -2) {
        dataPoints.add(_ExplainPoint(
          icon: '📉',
          title: lang.tr('price_falling'),
          detail: '${pctChange.abs().toStringAsFixed(1)}% price drop — harvest & store',
          isPositive: false,
        ));
      }
    }

    // 4. Confidence reasoning
    dataPoints.add(_ExplainPoint(
      icon: window.confidence == 'High' ? '✅' : window.confidence == 'Medium' ? '🟡' : '🔴',
      title: '${window.confidence} ${lang.tr('confidence')}',
      detail: 'Score: ${(window.averageScore * 100).toStringAsFixed(0)}% — ${window.confidence == 'High' ? 'strong recommendation' : 'use judgment'}',
      isPositive: window.confidence == 'High',
    ));

    // 5. From window positives/risks
    for (final p in window.positives.take(2)) {
      dataPoints.add(_ExplainPoint(
        icon: '✅', title: p, detail: '', isPositive: true,
      ));
    }
    for (final r in window.risks.take(2)) {
      dataPoints.add(_ExplainPoint(
        icon: '⚠️', title: r, detail: '', isPositive: false,
      ));
    }

    final positives = dataPoints.where((d) => d.isPositive).toList();
    final risks = dataPoints.where((d) => !d.isPositive).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.tr('why_harvest_now'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      lang.tr('explainability_subtitle'),
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Positive factors
          if (positives.isNotEmpty) ...[
            Text(
              '${lang.tr('supporting_factors')} (${positives.length})',
              style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 6),
            ...positives.map((p) => _explainRow(p)),
            const SizedBox(height: 10),
          ],

          // Risk factors
          if (risks.isNotEmpty) ...[
            Text(
              '${lang.tr('risk_factors')} (${risks.length})',
              style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.riskHigh),
            ),
            const SizedBox(height: 6),
            ...risks.map((p) => _explainRow(p)),
          ],
        ],
      ),
    );
  }

  Widget _explainRow(_ExplainPoint point) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: point.isPositive ? AppColors.primaryGreen : AppColors.riskHigh,
                  ),
                ),
                if (point.detail.isNotEmpty)
                  Text(
                    point.detail,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight, height: 1.3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO CARD: Best Harvest Window ─────────────────────────────────────────
  Widget _buildHeroCard(HarvestWindow window, LanguageProvider lang) {
    Color bgColor;
    Color borderColor;
    switch (window.confidence) {
      case 'High':
        bgColor = const Color(0xFFE8F5E9);
        borderColor = AppColors.primaryGreen;
        break;
      case 'Medium':
        bgColor = const Color(0xFFFFF8E1);
        borderColor = AppColors.riskMedium;
        break;
      default:
        bgColor = const Color(0xFFFFEBEE);
        borderColor = AppColors.riskHigh;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Row(
            children: [
              Text('🌾', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lang.tr('best_harvest_window'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date range — the hero text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.date_range, color: AppColors.primaryGreen, size: 22),
                const SizedBox(width: 8),
                Text(
                  window.dateRangeString,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Confidence badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${window.confidenceEmoji} ${window.confidence} ${lang.tr('confidence')} — Score: ${(window.averageScore * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: borderColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Positives
          if (window.positives.isNotEmpty) ...[
            ...window.positives.take(3).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(p,
                            style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
          ],

          // Risks
          if (window.risks.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...window.risks.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(r,
                            style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.riskHigh, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ── 10-Day Forecast Score Chart ────────────────────────────────────────────
  Widget _buildForecastScores(List<DayScore> scores, HarvestWindow? window, LanguageProvider lang) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 ${lang.tr('day_by_day_scores')}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            lang.tr('score_explanation'),
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
          ),
          const SizedBox(height: 12),

          // Visual score bars
          ...scores.map((s) {
            final isInWindow = window != null &&
                !s.date.isBefore(window.startDate) &&
                !s.date.isAfter(window.endDate);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Date
                  SizedBox(
                    width: 55,
                    child: Text(
                      '${s.date.day} ${months[s.date.month - 1]}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isInWindow ? FontWeight.w700 : FontWeight.w400,
                        color: isInWindow ? AppColors.primaryGreen : AppColors.textMedium,
                      ),
                    ),
                  ),
                  // Weather emoji
                  Text(s.forecast.weatherEmoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  // Score bar
                  Expanded(
                    child: Stack(
                      children: [
                        // Background
                        Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        // Score fill
                        FractionallySizedBox(
                          widthFactor: s.score.clamp(0.0, 1.0),
                          child: Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: _scoreColor(s.score).withValues(alpha: isInWindow ? 1.0 : 0.6),
                              borderRadius: BorderRadius.circular(6),
                              border: isInWindow
                                  ? Border.all(color: AppColors.primaryGreen, width: 2)
                                  : null,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              '${(s.score * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Score emoji
                  Text(s.scoreEmoji, style: const TextStyle(fontSize: 14)),
                  if (isInWindow)
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text('✅', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            );
          }),

          // Legend
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.riskLow, lang.tr('excellent')),
              const SizedBox(width: 12),
              _legendDot(AppColors.riskMedium, lang.tr('fair')),
              const SizedBox(width: 12),
              _legendDot(AppColors.riskHigh, lang.tr('poor')),
              const SizedBox(width: 12),
              Text('✅ = ${lang.tr('best_window')}',
                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }

  Color _scoreColor(double score) {
    if (score >= 0.7) return AppColors.riskLow;
    if (score >= 0.5) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  // ── AI Summary Card ────────────────────────────────────────────────────────
  Widget _buildAISummary(String summary, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                lang.tr('ai_harvest_advice'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Crop Info Card ─────────────────────────────────────────────────────────
  Widget _buildCropInfoCard(CropMaturityInfo info, LanguageProvider lang) {
    final harvestRange = info.harvestRange(_sowDate);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 ${lang.tr('crop_maturity_info')}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          _infoRow(lang.tr('crop'), info.crop),
          _infoRow(lang.tr('crop_type'), info.type),
          _infoRow(lang.tr('maturity_range'), '${info.minDays}–${info.maxDays} days'),
          _infoRow(lang.tr('ideal_temp'), '${info.idealTempRange[0]}–${info.idealTempRange[1]}°C'),
          _infoRow(lang.tr('rain_tolerance'), '${info.maxRainTolerance} mm/day'),
          _infoRow(lang.tr('sow_date'), '${_sowDate.day} ${months[_sowDate.month - 1]} ${_sowDate.year}'),
          _infoRow(
            lang.tr('expected_harvest'),
            '${harvestRange.start.day} ${months[harvestRange.start.month - 1]} – '
                '${harvestRange.end.day} ${months[harvestRange.end.month - 1]}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Helper data class for explainability panel
class _ExplainPoint {
  final String icon;
  final String title;
  final String detail;
  final bool isPositive;

  const _ExplainPoint({
    required this.icon,
    required this.title,
    required this.detail,
    required this.isPositive,
  });
}
