import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

/// Agriculture News Service — Uses Wikipedia APIs + Gemini AI.
/// Government schemes are fetched dynamically via AI.
class AgriNewsService {
  /// Fetch government schemes for a crop using Gemini AI.
  /// Falls back to static list if AI call fails.
  static Future<List<GovScheme>> fetchGovSchemesAI(String crop) async {
    try {
      final prompt =
          '''You are an Indian agriculture expert. 
List exactly 5 real Indian government schemes most relevant for a farmer growing "$crop". 
For each scheme respond ONLY with a JSON array, no extra text:
[
  {
    "name": "Scheme Name",
    "description": "1-line description in simple Hindi-English mix",
    "benefit": "Key benefit (e.g. ₹6,000/year)",
    "emoji": "relevant emoji",
    "url": "official scheme URL"
  }
]
Only return the JSON array. No markdown, no explanation.''';

      // ── Try Gemini Direct ─────────────────────────────────────────────
      final geminiResult = await _callGemini(prompt);
      if (geminiResult != null) {
        final schemes = _parseSchemes(geminiResult);
        if (schemes.isNotEmpty) return schemes;
      }

      // ── Fallback: Flask Proxy ─────────────────────────────────────────
      final proxyResult = await _callProxy(prompt);
      if (proxyResult != null) {
        final schemes = _parseSchemes(proxyResult);
        if (schemes.isNotEmpty) return schemes;
      }
    } catch (e) {
      debugPrint('GovSchemes AI error: $e');
    }

    // ── Final fallback: static list ────────────────────────────────────
    return getRelevantSchemes(crop);
  }

