import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────────────────
/// Harvest Window Prediction Engine
/// ─────────────────────────────────────────────────────────────────────────────
/// Combines:
///   1. Crop maturity timeline (sowDate + maturityDays → expected harvest range)
///   2. 10-day weather forecast (Open-Meteo)  — rain risk, temp spikes
///   3. Mandi price trend slope (data.gov.in) — rising / falling / stable
///   4. AI reasoning (Gemini) for final recommendation
///
/// Output:  HarvestPrediction with best window, confidence, risk factors

class HarvestPredictionService {
  // ── Open-Meteo 16-day forecast ───────────────────────────────────────────
  /// Fetch 10-day daily forecast (rain, temp, humidity, wind) for a location.
  static Future<List<DailyForecast>> fetch10DayForecast(String city) async {
    // Step 1: Geocode
    final geoUri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': city,
      'count': '1',
      'language': 'en',
      'format': 'json',
    });

    final geoRes = await http.get(geoUri).timeout(const Duration(seconds: 10));
    if (geoRes.statusCode != 200) throw Exception('Geo lookup failed');

    final geoJson = jsonDecode(geoRes.body) as Map<String, dynamic>;
    final results = (geoJson['results'] as List<dynamic>?) ?? [];
    if (results.isEmpty) throw Exception('City "$city" not found');

    final first = results.first as Map<String, dynamic>;
    final lat = (first['latitude'] as num).toDouble();
    final lon = (first['longitude'] as num).toDouble();

    // Step 2: 10-day forecast
    final weatherUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'daily':
          'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,weather_code',
      'timezone': 'auto',
      'forecast_days': '10',
    });

    final wRes = await http.get(weatherUri).timeout(const Duration(seconds: 10));
    if (wRes.statusCode != 200) throw Exception('Weather API error');

    final wJson = jsonDecode(wRes.body) as Map<String, dynamic>;
    final daily = wJson['daily'] as Map<String, dynamic>;

    final dates = (daily['time'] as List<dynamic>).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>).cast<num>();
    final precipitation = (daily['precipitation_sum'] as List<dynamic>).cast<num>();
    final precipProb = (daily['precipitation_probability_max'] as List<dynamic>?)
        ?.cast<num>();
    final windMax = (daily['wind_speed_10m_max'] as List<dynamic>).cast<num>();
    final weatherCodes = (daily['weather_code'] as List<dynamic>).cast<num>();

    final forecasts = <DailyForecast>[];
    for (var i = 0; i < dates.length; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.parse(dates[i]),
        maxTemp: maxTemps[i].toDouble(),
        minTemp: minTemps[i].toDouble(),
        precipitationMm: precipitation[i].toDouble(),
        rainProbability: precipProb != null ? precipProb[i].toInt() : 0,
        windMaxKmh: windMax[i].toDouble(),
        weatherCode: weatherCodes[i].toInt(),
      ));
    }

    return forecasts;
  }

  // ── Crop Maturity Database ───────────────────────────────────────────────
  /// Returns typical maturity range in days for Indian crops.
  static CropMaturityInfo getCropMaturity(String crop) {
    final c = crop.toLowerCase().trim();

    // Major Indian crops with maturity ranges
    final db = <String, CropMaturityInfo>{
      'wheat': CropMaturityInfo(crop: 'Wheat', minDays: 120, maxDays: 150, type: 'Rabi', idealTempRange: [15, 25], maxRainTolerance: 5),
      'rice': CropMaturityInfo(crop: 'Rice', minDays: 100, maxDays: 140, type: 'Kharif', idealTempRange: [20, 35], maxRainTolerance: 15),
      'paddy': CropMaturityInfo(crop: 'Paddy', minDays: 100, maxDays: 140, type: 'Kharif', idealTempRange: [20, 35], maxRainTolerance: 15),
      'tomato': CropMaturityInfo(crop: 'Tomato', minDays: 60, maxDays: 85, type: 'Vegetable', idealTempRange: [18, 30], maxRainTolerance: 3),
      'potato': CropMaturityInfo(crop: 'Potato', minDays: 75, maxDays: 120, type: 'Rabi', idealTempRange: [15, 25], maxRainTolerance: 5),
      'onion': CropMaturityInfo(crop: 'Onion', minDays: 100, maxDays: 150, type: 'Rabi', idealTempRange: [15, 30], maxRainTolerance: 3),
      'soybean': CropMaturityInfo(crop: 'Soybean', minDays: 80, maxDays: 120, type: 'Kharif', idealTempRange: [20, 30], maxRainTolerance: 8),
      'cotton': CropMaturityInfo(crop: 'Cotton', minDays: 150, maxDays: 180, type: 'Kharif', idealTempRange: [21, 35], maxRainTolerance: 5),
      'sugarcane': CropMaturityInfo(crop: 'Sugarcane', minDays: 270, maxDays: 365, type: 'Annual', idealTempRange: [20, 35], maxRainTolerance: 20),
      'banana': CropMaturityInfo(crop: 'Banana', minDays: 270, maxDays: 365, type: 'Fruit', idealTempRange: [20, 35], maxRainTolerance: 10),
      'apple': CropMaturityInfo(crop: 'Apple', minDays: 150, maxDays: 180, type: 'Fruit', idealTempRange: [10, 25], maxRainTolerance: 5),
      'mango': CropMaturityInfo(crop: 'Mango', minDays: 100, maxDays: 150, type: 'Fruit', idealTempRange: [24, 35], maxRainTolerance: 5),
      'cauliflower': CropMaturityInfo(crop: 'Cauliflower', minDays: 55, maxDays: 100, type: 'Vegetable', idealTempRange: [15, 25], maxRainTolerance: 3),
      'chilli': CropMaturityInfo(crop: 'Chilli', minDays: 60, maxDays: 90, type: 'Vegetable', idealTempRange: [20, 30], maxRainTolerance: 3),
      'garlic': CropMaturityInfo(crop: 'Garlic', minDays: 120, maxDays: 150, type: 'Rabi', idealTempRange: [12, 24], maxRainTolerance: 2),
      'ginger': CropMaturityInfo(crop: 'Ginger', minDays: 210, maxDays: 270, type: 'Kharif', idealTempRange: [20, 30], maxRainTolerance: 10),
      'maize': CropMaturityInfo(crop: 'Maize', minDays: 80, maxDays: 110, type: 'Kharif', idealTempRange: [21, 30], maxRainTolerance: 8),
      'mustard': CropMaturityInfo(crop: 'Mustard', minDays: 110, maxDays: 140, type: 'Rabi', idealTempRange: [10, 25], maxRainTolerance: 3),
      'gram': CropMaturityInfo(crop: 'Gram', minDays: 90, maxDays: 120, type: 'Rabi', idealTempRange: [15, 30], maxRainTolerance: 3),
      'groundnut': CropMaturityInfo(crop: 'Groundnut', minDays: 100, maxDays: 130, type: 'Kharif', idealTempRange: [20, 30], maxRainTolerance: 5),
      'bajra': CropMaturityInfo(crop: 'Bajra (Pearl Millet)', minDays: 65, maxDays: 90, type: 'Kharif', idealTempRange: [25, 35], maxRainTolerance: 5),
      'jowar': CropMaturityInfo(crop: 'Jowar (Sorghum)', minDays: 90, maxDays: 120, type: 'Kharif', idealTempRange: [25, 35], maxRainTolerance: 5),
      'brinjal': CropMaturityInfo(crop: 'Brinjal', minDays: 60, maxDays: 80, type: 'Vegetable', idealTempRange: [20, 30], maxRainTolerance: 3),
      'cabbage': CropMaturityInfo(crop: 'Cabbage', minDays: 60, maxDays: 90, type: 'Vegetable', idealTempRange: [15, 25], maxRainTolerance: 3),
      'carrot': CropMaturityInfo(crop: 'Carrot', minDays: 70, maxDays: 100, type: 'Vegetable', idealTempRange: [15, 25], maxRainTolerance: 3),
    };

    // Find best match
    for (final entry in db.entries) {
      if (c.contains(entry.key) || entry.key.contains(c)) {
        return entry.value;
      }
    }

    // Default for unknown crops
    return CropMaturityInfo(crop: crop, minDays: 90, maxDays: 120, type: 'General', idealTempRange: [18, 30], maxRainTolerance: 5);
  }

  // ── Score each day in forecast window ────────────────────────────────────
  /// Scores each forecast day from 0.0 (terrible) to 1.0 (perfect) for harvest.
  static List<DayScore> scoreForecastDays({
    required List<DailyForecast> forecast,
    required CropMaturityInfo cropInfo,
    List<double>? priceTrend, // last 5-7 price data points
  }) {
    final scores = <DayScore>[];

    // Price trend slope (positive = prices rising = wait, negative = sell soon)
    double priceSlope = 0;
    if (priceTrend != null && priceTrend.length >= 2) {
      priceSlope = _linearSlope(priceTrend);
    }

    for (int i = 0; i < forecast.length; i++) {
      final day = forecast[i];
      double score = 0;
      final risks = <String>[];
      final positives = <String>[];

      // ── Rain Risk (weight: 35%) ──────────────────────────────────────
      double rainScore = 1.0;
      if (day.precipitationMm > cropInfo.maxRainTolerance) {
        rainScore = 0.0;
        risks.add('🌧 Heavy rain (${day.precipitationMm.toStringAsFixed(1)}mm)');
      } else if (day.precipitationMm > cropInfo.maxRainTolerance * 0.5) {
        rainScore = 0.4;
        risks.add('🌦 Moderate rain (${day.precipitationMm.toStringAsFixed(1)}mm)');
      } else if (day.rainProbability > 60) {
        rainScore = 0.5;
        risks.add('☁️ High rain probability (${day.rainProbability}%)');
      } else if (day.precipitationMm < 1 && day.rainProbability < 30) {
        rainScore = 1.0;
        positives.add('☀️ Dry day — ideal for harvest');
      } else {
        rainScore = 0.7;
      }

      // ── Temperature Risk (weight: 25%) ────────────────────────────────
      double tempScore = 1.0;
      final avgTemp = (day.maxTemp + day.minTemp) / 2;
      final idealMin = cropInfo.idealTempRange[0];
      final idealMax = cropInfo.idealTempRange[1];

      if (day.maxTemp > 42) {
        tempScore = 0.1;
        risks.add('🔥 Extreme heat spike (${day.maxTemp.toStringAsFixed(0)}°C)');
      } else if (day.maxTemp > idealMax + 5) {
        tempScore = 0.3;
        risks.add('🌡️ High temp (${day.maxTemp.toStringAsFixed(0)}°C above ideal ${idealMax.toStringAsFixed(0)}°C)');
      } else if (avgTemp >= idealMin && avgTemp <= idealMax) {
        tempScore = 1.0;
        positives.add('🌡️ Temperature in ideal range (${avgTemp.toStringAsFixed(0)}°C)');
      } else {
        tempScore = 0.6;
      }

      // ── Wind Risk (weight: 10%) ──────────────────────────────────────
      double windScore = 1.0;
      if (day.windMaxKmh > 40) {
        windScore = 0.2;
        risks.add('💨 High wind (${day.windMaxKmh.toStringAsFixed(0)} km/h)');
      } else if (day.windMaxKmh > 25) {
        windScore = 0.6;
        risks.add('💨 Moderate wind');
      } else {
        positives.add('🍃 Calm wind');
      }

      // ── Price Trend (weight: 20%) ────────────────────────────────────
      double priceScore = 0.5; // neutral
      if (priceSlope > 2) {
        // Prices rising sharply — wait if possible
        priceScore = 0.3 + (i * 0.05).clamp(0.0, 0.3); // later days score higher
        if (i >= 5) positives.add('📈 Prices rising — later harvest may fetch more');
      } else if (priceSlope > 0.5) {
        priceScore = 0.5 + (i * 0.03).clamp(0.0, 0.2);
      } else if (priceSlope < -2) {
        // Prices falling — harvest sooner
        priceScore = 0.8 - (i * 0.05).clamp(0.0, 0.3);
        if (i <= 2) positives.add('📉 Prices dropping — sell early');
      } else {
        priceScore = 0.6;
      }

      // ── Consecutive Dry Days Bonus (weight: 10%) ─────────────────────
      double dryBonus = 0.5;
      // Check if next 2 days after this are also dry (for drying/transport)
      int dryCount = 0;
      for (int j = i; j < min(i + 3, forecast.length); j++) {
        if (forecast[j].precipitationMm < 2) dryCount++;
      }
      if (dryCount >= 3) {
        dryBonus = 1.0;
        positives.add('☀️ 3+ consecutive dry days');
      } else if (dryCount >= 2) {
        dryBonus = 0.7;
      }

      // ── Weighted Score ───────────────────────────────────────────────
      score = (rainScore * 0.35) +
          (tempScore * 0.25) +
          (priceScore * 0.20) +
          (windScore * 0.10) +
          (dryBonus * 0.10);

      scores.add(DayScore(
        date: day.date,
        score: score,
        rainScore: rainScore,
        tempScore: tempScore,
        priceScore: priceScore,
        windScore: windScore,
        risks: risks,
        positives: positives,
        forecast: day,
      ));
    }

    return scores;
  }

  // ── Find Best Harvest Window ─────────────────────────────────────────────
  /// Finds the best 3-5 day consecutive window with highest average score.
  static HarvestWindow findBestWindow(List<DayScore> scores, {int windowSize = 4}) {
    if (scores.length < windowSize) {
      windowSize = scores.length;
    }

    double bestAvg = -1;
    int bestStart = 0;

    for (int i = 0; i <= scores.length - windowSize; i++) {
      double sum = 0;
      for (int j = i; j < i + windowSize; j++) {
        sum += scores[j].score;
      }
      final avg = sum / windowSize;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestStart = i;
      }
    }

    final windowScores = scores.sublist(bestStart, bestStart + windowSize);
    final startDate = windowScores.first.date;
    final endDate = windowScores.last.date;

    // Confidence level
    String confidence;
    if (bestAvg >= 0.75) {
      confidence = 'High';
    } else if (bestAvg >= 0.55) {
      confidence = 'Medium';
    } else {
      confidence = 'Low';
    }

    // Collect all risks and positives in the window
    final windowRisks = <String>{};
    final windowPositives = <String>{};
    for (final ds in windowScores) {
      windowRisks.addAll(ds.risks);
      windowPositives.addAll(ds.positives);
    }

    return HarvestWindow(
      startDate: startDate,
      endDate: endDate,
      averageScore: bestAvg,
      confidence: confidence,
      dayScores: windowScores,
      risks: windowRisks.toList(),
      positives: windowPositives.toList(),
    );
  }

  // ── Linear regression slope helper ───────────────────────────────────────
  static double _linearSlope(List<double> values) {
    final n = values.length;
    if (n < 2) return 0;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }
    final denom = (n * sumX2 - sumX * sumX);
    if (denom == 0) return 0;
    return (n * sumXY - sumX * sumY) / denom;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double precipitationMm;
  final int rainProbability;
  final double windMaxKmh;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationMm,
    required this.rainProbability,
    required this.windMaxKmh,
    required this.weatherCode,
  });

  String get weatherEmoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode == 45 || weatherCode == 48) return '🌫️';
    if (weatherCode >= 51 && weatherCode <= 67) return '🌧️';
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌧️';
    if (weatherCode >= 95) return '⛈️';
    return '🌤️';
  }

  bool get isRainy => precipitationMm > 2 || rainProbability > 60;
}

