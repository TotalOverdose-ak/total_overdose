import 'package:flutter/foundation.dart';
import '../services/harvest_prediction_service.dart';
import '../services/mandi_ai_service.dart';

/// Provider for the Optimal Harvest Window Prediction feature.
///
/// Orchestrates:
/// - Crop maturity database lookup
/// - 10-day weather forecast fetch
/// - Mandi price trend analysis
/// - Scoring algorithm → best harvest window
/// - AI summary via Gemini
class HarvestProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────
  String _selectedCrop = '';
  DateTime? _sowDate;
  String _city = 'Nagpur';
  int _customMaturityDays = 0; // 0 = use default database

  bool _isLoading = false;
  String? _errorMessage;

  // Results
  CropMaturityInfo? _cropInfo;
  List<DailyForecast>? _forecast;
  List<DayScore>? _dayScores;
  HarvestWindow? _bestWindow;
  String? _aiSummary;
  List<double> _priceTrend = [];

  // Getters
  String get selectedCrop => _selectedCrop;
  DateTime? get sowDate => _sowDate;
  String get city => _city;
  int get customMaturityDays => _customMaturityDays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CropMaturityInfo? get cropInfo => _cropInfo;
  List<DailyForecast>? get forecast => _forecast;
  List<DayScore>? get dayScores => _dayScores;
  HarvestWindow? get bestWindow => _bestWindow;
  String? get aiSummary => _aiSummary;
  List<double> get priceTrend => _priceTrend;

  // ── Setters ───────────────────────────────────────────────────────────────
  void setCrop(String crop) {
    _selectedCrop = crop;
    _cropInfo = HarvestPredictionService.getCropMaturity(crop);
    notifyListeners();
  }

  void setSowDate(DateTime date) {
    _sowDate = date;
    notifyListeners();
  }

  void setCity(String city) {
    _city = city;
    notifyListeners();
  }

  void setCustomMaturityDays(int days) {
    _customMaturityDays = days;
    notifyListeners();
  }

  void setPriceTrend(List<double> prices) {
    _priceTrend = prices;
  }

  // ── Main Prediction ──────────────────────────────────────────────────────
  /// Run the full harvest prediction pipeline.
  Future<void> predict({String language = 'Hinglish'}) async {
    if (_selectedCrop.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _bestWindow = null;
    _dayScores = null;
    _aiSummary = null;
    notifyListeners();

    try {
      // 1. Get crop maturity info
      _cropInfo = HarvestPredictionService.getCropMaturity(_selectedCrop);

      // If custom maturity days provided, override
      if (_customMaturityDays > 0) {
        _cropInfo = CropMaturityInfo(
          crop: _cropInfo!.crop,
          minDays: _customMaturityDays - 5,
          maxDays: _customMaturityDays + 10,
          type: _cropInfo!.type,
          idealTempRange: _cropInfo!.idealTempRange,
          maxRainTolerance: _cropInfo!.maxRainTolerance,
        );
      }

      // 2. Fetch 10-day weather forecast
      debugPrint('HarvestProvider: Fetching 10-day forecast for $_city');
      _forecast = await HarvestPredictionService.fetch10DayForecast(_city);
      debugPrint('HarvestProvider: Got ${_forecast!.length} days forecast');

      // 3. Score each day
      _dayScores = HarvestPredictionService.scoreForecastDays(
        forecast: _forecast!,
        cropInfo: _cropInfo!,
        priceTrend: _priceTrend.isNotEmpty ? _priceTrend : null,
      );

      // 4. Find best harvest window
      _bestWindow = HarvestPredictionService.findBestWindow(_dayScores!);

      // 5. Get AI summary (non-blocking — show results first, then AI fills in)
      notifyListeners();

      // Generate AI summary with all the data
      _aiSummary = await _generateAISummary(language);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('HarvestProvider error: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── AI Summary Generation ────────────────────────────────────────────────
  Future<String> _generateAISummary(String language) async {
    if (_bestWindow == null || _forecast == null || _cropInfo == null) {
      return 'Insufficient data for AI analysis.';
    }

    // Build a rich context for Gemini
    final window = _bestWindow!;
    final crop = _cropInfo!;

    // Forecast summary for all 10 days
    final forecastSummary = _forecast!.map((d) {
      final m = d.date.month;
      final day = d.date.day;
      return '$day/${m}: ${d.maxTemp.toStringAsFixed(0)}°/${d.minTemp.toStringAsFixed(0)}° rain:${d.precipitationMm.toStringAsFixed(1)}mm wind:${d.windMaxKmh.toStringAsFixed(0)}km/h ${d.weatherEmoji}';
    }).join(' | ');

    // Day scores
    final scoreSummary = _dayScores!.map((s) {
      return '${s.date.day}/${s.date.month}: score=${s.score.toStringAsFixed(2)} ${s.scoreEmoji}';
    }).join(' | ');

    // Price trend info
    String priceInfo = 'No price data available';
    if (_priceTrend.isNotEmpty) {
      priceInfo = 'Recent prices: ${_priceTrend.map((p) => '₹${p.toStringAsFixed(0)}').join(', ')}';
      final first = _priceTrend.first;
      final last = _priceTrend.last;
      final change = ((last - first) / first * 100);
      priceInfo += ' | Trend: ${change > 0 ? "+" : ""}${change.toStringAsFixed(1)}% ${change > 0 ? "📈 Rising" : change < 0 ? "📉 Falling" : "→ Stable"}';
    }

    String langInstruction = '';
    if (language == 'Hindi') {
      langInstruction = 'Respond ENTIRELY in Hindi using Devanagari script.';
    } else if (language == 'Hinglish') {
      langInstruction = 'Respond in Hinglish (Hindi-English mix, Roman script).';
    } else if (language == 'Marathi') {
      langInstruction = 'Respond ENTIRELY in Marathi using Devanagari script.';
    }

    final prompt = '''You are an expert agricultural harvest advisor for Indian farmers.

CROP: ${crop.crop} (${crop.type} crop)
MATURITY: ${crop.minDays}–${crop.maxDays} days
IDEAL HARVEST TEMP: ${crop.idealTempRange[0]}–${crop.idealTempRange[1]}°C
MAX RAIN TOLERANCE: ${crop.maxRainTolerance}mm/day
LOCATION: $_city

10-DAY WEATHER FORECAST:
$forecastSummary

HARVEST SCORES (0=bad, 1=perfect):
$scoreSummary

BEST HARVEST WINDOW: ${window.dateRangeString}
CONFIDENCE: ${window.confidence} (score: ${window.averageScore.toStringAsFixed(2)})

RISKS IN WINDOW: ${window.risks.isEmpty ? 'None' : window.risks.join(', ')}
POSITIVES: ${window.positives.isEmpty ? 'None' : window.positives.join(', ')}

PRICE TREND: $priceInfo

$langInstruction

Give a farmer-friendly harvest recommendation:
1. State the BEST HARVEST WINDOW with confidence level
2. Explain WHY these dates are best (weather + price reasons)
3. If there are risks, what precautions to take
4. If prices are rising/falling, should they wait or harvest early?
5. One practical tip (morning harvest, moisture check, transport timing)

Keep under 120 words. No markdown. Be practical and direct like a village agriculture officer.''';

    try {
      return await MandiAIService.chat(
        message: prompt,
        language: language,
      );
    } catch (e) {
      return 'AI analysis unavailable. See the scores above for guidance.';
    }
  }
}
