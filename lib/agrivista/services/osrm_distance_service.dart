import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// OSRM Distance Service — Completely FREE, no API key needed.
/// Source: Open Source Routing Machine (https://router.project-osrm.org)
///
/// Provides REAL road distances and travel times between any two points.
/// Much more accurate than straight-line distance estimates.
class OsrmDistanceService {
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';
  static const String _geocodeBase =
      'https://geocoding-api.open-meteo.com/v1/search';

  /// Get real road distance and travel time between two cities.
  /// Returns null if either city cannot be geocoded or route fails.
  static Future<RouteInfo?> getRoute({
    required String fromCity,
    required String toCity,
  }) async {
    try {
      // Geocode both cities in parallel
      final results = await Future.wait([_geocode(fromCity), _geocode(toCity)]);

      final fromCoord = results[0];
      final toCoord = results[1];

      if (fromCoord == null || toCoord == null) {
        debugPrint('OSRM: Could not geocode cities: $fromCity / $toCity');
        return null;
      }

      // Call OSRM
      final url =
          '$_osrmBase/${fromCoord[1]},${fromCoord[0]};${toCoord[1]},${toCoord[0]}?overview=false';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('OSRM: Route API returned ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final code = json['code'] as String?;
      if (code != 'Ok') return null;

      final routes = json['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
      final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0;

      return RouteInfo(
        fromCity: fromCity,
        toCity: toCity,
        distanceKm: distanceMeters / 1000,
        durationHours: durationSeconds / 3600,
        durationMinutes: durationSeconds / 60,
      );
    } catch (e) {
      debugPrint('OSRM error: $e');
      return null;
    }
  }

  /// Batch route calculation for multiple destinations from one source.
  /// More efficient for market recommendation.
  static Future<List<RouteInfo>> getBatchRoutes({
    required String fromCity,
    required List<String> toCities,
  }) async {
    final results = <RouteInfo>[];

    // Geocode source first
    final fromCoord = await _geocode(fromCity);
    if (fromCoord == null) return results;

    // Geocode all destinations in parallel (max 5 at a time to be nice)
    for (var i = 0; i < toCities.length; i += 5) {
      final batch = toCities.skip(i).take(5).toList();
      final geoResults = await Future.wait(batch.map((city) => _geocode(city)));

      for (var j = 0; j < batch.length; j++) {
        final toCoord = geoResults[j];
        if (toCoord == null) continue;

        try {
          final url =
              '$_osrmBase/${fromCoord[1]},${fromCoord[0]};${toCoord[1]},${toCoord[0]}?overview=false';
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            if (json['code'] == 'Ok') {
              final routes = json['routes'] as List<dynamic>? ?? [];
              if (routes.isNotEmpty) {
                final route = routes.first as Map<String, dynamic>;
                results.add(
                  RouteInfo(
                    fromCity: fromCity,
                    toCity: batch[j],
                    distanceKm:
                        ((route['distance'] as num?)?.toDouble() ?? 0) / 1000,
                    durationHours:
                        ((route['duration'] as num?)?.toDouble() ?? 0) / 3600,
                    durationMinutes:
                        ((route['duration'] as num?)?.toDouble() ?? 0) / 60,
                  ),
                );
              }
            }
          }
        } catch (e) {
          debugPrint('OSRM batch route error for ${batch[j]}: $e');
        }
      }
    }

    return results;
  }

  /// Geocode using Open-Meteo (free, no key)
  static Future<List<double>?> _geocode(String city) async {
    try {
      // Add "India" to improve geocoding accuracy
      final query = city.contains('India') ? city : '$city, India';

      final uri = Uri.parse(_geocodeBase).replace(
        queryParameters: {
          'name': query,
          'count': '1',
          'language': 'en',
          'format': 'json',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      return [
        (first['latitude'] as num).toDouble(), // lat
        (first['longitude'] as num).toDouble(), // lon
      ];
    } catch (e) {
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class RouteInfo {
  final String fromCity;
  final String toCity;
  final double distanceKm;
  final double durationHours;
  final double durationMinutes;

  const RouteInfo({
    required this.fromCity,
    required this.toCity,
    required this.distanceKm,
    required this.durationHours,
    required this.durationMinutes,
  });

  /// Formatted distance
  String get distanceLabel => distanceKm >= 1
      ? '${distanceKm.toStringAsFixed(0)} km'
      : '${(distanceKm * 1000).toStringAsFixed(0)} m';

  /// Formatted duration
  String get durationLabel {
    final hours = durationHours.floor();
    final mins = ((durationHours - hours) * 60).round();
    if (hours == 0) return '$mins min';
    return '${hours}h ${mins}m';
  }

  /// Estimated transport cost (₹/quintal)
  /// Based on real distance: ~₹3.5/km/quintal for truck
  double get estimatedTransportCost => (distanceKm * 3.5).clamp(50, 5000);
}