class CropMaturityInfo {
  final String crop;
  final int minDays;
  final int maxDays;
  final String type; // Rabi, Kharif, Vegetable, Fruit, Annual
  final List<double> idealTempRange; // [min, max]
  final double maxRainTolerance; // mm per day

  const CropMaturityInfo({
    required this.crop,
    required this.minDays,
    required this.maxDays,
    required this.type,
    required this.idealTempRange,
    required this.maxRainTolerance,
  });

  /// Expected harvest date range given sowing date
  DateRange harvestRange(DateTime sowDate) {
    return DateRange(
      start: sowDate.add(Duration(days: minDays)),
      end: sowDate.add(Duration(days: maxDays)),
    );
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});
}

class DayScore {
  final DateTime date;
  final double score; // 0.0 – 1.0
  final double rainScore;
  final double tempScore;
  final double priceScore;
  final double windScore;
  final List<String> risks;
  final List<String> positives;
  final DailyForecast forecast;

  const DayScore({
    required this.date,
    required this.score,
    required this.rainScore,
    required this.tempScore,
    required this.priceScore,
    required this.windScore,
    required this.risks,
    required this.positives,
    required this.forecast,
  });

  String get scoreLabel {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.65) return 'Good';
    if (score >= 0.5) return 'Fair';
    if (score >= 0.35) return 'Poor';
    return 'Bad';
  }

  String get scoreEmoji {
    if (score >= 0.8) return '🟢';
    if (score >= 0.65) return '🟡';
    if (score >= 0.5) return '🟠';
    return '🔴';
  }
}

class HarvestWindow {
  final DateTime startDate;
  final DateTime endDate;
  final double averageScore;
  final String confidence; // High, Medium, Low
  final List<DayScore> dayScores;
  final List<String> risks;
  final List<String> positives;

  const HarvestWindow({
    required this.startDate,
    required this.endDate,
    required this.averageScore,
    required this.confidence,
    required this.dayScores,
    required this.risks,
    required this.positives,
  });

  String get confidenceEmoji {
    switch (confidence) {
      case 'High':
        return '🟢';
      case 'Medium':
        return '🟡';
      default:
        return '🔴';
    }
  }

  /// Formatted date range string
  String get dateRangeString {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${startDate.day} ${months[startDate.month - 1]} – ${endDate.day} ${months[endDate.month - 1]}';
  }
}
