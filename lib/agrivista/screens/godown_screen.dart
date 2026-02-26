import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/weather_provider.dart';
import '../services/mandi_ai_service.dart';
import '../services/spoilage_prevention_service.dart';
import '../theme/app_colors.dart';

/// Smart Godown Screen — AI-powered crop storage advisor
/// Features:
/// - Weather-based storage risk assessment
/// - Ideal storage conditions for any crop
/// - Nearby godown / safe storage location suggestions
/// - Multi-language support
class GodownScreen extends StatefulWidget {
  const GodownScreen({super.key});

  @override
  State<GodownScreen> createState() => _GodownScreenState();
}

class _GodownScreenState extends State<GodownScreen> {
  final TextEditingController _cropController = TextEditingController();
  String? _selectedCrop;
  bool _isLoading = false;
  String? _storageAdvice;
  String? _locationAdvice;
  String _riskLevel = ''; // low, medium, high

  static const List<String> _commonCrops = [
    'Wheat',
    'Rice',
    'Tomato',
    'Potato',
    'Onion',
    'Soybean',
    'Cotton',
    'Sugarcane',
    'Banana',
    'Apple',
    'Mango',
    'Cauliflower',
    'Chilli',
    'Garlic',
    'Ginger',
  ];

  static const Map<String, String> _cropEmojis = {
    'Wheat': '🌾',
    'Rice': '🍚',
    'Tomato': '🍅',
    'Potato': '🥔',
    'Onion': '🧅',
    'Soybean': '🫘',
    'Cotton': '🧵',
    'Sugarcane': '🍬',
    'Banana': '🍌',
    'Apple': '🍎',
    'Mango': '🥭',
    'Cauliflower': '🥦',
    'Chilli': '🌶️',
    'Garlic': '🧄',
    'Ginger': '🫚',
  };

