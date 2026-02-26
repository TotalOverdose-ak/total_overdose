import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/market_recommendation_service.dart';

/// Provider that orchestrates market recommendation analysis.
///
/// Fetches multi-market data → scores → ranks → generates AI summary.
/// This is DECISION INTELLIGENCE, not just price display.
class MarketRecommendationProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────
  List<MarketScore> _rankedMarkets = [];
  MarketScore? _topRecommendation;
  String? _aiSummary;
  bool _isLoading = false;
  String? _error;
  String _selectedCrop = 'Tomato';
  String _userCity = 'Nagpur';
  String _userState = 'Maharashtra';

  // ── Getters ───────────────────────────────────────────────────────────────
  List<MarketScore> get rankedMarkets => _rankedMarkets;
  MarketScore? get topRecommendation => _topRecommendation;
  String? get aiSummary => _aiSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCrop => _selectedCrop;
  String get userCity => _userCity;
  String get userState => _userState;

  // ── Crop & Location Setters ───────────────────────────────────────────────
  void setCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  void setUserLocation(String city, String state) {
    _userCity = city;
    _userState = state;
    notifyListeners();
  }

  // ── Main Analysis Pipeline ────────────────────────────────────────────────
  /// Runs the full recommendation pipeline:
  /// 1. Fetch multi-market data for the crop
  /// 2. Score & rank all markets
  /// 3. Generate AI explanation
  Future<void> analyze({String? language}) async {
    _isLoading = true;
    _error = null;
    _rankedMarkets = [];
    _topRecommendation = null;
    _aiSummary = null;
    notifyListeners();

    try {
      // ── Step 1: Fetch market data ─────────────────────────────────────
      debugPrint('MarketRec: Fetching data for $_selectedCrop...');
      final entries = await MarketRecommendationService.fetchMarketsForCommodity(
          _selectedCrop);

      if (entries.isEmpty) {
        _error = 'No market data found for $_selectedCrop';
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('MarketRec: Got ${entries.length} entries across markets');

      // ── Step 2: Score & rank ──────────────────────────────────────────
      _rankedMarkets = MarketRecommendationService.analyzeMarkets(
        entries: entries,
        userCity: _userCity,
        userState: _userState,
      );

      if (_rankedMarkets.isNotEmpty) {
        _topRecommendation = _rankedMarkets.first;
      }

      debugPrint(
          'MarketRec: Ranked ${_rankedMarkets.length} markets. Top: ${_topRecommendation?.market}');

      // ── Step 3: Generate AI summary ───────────────────────────────────
      await _generateAISummary(language ?? 'Hinglish');
    } catch (e) {
      debugPrint('MarketRec error: $e');
      _error = 'Analysis failed: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── AI Summary Generation ─────────────────────────────────────────────────
  Future<void> _generateAISummary(String language) async {
    if (_rankedMarkets.isEmpty) return;

    try {
      final top = _topRecommendation!;
      final allMarketLines = _rankedMarkets.take(6).map((m) {
        return '${m.market} (${m.district}, ${m.state}): Modal ₹${m.modalPrice.toStringAsFixed(0)}, '
            'Net ₹${m.netProfit.toStringAsFixed(0)}, '
            'Travel ₹${m.estimatedTravelCost.toStringAsFixed(0)}, '
            'Regional ${m.regionalDiffPercent >= 0 ? '+' : ''}${m.regionalDiffPercent.toStringAsFixed(1)}%, '
            'Volatility ${(m.volatility * 100).toStringAsFixed(0)}%, '
            'Arrivals ${m.arrivalCount}, '
            'Score ${m.overallScore.toStringAsFixed(0)}/100';
      }).join('\n');

      String langInstr = '';
      if (language == 'Hindi') {
        langInstr = 'Respond ENTIRELY in Hindi (Devanagari script).';
      } else if (language == 'Hinglish') {
        langInstr = 'Respond in Hinglish (Hindi-English mix, Roman script). Use "bhaiya", "dekho" style naturally.';
      } else {
        langInstr = 'Respond in simple English.';
      }

      final prompt = '''You are an expert agricultural market advisor for Indian farmers.

FARMER'S SITUATION:
- Crop: ${top.commodity}
- Location: $_userCity, $_userState
- Looking for BEST MARKET to sell their produce

MARKET ANALYSIS DATA (scored by our AI engine):
$allMarketLines

TOP RECOMMENDATION: ${top.market}, ${top.district}
- Modal Price: ₹${top.modalPrice.toStringAsFixed(0)}/quintal
- Net Profit (after travel): ₹${top.netProfit.toStringAsFixed(0)}/quintal
- Regional Performance: ${top.regionalDiffPercent >= 0 ? '+' : ''}${top.regionalDiffPercent.toStringAsFixed(1)}% vs regional average
- Travel Cost: ₹${top.estimatedTravelCost.toStringAsFixed(0)}/quintal
- Volatility: ${(top.volatility * 100).toStringAsFixed(0)}%
- Competition: ${top.arrivalCount} arrival entries

$langInstr

Give a brief (under 80 words), practical recommendation explaining:
1. WHY this market is best (use specific numbers)
2. What NET PROFIT the farmer can expect per quintal
3. One practical tip for selling at this market

Be direct, confident, and data-driven. No markdown. No bullets. Write as flowing text like a trusted advisor.''';

      const apiKey = 'AIzaSyCRPu7QSFgUnBeu2SkmDzhvunJjYJ4sEQk';
      const model = 'gemini-2.0-flash';
      const url =
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 300,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content =
              candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          final text = parts?[0]['text'] as String? ?? '';
          if (text.trim().isNotEmpty) {
            _aiSummary = text.trim();
            notifyListeners();
            return;
          }
        }
      }

      // Fallback summary
      _aiSummary = _buildFallbackSummary(top, language);
    } catch (e) {
      debugPrint('MarketRec AI summary error: $e');
      _aiSummary = _buildFallbackSummary(_topRecommendation!, language);
    }
  }

  String _buildFallbackSummary(MarketScore top, String language) {
    final net = top.netProfit.toStringAsFixed(0);
    final modal = top.modalPrice.toStringAsFixed(0);
    final diff = top.regionalDiffPercent.abs().toStringAsFixed(1);
    final above = top.regionalDiffPercent >= 0;

    if (language == 'Hindi') {
      return '${top.market} मंडी में ${top.commodity} बेचें। मोडल भाव ₹$modal/क्विंटल है, '
          'ट्रांसपोर्ट के बाद शुद्ध लाभ ₹$net/क्विंटल। '
          '${above ? 'रीजनल एवरेज से $diff% ज़्यादा' : 'रीजनल एवरेज से $diff% कम'}। '
          'सुबह जल्दी पहुँचें ताकि अच्छे खरीदार मिलें।';
    }
    return '${top.market} mandi mein ${top.commodity} becho. Modal rate ₹$modal/quintal hai, '
        'transport ke baad net profit ₹$net/quintal milega. '
        '${above ? 'Regional average se $diff% zyada' : 'Regional average se $diff% kam'}. '
        'Subah jaldi pahuncho for best buyers!';
  }

  // ── Available crops for recommendation ────────────────────────────────────
  static const List<String> availableCrops = [
    'Tomato',
    'Onion',
    'Potato',
    'Wheat',
    'Rice',
    'Soybean',
    'Cotton',
    'Maize',
    'Groundnut',
    'Chilli',
  ];

  // ── Major states for user location ────────────────────────────────────────
  static const Map<String, List<String>> stateCities = {
    'Maharashtra': ['Nagpur', 'Pune', 'Mumbai', 'Nashik', 'Aurangabad', 'Amravati'],
    'Madhya Pradesh': ['Indore', 'Bhopal', 'Jabalpur', 'Ujjain', 'Khandwa'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Kota', 'Udaipur'],
    'Uttar Pradesh': ['Lucknow', 'Agra', 'Kanpur', 'Varanasi'],
    'Gujarat': ['Ahmedabad', 'Rajkot', 'Surat', 'Vadodara'],
    'Karnataka': ['Bengaluru', 'Hubli', 'Davangere', 'Mysuru'],
    'Punjab': ['Amritsar', 'Ludhiana', 'Jalandhar'],
    'Haryana': ['Karnal', 'Hisar', 'Rohtak'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
    'Telangana': ['Hyderabad', 'Warangal', 'Adilabad'],
    'West Bengal': ['Kolkata', 'Burdwan', 'Hooghly'],
    'Bihar': ['Patna', 'Muzaffarpur', 'Gaya'],
  };
}
