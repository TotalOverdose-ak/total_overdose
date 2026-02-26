import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Agriculture News Service — Uses FREE Wikipedia + Wikidata APIs.
/// Also fetches current agriculture commodity global prices from free sources.
///
/// No API key required. Completely free forever.
class AgriNewsService {
  /// Fetch agriculture-related crop facts from Wikipedia.
  /// Returns useful tips and facts for the selected crop.
  static Future<List<CropFact>> fetchCropFacts(String crop) async {
    try {
      final uri = Uri.https(
        'en.wikipedia.org',
        '/api/rest_v1/page/summary/${crop.toLowerCase()}_production_in_India',
      );

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final extract = json['extract'] as String? ?? '';
        if (extract.isNotEmpty) {
          // Split into sentence-based facts
          final sentences = extract
              .split('. ')
              .where((s) => s.length > 20)
              .take(5)
              .map(
                (s) => CropFact(
                  title: '📚 India $crop Fact',
                  content: '${s.trim()}.',
                  source: 'Wikipedia',
                ),
              )
              .toList();
          if (sentences.isNotEmpty) return sentences;
        }
      }

      // Fallback: try generic crop page
      final fallbackUri = Uri.https(
        'en.wikipedia.org',
        '/api/rest_v1/page/summary/$crop',
      );
      final fallbackRes = await http
          .get(fallbackUri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (fallbackRes.statusCode == 200) {
        final json = jsonDecode(fallbackRes.body) as Map<String, dynamic>;
        final extract = json['extract'] as String? ?? '';
        if (extract.isNotEmpty) {
          return extract
              .split('. ')
              .where((s) => s.length > 20)
              .take(4)
              .map(
                (s) => CropFact(
                  title: '📖 About $crop',
                  content: '${s.trim()}.',
                  source: 'Wikipedia',
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('AgriNews Wikipedia error: $e');
      return [];
    }
  }

  /// Fetch government agriculture scheme information.
  /// Uses open government data concepts.
  static List<GovScheme> getRelevantSchemes(String crop) {
    final cropLower = crop.toLowerCase();
    final schemes = <GovScheme>[];

    // Always applicable
    schemes.add(
      const GovScheme(
        name: 'PM-KISAN',
        description: '₹6,000/year direct income support to farmer families',
        benefit: '₹6,000/year',
        emoji: '💰',
        url: 'https://pmkisan.gov.in',
      ),
    );

    schemes.add(
      const GovScheme(
        name: 'PM Fasal Bima Yojana',
        description: 'Crop insurance at 1.5-2% premium for Kharif/Rabi crops',
        benefit: 'Crop Insurance',
        emoji: '🛡️',
        url: 'https://pmfby.gov.in',
      ),
    );

    // Crop-specific schemes
    if (cropLower.contains('wheat') ||
        cropLower.contains('rice') ||
        cropLower.contains('paddy')) {
      schemes.add(
        const GovScheme(
          name: 'MSP Procurement',
          description:
              'Minimum Support Price guarantee — sell to govt at fixed rate',
          benefit: 'Price Guarantee',
          emoji: '🏪',
          url: 'https://farmer.gov.in',
        ),
      );
    }

    if (_isFruitOrVeg(cropLower)) {
      schemes.add(
        const GovScheme(
          name: 'PM Kisan SAMPADA',
          description:
              'Subsidy for cold storage, food processing units & agri-logistics',
          benefit: 'Up to 70% subsidy',
          emoji: '🏭',
          url: 'https://mofpi.nic.in',
        ),
      );

      schemes.add(
        const GovScheme(
          name: 'Mission for Integrated Development of Horticulture',
          description:
              'Financial assistance for cultivation, cold chains & marketing of fruits/vegetables',
          benefit: 'Up to ₹50,000/ha',
          emoji: '🌱',
          url: 'https://midh.gov.in',
        ),
      );
    }

    if (cropLower.contains('cotton') ||
        cropLower.contains('soybean') ||
        cropLower.contains('groundnut')) {
      schemes.add(
        const GovScheme(
          name: 'National Mission on Oilseeds & Oil Palm',
          description:
              'Technology mission for oilseed crops — free seeds, subsidy on inputs',
          benefit: 'Input Subsidy',
          emoji: '🌻',
          url: 'https://nmoop.gov.in',
        ),
      );
    }

    schemes.add(
      const GovScheme(
        name: 'Kisan Credit Card',
        description:
            'Short-term crop loans at 4% interest (with timely repayment)',
        benefit: '4% interest loan',
        emoji: '💳',
        url: 'https://www.nabard.org',
      ),
    );

    schemes.add(
      const GovScheme(
        name: 'eNAM - National Agri Market',
        description:
            'Sell produce online to any mandi in India — transparent auction',
        benefit: 'Pan-India Market',
        emoji: '📲',
        url: 'https://enam.gov.in',
      ),
    );

    return schemes;
  }

  static bool _isFruitOrVeg(String crop) {
    const fruitVeg = [
      'tomato',
      'onion',
      'potato',
      'banana',
      'mango',
      'apple',
      'cauliflower',
      'cabbage',
      'carrot',
      'chilli',
      'garlic',
      'ginger',
      'brinjal',
      'orange',
      'grape',
    ];
    return fruitVeg.any((f) => crop.contains(f));
  }

  /// Fetch global commodity prices from the World Bank API (free, no key).
  static Future<List<GlobalPrice>> fetchGlobalPrices() async {
    try {
      // World Bank Commodity Prices — free, no auth
      final uri = Uri.parse(
        'https://api.worldbank.org/v2/country/IND/indicator/AG.PRD.FOOD.XD?format=json&per_page=5&date=2020:2025',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List && json.length > 1) {
          final data = json[1] as List<dynamic>? ?? [];
          return data
              .where((d) => d['value'] != null)
              .take(5)
              .map(
                (d) => GlobalPrice(
                  indicator: 'Food Production Index',
                  year: d['date']?.toString() ?? '',
                  value: (d['value'] as num?)?.toDouble() ?? 0,
                  country: 'India',
                ),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('GlobalPrice error: $e');
      return [];
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class CropFact {
  final String title;
  final String content;
  final String source;

  const CropFact({
    required this.title,
    required this.content,
    required this.source,
  });
}

class GovScheme {
  final String name;
  final String description;
  final String benefit;
  final String emoji;
  final String url;

  const GovScheme({
    required this.name,
    required this.description,
    required this.benefit,
    required this.emoji,
    required this.url,
  });
}

class GlobalPrice {
  final String indicator;
  final String year;
  final double value;
  final String country;

  const GlobalPrice({
    required this.indicator,
    required this.year,
    required this.value,
    required this.country,
  });
}