  void _analyzeStorage() async {
    final crop = _selectedCrop ?? _cropController.text.trim();
    if (crop.isEmpty) return;

    final weatherProvider = context.read<WeatherProvider>();
    final weather = weatherProvider.weatherData;
    final lang = context.read<LanguageProvider>().currentLanguage;

    setState(() {
      _isLoading = true;
      _storageAdvice = null;
      _locationAdvice = null;
      _riskLevel = '';
    });

    try {
      // Parallel AI calls for storage advice and location suggestions
      final results = await Future.wait([
        _getStorageAdvice(crop, weather, lang),
        _getLocationAdvice(crop, weather, lang),
      ]);

      if (mounted) {
        setState(() {
          _storageAdvice = results[0];
          _locationAdvice = results[1];
          _riskLevel = _calculateRisk(crop, weather);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _storageAdvice = 'Could not get advice. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  String _calculateRisk(String crop, WeatherData? weather) {
    if (weather == null) return 'medium';

    final temp = weather.temperature;
    final humidity = weather.humidity;

    // Perishable crops (fruits/vegetables)
    final perishable = [
      'Tomato', 'Banana', 'Mango', 'Apple', 'Cauliflower',
      'Potato', 'Onion', 'Chilli',
    ];

    // Grains (more tolerant)
    final grains = ['Wheat', 'Rice', 'Soybean', 'Cotton'];

    if (perishable.contains(crop)) {
      if (temp > 35 || humidity > 85) return 'high';
      if (temp > 28 || humidity > 70) return 'medium';
      return 'low';
    } else if (grains.contains(crop)) {
      if (humidity > 80) return 'high';
      if (humidity > 65 || temp > 38) return 'medium';
      return 'low';
    } else {
      // Default logic
      if (temp > 35 && humidity > 75) return 'high';
      if (temp > 30 || humidity > 70) return 'medium';
      return 'low';
    }
  }

  Future<String> _getStorageAdvice(
      String crop, WeatherData? weather, String lang) async {
    final weatherInfo = weather != null
        ? 'Current weather: ${weather.temperature}°C, ${weather.humidity}% humidity, ${weather.description}, Wind: ${weather.windKmh} km/h, City: ${weather.city}'
        : 'Weather data not available';

    String langInstruction = '';
    if (lang == 'Hindi') {
      langInstruction = 'Respond ENTIRELY in Hindi using Devanagari script.';
    } else if (lang == 'Marathi') {
      langInstruction = 'Respond ENTIRELY in Marathi using Devanagari script.';
    } else if (lang == 'Tamil') {
      langInstruction = 'Respond ENTIRELY in Tamil script.';
    } else if (lang == 'Telugu') {
      langInstruction = 'Respond ENTIRELY in Telugu script.';
    } else if (lang == 'Bengali') {
      langInstruction = 'Respond ENTIRELY in Bengali script.';
    } else if (lang == 'Hinglish') {
      langInstruction = 'Respond in Hinglish (Hindi-English mix, Roman script).';
    }

    final prompt = '''You are an expert agricultural storage advisor for Indian farmers.

CROP: $crop
$weatherInfo

$langInstruction

Provide storage advice covering:
1. Ideal temperature and humidity range for storing this crop
2. Expected shelf life under good conditions
3. Whether CURRENT weather is suitable for storage (assess risk)
4. Key precautions given today's weather
5. Signs of spoilage to watch for

Keep under 120 words. No markdown. Be practical and farmer-friendly.''';

    return MandiAIService.chat(
      message: prompt,
      language: lang,
    );
  }

  Future<String> _getLocationAdvice(
      String crop, WeatherData? weather, String lang) async {
    final city = weather?.city ?? 'India';
    final temp = weather?.temperature ?? 30;
    final humidity = weather?.humidity ?? 60;

    String langInstruction = '';
    if (lang == 'Hindi') {
      langInstruction = 'Respond ENTIRELY in Hindi using Devanagari script.';
    } else if (lang == 'Marathi') {
      langInstruction = 'Respond ENTIRELY in Marathi using Devanagari script.';
    } else if (lang == 'Tamil') {
      langInstruction = 'Respond ENTIRELY in Tamil script.';
    } else if (lang == 'Hinglish') {
      langInstruction = 'Respond in Hinglish (Hindi-English mix, Roman script).';
    }

    final prompt = '''You are an agricultural storage location expert for India.

CROP: $crop
LOCATION: $city area
CURRENT TEMP: ${temp}°C
CURRENT HUMIDITY: $humidity%

$langInstruction

Suggest:
1. What TYPE of storage is best for $crop (cold storage, dry warehouse, ventilated shed, etc.)
2. 2-3 specific godown/cold storage location types near $city where farmer can store this crop
3. Tips for choosing the right storage facility
4. Government schemes available for cold storage (PM Kisan, etc.)

Keep under 100 words. No markdown. Be practical.''';

    return MandiAIService.chat(
      message: prompt,
      language: lang,
    );
  }

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final weather = context.watch<WeatherProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Text(
          lang.tr('godown_title'),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          // Language picker quick access
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
              lang.tr('godown_subtitle'),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),

            // ── Weather Status Card ──────────────────────────────────────
            _buildWeatherCard(weather, lang),
            const SizedBox(height: 16),

            // ── Crop Selection ───────────────────────────────────────────
            _buildCropSelector(lang),
            const SizedBox(height: 12),

            // ── Get Advice Button ────────────────────────────────────────
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyzeStorage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(lang.tr('loading_advice'),
                              style: GoogleFonts.poppins(fontSize: 13)),
                        ],
                      )
                    : Text(
                        lang.tr('get_advice'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Risk Assessment Card ─────────────────────────────────────
            if (_riskLevel.isNotEmpty) _buildRiskCard(lang),
            if (_riskLevel.isNotEmpty) const SizedBox(height: 14),

            // ── Storage Advice Card ──────────────────────────────────────
            if (_storageAdvice != null) _buildAdviceCard(lang),
            if (_storageAdvice != null) const SizedBox(height: 14),

            // ── Spoilage Prevention Ranking Table ────────────────────────
            if (_storageAdvice != null && (_selectedCrop ?? _cropController.text).isNotEmpty)
              _buildPreservationRankingTable(lang),
            if (_storageAdvice != null) const SizedBox(height: 14),

            // ── Location Advice Card ─────────────────────────────────────
            if (_locationAdvice != null) _buildLocationCard(lang),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Weather Card ───────────────────────────────────────────────────────────
  Widget _buildWeatherCard(WeatherProvider wp, LanguageProvider lang) {
    final weather = wp.weatherData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: weather == null
          ? Center(
              child: Text(
                lang.tr('fetching'),
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
            )
          : Row(
              children: [
                Text(weather.iconEmoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.city} — ${lang.tr('current_weather')}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C  •  ${lang.tr('humidity')}: ${weather.humidity}%',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${weather.description}  •  ${lang.tr('wind')}: ${weather.windKmh.toStringAsFixed(0)} km/h',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Crop Selector ──────────────────────────────────────────────────────────
  Widget _buildCropSelector(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.tr('select_crop'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),

        // Crop chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonCrops.map((crop) {
            final isSelected = _selectedCrop == crop;
            final emoji = _cropEmojis[crop] ?? '🌿';
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCrop = crop;
                  _cropController.text = crop;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : AppColors.divider,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )]
                      : [],
                ),
                child: Text(
                  '$emoji $crop',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // Custom crop input
        TextField(
          controller: _cropController,
          onChanged: (v) => setState(() => _selectedCrop = v.isNotEmpty ? v : null),
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: lang.tr('enter_crop'),
            hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 13),
            prefixIcon: const Icon(Icons.eco, color: AppColors.primaryGreen),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Risk Assessment Card ───────────────────────────────────────────────────
  Widget _buildRiskCard(LanguageProvider lang) {
    Color riskColor;
    String riskText;
    IconData riskIcon;

    switch (_riskLevel) {
      case 'low':
        riskColor = AppColors.riskLow;
        riskText = lang.tr('risk_low');
        riskIcon = Icons.check_circle;
        break;
      case 'high':
        riskColor = AppColors.riskHigh;
        riskText = lang.tr('risk_high');
        riskIcon = Icons.dangerous;
        break;
      default:
        riskColor = AppColors.riskMedium;
        riskText = lang.tr('risk_medium');
        riskIcon = Icons.warning;
    }

    final crop = _selectedCrop ?? _cropController.text;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(riskIcon, color: riskColor, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${lang.tr('weather_crop_check')} — $crop',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lang.tr('storage_risk')}: $riskText',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Storage Advice Card ────────────────────────────────────────────────────
  Widget _buildAdviceCard(LanguageProvider lang) {
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
          Row(
            children: [
              const Text('🏭', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                lang.tr('storage_advice'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _storageAdvice!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Spoilage Prevention Ranking Table ─────────────────────────────────────
  Widget _buildPreservationRankingTable(LanguageProvider lang) {
    final crop = _selectedCrop ?? _cropController.text.trim();
    final actions = SpoilagePreventionService.getRankedActions(crop);

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
          Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lang.tr('preservation_ranking'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lang.tr('preservation_subtitle'),
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
          ),
          const SizedBox(height: 12),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('Rank',
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(lang.tr('action'),
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(lang.tr('cost_col'),
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ),
                SizedBox(
                  width: 65,
                  child: Text(lang.tr('effectiveness'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Table Rows
          ...actions.map((a) => _buildPreservationRow(a)),

          const SizedBox(height: 10),

          // Effectiveness legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendChip('🟢', lang.tr('low_cost')),
              const SizedBox(width: 8),
              _legendChip('🟡', lang.tr('medium_cost')),
              const SizedBox(width: 8),
              _legendChip('🔴', lang.tr('high_cost')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreservationRow(PreservationAction action) {
    Color effectColor;
    if (action.effectivenessPercent >= 40) {
      effectColor = AppColors.riskLow;
    } else if (action.effectivenessPercent >= 25) {
      effectColor = const Color(0xFF4CAF50);
    } else {
      effectColor = AppColors.riskMedium;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: action.rank == 1
            ? const Color(0xFFE8F5E9)
            : (action.rank % 2 == 0 ? AppColors.background : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: action.rank == 1
            ? Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank
              SizedBox(
                width: 28,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: action.rank == 1
                        ? AppColors.primaryGreen
                        : action.rank <= 3
                            ? const Color(0xFF4CAF50)
                            : AppColors.textLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${action.rank}',
                    style: GoogleFonts.poppins(
                        fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              // Action name
              Expanded(
                flex: 3,
                child: Text(
                  action.action,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: action.rank == 1 ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              // Cost
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(action.costEmoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        action.costEstimate,
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMedium),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Effectiveness bar
              SizedBox(
                width: 65,
                child: Column(
                  children: [
                    Text(
                      '${action.effectivenessPercent}%',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: effectColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: action.effectivenessPercent / 50,
                        backgroundColor: effectColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(effectColor),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Description (compact)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              action.description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textLight,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(String emoji, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 3),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }

  // ── Location Advice Card ───────────────────────────────────────────────────
  Widget _buildLocationCard(LanguageProvider lang) {
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
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                lang.tr('godown_locations'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _locationAdvice!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
