import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// SoilGrids API Service — FREE, no API key needed.
/// Source: ISRIC World Soil Information (https://rest.isric.org)
///
/// Provides soil nutrient data by GPS coordinates:
/// - Organic Carbon (SOC)
/// - Nitrogen (Nitrogen)
/// - Clay/Sand/Silt content
/// - pH value
/// - Soil Organic Carbon Stock
///
/// This helps farmers understand soil health before planting/storage.
class SoilHealthService {
  static const String _baseUrl =
      'https://rest.isric.org/soilgrids/v2.0/properties/query';

  /// Fetch soil health data for given coordinates.
  /// Returns null on failure (non-blocking).
  static Future<SoilHealthData?> fetchSoilData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'lon': longitude.toStringAsFixed(4),
          'lat': latitude.toStringAsFixed(4),
          'property': 'soc,nitrogen,phh2o,clay,sand,silt,ocd',
          'depth': '0-5cm,5-15cm',
          'value': 'mean',
        },
      );

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        debugPrint('SoilHealth: API returned ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseSoilData(json);
    } catch (e) {
      debugPrint('SoilHealth error: $e');
      return null;
    }
  }

  static SoilHealthData? _parseSoilData(Map<String, dynamic> json) {
    try {
      final properties = json['properties'] as Map<String, dynamic>?;
      if (properties == null) return null;

      final layers = properties['layers'] as List<dynamic>? ?? [];

      double? soc, nitrogen, ph, clay, sand, silt, ocd;

      for (final layer in layers) {
        final name = layer['name'] as String? ?? '';
        final depths = layer['depths'] as List<dynamic>? ?? [];
        if (depths.isEmpty) continue;

        final values = depths[0]['values'] as Map<String, dynamic>? ?? {};
        final mean = (values['mean'] as num?)?.toDouble();

        switch (name) {
          case 'soc':
            soc = mean != null ? mean / 10 : null; // dg/kg → g/kg
            break;
          case 'nitrogen':
            nitrogen = mean != null ? mean / 100 : null; // cg/kg → g/kg
            break;
          case 'phh2o':
            ph = mean != null ? mean / 10 : null; // pH×10 → pH
            break;
          case 'clay':
            clay = mean != null ? mean / 10 : null; // g/kg → %
            break;
          case 'sand':
            sand = mean != null ? mean / 10 : null;
            break;
          case 'silt':
            silt = mean != null ? mean / 10 : null;
            break;
          case 'ocd':
            ocd = mean != null ? mean / 10 : null; // hg/m³ → kg/m³
            break;
        }
      }

      return SoilHealthData(
        latitude:
            (json['geometry']?['coordinates']?[1] as num?)?.toDouble() ?? 0,
        longitude:
            (json['geometry']?['coordinates']?[0] as num?)?.toDouble() ?? 0,
        organicCarbonGPerKg: soc,
        nitrogenGPerKg: nitrogen,
        phValue: ph,
        clayPercent: clay,
        sandPercent: sand,
        siltPercent: silt,
        organicCarbonDensity: ocd,
      );
    } catch (e) {
      debugPrint('SoilHealth parse error: $e');
      return null;
    }
  }

  /// Get GPS coordinates for a city using Open-Meteo geocoding (already free).
  static Future<List<double>?> geocodeCity(String city) async {
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': city,
        'count': '1',
        'language': 'en',
        'format': 'json',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      return [
        (first['latitude'] as num).toDouble(),
        (first['longitude'] as num).toDouble(),
      ];
    } catch (e) {
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class SoilHealthData {
  final double latitude;
  final double longitude;
  final double? organicCarbonGPerKg;
  final double? nitrogenGPerKg;
  final double? phValue;
  final double? clayPercent;
  final double? sandPercent;
  final double? siltPercent;
  final double? organicCarbonDensity;

  const SoilHealthData({
    required this.latitude,
    required this.longitude,
    this.organicCarbonGPerKg,
    this.nitrogenGPerKg,
    this.phValue,
    this.clayPercent,
    this.sandPercent,
    this.siltPercent,
    this.organicCarbonDensity,
  });

  /// Overall soil fertility rating
  String get fertilityRating {
    int score = 0;
    if (organicCarbonGPerKg != null && organicCarbonGPerKg! > 20) score++;
    if (nitrogenGPerKg != null && nitrogenGPerKg! > 1.5) score++;
    if (phValue != null && phValue! >= 6.0 && phValue! <= 7.5) score++;
    if (clayPercent != null && clayPercent! >= 15 && clayPercent! <= 35)
      score++;

    if (score >= 3) return 'Good';
    if (score >= 2) return 'Moderate';
    return 'Poor';
  }

  String get fertilityEmoji {
    switch (fertilityRating) {
      case 'Good':
        return '🟢';
      case 'Moderate':
        return '🟡';
      default:
        return '🔴';
    }
  }

  /// Soil type based on texture
  String get soilType {
    if (clayPercent == null || sandPercent == null || siltPercent == null)
      return 'Unknown';
    if (clayPercent! > 40) return 'Clay Soil (Heavy)';
    if (sandPercent! > 60) return 'Sandy Soil (Light)';
    if (siltPercent! > 40) return 'Silty Soil';
    if (clayPercent! >= 20 && sandPercent! >= 20 && siltPercent! >= 20)
      return 'Loamy Soil (Ideal)';
    return 'Mixed Soil';
  }

  /// pH interpretation
  String get phInterpretation {
    if (phValue == null) return 'Unknown';
    if (phValue! < 5.5) return 'Acidic — needs liming';
    if (phValue! < 6.5) return 'Slightly Acidic — good for most crops';
    if (phValue! <= 7.5) return 'Neutral — ideal for farming';
    if (phValue! <= 8.5) return 'Alkaline — add gypsum/organic matter';
    return 'Highly Alkaline — needs treatment';
  }

  /// Storage suitability based on soil conditions
  String get storageSuitability {
    if (clayPercent != null && clayPercent! > 45) {
      return 'Clay soil retains moisture — elevated storage recommended';
    }
    if (sandPercent != null && sandPercent! > 60) {
      return 'Sandy soil drains fast — ground storage acceptable';
    }
    return 'Moderate drainage — use raised platforms for storage';
  }
}