  /// Call Gemini API directly.
  static Future<String?> _callGemini(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.geminiBaseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.geminiApiKey}',
            },
            body: jsonEncode({
              'model': AppConfig.geminiModel,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.3,
              'max_tokens': 1000,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['choices']?[0]?['message']?['content']?.toString();
      }
      debugPrint('Gemini status: ${response.statusCode}');
    } catch (e) {
      debugPrint('Gemini call failed: $e');
    }
    return null;
  }

  /// Call Flask proxy (OpenRouter fallback).
  static Future<String?> _callProxy(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.proxyBaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': prompt}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['reply']?.toString();
      }
    } catch (e) {
      debugPrint('Proxy call failed: $e');
    }
    return null;
  }

  /// Parse AI response JSON into GovScheme list.
  static List<GovScheme> _parseSchemes(String raw) {
    try {
      // Extract JSON array from response (strip markdown fences if any)
      var cleaned = raw.trim();
      if (cleaned.contains('[')) {
        cleaned = cleaned.substring(cleaned.indexOf('['));
      }
      if (cleaned.contains(']')) {
        cleaned = cleaned.substring(0, cleaned.lastIndexOf(']') + 1);
      }

      final list = jsonDecode(cleaned) as List<dynamic>;
      return list
          .map(
            (item) => GovScheme(
              name: item['name']?.toString() ?? 'Scheme',
              description: item['description']?.toString() ?? '',
              benefit: item['benefit']?.toString() ?? '',
              emoji: item['emoji']?.toString() ?? '🏛️',
              url: item['url']?.toString() ?? 'https://farmer.gov.in',
            ),
          )
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('Scheme parse error: $e');
      return [];
    }
  }

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

  /// Returns government schemes RELEVANT to the selected crop.
  /// Each crop category gets targeted schemes (max 5).
  static List<GovScheme> getRelevantSchemes(String crop) {
    final cropLower = crop.toLowerCase();
    final schemes = <GovScheme>[];

    // ── Universal scheme (always relevant) ─────────────────────────────
    schemes.add(
      const GovScheme(
        name: 'PM-KISAN',
        description: '₹6,000/year direct income support to all farmer families',
        benefit: '₹6,000/year',
        emoji: '💰',
        url: 'https://pmkisan.gov.in',
      ),
    );

    // ── Crop insurance (relevant for all crops) ────────────────────────
    schemes.add(
      GovScheme(
        name: 'PM Fasal Bima Yojana',
        description:
            'Crop insurance at 1.5-2% premium — protects your $crop crop',
        benefit: 'Crop Insurance',
        emoji: '🛡️',
        url: 'https://pmfby.gov.in',
      ),
    );

    // ── Wheat / Rice / Paddy — MSP & Food Security ─────────────────────
    if (cropLower.contains('wheat') ||
        cropLower.contains('rice') ||
        cropLower.contains('paddy')) {
      schemes.add(
        GovScheme(
          name: 'MSP Procurement',
          description:
              'Sell $crop to govt at Minimum Support Price — guaranteed rate',
          benefit: 'Price Guarantee',
          emoji: '🏪',
          url: 'https://farmer.gov.in',
        ),
      );
      schemes.add(
        GovScheme(
          name: 'National Food Security Mission',
          description:
              'Free seeds, subsidized fertilizers & training for wheat/rice farmers',
          benefit: 'Free Seeds + Subsidy',
          emoji: '🌾',
          url: 'https://nfsm.gov.in',
        ),
      );
    }

    // ── Fruits & Vegetables — Horticulture + Cold Storage ──────────────
    if (_isFruitOrVeg(cropLower)) {
      schemes.add(
        GovScheme(
          name: 'Mission for Integrated Development of Horticulture',
          description:
              'Financial aid for $crop cultivation, cold chains & marketing',
          benefit: 'Up to ₹50,000/ha',
          emoji: '🌱',
          url: 'https://midh.gov.in',
        ),
      );
      schemes.add(
        GovScheme(
          name: 'PM Kisan SAMPADA',
          description:
              'Subsidy for cold storage & food processing units for $crop',
          benefit: 'Up to 70% subsidy',
          emoji: '🏭',
          url: 'https://mofpi.nic.in',
        ),
      );
    }

    // ── Cotton / Soybean / Groundnut — Oilseeds Mission ────────────────
    if (cropLower.contains('cotton') ||
        cropLower.contains('soybean') ||
        cropLower.contains('groundnut')) {
      schemes.add(
        GovScheme(
          name: 'National Mission on Oilseeds & Oil Palm',
          description:
              'Free seeds, input subsidy & technology support for $crop',
          benefit: 'Input Subsidy',
          emoji: '🌻',
          url: 'https://nmoop.gov.in',
        ),
      );
      schemes.add(
        GovScheme(
          name: 'MSP Procurement',
          description:
              'Sell $crop at Minimum Support Price — govt guaranteed rate',
          benefit: 'Price Guarantee',
          emoji: '🏪',
          url: 'https://farmer.gov.in',
        ),
      );
    }

    // ── Maize / Millets — Nutri Cereals Mission ────────────────────────
    if (cropLower.contains('maize') ||
        cropLower.contains('bajra') ||
        cropLower.contains('jowar') ||
        cropLower.contains('ragi') ||
        cropLower.contains('millet')) {
      schemes.add(
        GovScheme(
          name: 'National Mission on Nutri Cereals',
          description:
              'Subsidized seeds & training for millets and coarse cereals',
          benefit: 'Seed + Training Subsidy',
          emoji: '🌽',
          url: 'https://nfsm.gov.in',
        ),
      );
    }

    // ── Sugarcane ──────────────────────────────────────────────────────
    if (cropLower.contains('sugarcane')) {
      schemes.add(
        GovScheme(
          name: 'Fair & Remunerative Price (FRP)',
          description:
              'Govt-mandated minimum price for sugarcane at sugar mills',
          benefit: 'FRP Guarantee',
          emoji: '🍬',
          url: 'https://farmer.gov.in',
        ),
      );
    }

    // ── Pulses — Lentils, Chana, Moong ─────────────────────────────────
    if (cropLower.contains('dal') ||
        cropLower.contains('chana') ||
        cropLower.contains('moong') ||
        cropLower.contains('lentil') ||
        cropLower.contains('pulse') ||
        cropLower.contains('gram')) {
      schemes.add(
        GovScheme(
          name: 'National Food Security Mission — Pulses',
          description:
              'Subsidized seeds, equipment & training for pulse farmers',
          benefit: 'Free Seeds + Aid',
          emoji: '🫘',
          url: 'https://nfsm.gov.in',
        ),
      );
    }

    // ── Spices — Chilli, Turmeric ──────────────────────────────────────
    if (cropLower.contains('chilli') ||
        cropLower.contains('turmeric') ||
        cropLower.contains('pepper') ||
        cropLower.contains('ginger') ||
        cropLower.contains('garlic')) {
      schemes.add(
        GovScheme(
          name: 'Spices Board Subsidy Scheme',
          description:
              'Export promotion & quality improvement subsidy for $crop',
          benefit: 'Export Subsidy',
          emoji: '🌶️',
          url: 'https://www.indianspices.com',
        ),
      );
    }

    // ── eNAM (applicable if farmer wants to sell online) ───────────────
    schemes.add(
      GovScheme(
        name: 'eNAM - National Agri Market',
        description:
            'Sell $crop online to any mandi in India — transparent auction',
        benefit: 'Pan-India Market',
        emoji: '📲',
        url: 'https://enam.gov.in',
      ),
    );

    // Limit to 5 most relevant
    return schemes.take(5).toList();
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
