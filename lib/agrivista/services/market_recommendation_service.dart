import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Market Recommendation Engine — Decision Intelligence for farmers.
///
/// Not just showing prices — this RECOMMENDS the best market to sell.
/// Factors: net price after travel, price volatility, arrival volume,
/// regional avg comparison, price trend.
class MarketRecommendationService {
  static const String _resourceId = '9ef84268-d588-465a-a308-a864a43d0070';
  static const String _baseUrl =
      'https://api.data.gov.in/resource/$_resourceId';
  static const String _apiKey =
      '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b';

  // ── Fetch Multi-Market Data ──────────────────────────────────────────────
  /// Fetches prices for a commodity across all available markets.
  static Future<List<MarketEntry>> fetchMarketsForCommodity(
      String commodity) async {
    try {
      final queryParams = <String, String>{
        'api-key': _apiKey,
        'format': 'json',
        'limit': '500',
        'offset': '0',
        'filters[commodity]': commodity,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('API error ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final records = json['records'] as List<dynamic>? ?? [];

      if (records.isEmpty) {
        debugPrint('MarketRecommendation: No API records, using fallback');
        return _fallbackMarkets(commodity);
      }

      return records.map((r) {
        final record = r as Map<String, dynamic>;
        return MarketEntry(
          state: _cleanString(record['state'] ?? ''),
          district: _cleanString(record['district'] ?? ''),
          market: _cleanString(record['market'] ?? ''),
          commodity: _cleanString(record['commodity'] ?? ''),
          variety: _cleanString(record['variety'] ?? ''),
          minPrice: _parsePrice(record['min_price']),
          maxPrice: _parsePrice(record['max_price']),
          modalPrice: _parsePrice(record['modal_price']),
          arrivalDate: _cleanString(record['arrival_date'] ?? ''),
        );
      }).toList();
    } catch (e) {
      debugPrint('MarketRecommendation fetch error: $e');
      return _fallbackMarkets(commodity);
    }
  }

  // ── Analyze & Rank Markets ───────────────────────────────────────────────
  /// Main intelligence engine: scores and ranks all markets for a commodity.
  ///
  /// Returns sorted list of [MarketScore] — best market first.
  static List<MarketScore> analyzeMarkets({
    required List<MarketEntry> entries,
    required String userCity,
    required String userState,
  }) {
    if (entries.isEmpty) return [];

    // ── Step 1: Group entries by market ──────────────────────────────────
    final marketGroups = <String, List<MarketEntry>>{};
    for (final e in entries) {
      final key = '${e.market}|${e.district}|${e.state}';
      marketGroups.putIfAbsent(key, () => []).add(e);
    }

    // ── Step 2: Calculate regional average ──────────────────────────────
    double totalModal = 0;
    int count = 0;
    for (final e in entries) {
      if (e.modalPrice > 0) {
        totalModal += e.modalPrice;
        count++;
      }
    }
    final regionalAvg = count > 0 ? totalModal / count : 0.0;

    // ── Step 3: Score each market ───────────────────────────────────────
    final scores = <MarketScore>[];

    for (final entry in marketGroups.entries) {
      final parts = entry.key.split('|');
      final market = parts[0];
      final district = parts[1];
      final state = parts[2];
      final marketEntries = entry.value;

      // Best entry (highest modal) for this market
      marketEntries.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));
      final best = marketEntries.first;

      // Price metrics
      final avgModal = marketEntries.fold<double>(
              0, (s, e) => s + e.modalPrice) /
          marketEntries.length;
      final avgMin = marketEntries.fold<double>(
              0, (s, e) => s + e.minPrice) /
          marketEntries.length;
      final avgMax = marketEntries.fold<double>(
              0, (s, e) => s + e.maxPrice) /
          marketEntries.length;

      // Volatility = spread / modal (lower = more stable)
      final spread = avgMax - avgMin;
      final volatility = avgModal > 0 ? spread / avgModal : 1.0;

      // Regional comparison
      final regionalDiffPercent = regionalAvg > 0
          ? ((avgModal - regionalAvg) / regionalAvg) * 100
          : 0.0;

      // Arrival volume proxy — more entries = more competition (bad for seller)
      final arrivalCount = marketEntries.length;

      // Travel cost estimate
      final travelCost = _estimateTravelCost(
        fromCity: userCity,
        fromState: userState,
        toMarket: market,
        toDistrict: district,
        toState: state,
      );

      // NET profit per quintal
      final netProfit = avgModal - travelCost;

      // ── Scoring Algorithm ──────────────────────────────────────────
      // Net Price Score (0-100): 40% weight
      // Higher net profit = better
      final maxPossibleProfit = entries
          .map((e) => e.modalPrice)
          .reduce((a, b) => a > b ? a : b);
      final netPriceScore = maxPossibleProfit > 0
          ? (netProfit / maxPossibleProfit * 100).clamp(0.0, 100.0)
          : 50.0;

      // Stability Score (0-100): 20% weight
      // Lower volatility = better
      final stabilityScore = ((1 - volatility.clamp(0.0, 1.0)) * 100);

      // Regional Advantage Score (0-100): 25% weight
      // Higher above regional avg = better
      final regionalScore =
          (50 + regionalDiffPercent * 2).clamp(0.0, 100.0);

      // Competition Score (0-100): 15% weight
      // Fewer entries = less competition = better for seller
      final maxArrivals = marketGroups.values
          .map((v) => v.length)
          .reduce((a, b) => a > b ? a : b);
      final competitionScore = maxArrivals > 1
          ? ((1 - (arrivalCount - 1) / (maxArrivals - 1)) * 100)
              .clamp(0.0, 100.0)
          : 80.0;

      // Weighted total
      final overallScore = netPriceScore * 0.40 +
          stabilityScore * 0.20 +
          regionalScore * 0.25 +
          competitionScore * 0.15;

      // ── Build reasons ─────────────────────────────────────────────
      final reasons = <String>[];
      final warnings = <String>[];

      if (regionalDiffPercent > 5) {
        reasons.add(
            'Modal price ${regionalDiffPercent.toStringAsFixed(1)}% above regional avg');
      }
      if (volatility < 0.15) {
        reasons.add('Very stable prices (low volatility)');
      }
      if (arrivalCount <= 2) {
        reasons.add('Low arrival volume — less competition');
      }
      if (travelCost < 200) {
        reasons.add('Nearby market — low travel cost');
      }
      if (netProfit > regionalAvg * 0.9) {
        reasons.add('Strong net profit after transport');
      }

      if (regionalDiffPercent < -5) {
        warnings
            .add('${(-regionalDiffPercent).toStringAsFixed(1)}% below regional avg');
      }
      if (volatility > 0.3) {
        warnings.add('High price volatility — risky');
      }
      if (arrivalCount > 5) {
        warnings.add('High arrival volume — competitive market');
      }
      if (travelCost > 500) {
        warnings.add('Far market — high transport cost ₹$travelCost');
      }

      // ── Transit time & spoilage risk ────────────────────────────────
      final transitHours = _estimateTransitHours(
        fromCity: userCity,
        fromState: userState,
        toMarket: market,
        toDistrict: district,
        toState: state,
      );

      final isPerishable = _isPerishableCrop(best.commodity);
      final spoilageRisk = _calcTransitSpoilageRisk(
        crop: best.commodity,
        transitHours: transitHours,
        isPerishable: isPerishable,
      );

      if (isPerishable && transitHours > 8) {
        warnings.add('Perishable crop — ${transitHours.toStringAsFixed(0)}h transit increases spoilage');
      }
      if (spoilageRisk > 15) {
        warnings.add('Spoilage risk: ~${spoilageRisk.toStringAsFixed(0)}% loss expected in transit');
      }
      if (isPerishable && transitHours <= 4) {
        reasons.add('Short transit (${transitHours.toStringAsFixed(0)}h) — minimal spoilage');
      }

      scores.add(MarketScore(
        market: market,
        district: district,
        state: state,
        commodity: best.commodity,
        variety: best.variety,
        modalPrice: avgModal,
        minPrice: avgMin,
        maxPrice: avgMax,
        priceSpread: spread,
        volatility: volatility,
        regionalAvg: regionalAvg,
        regionalDiffPercent: regionalDiffPercent,
        estimatedTravelCost: travelCost,
        netProfit: netProfit,
        arrivalCount: arrivalCount,
        netPriceScore: netPriceScore,
        stabilityScore: stabilityScore,
        regionalScore: regionalScore,
        competitionScore: competitionScore,
        overallScore: overallScore,
        reasons: reasons,
        warnings: warnings,
        transitHours: transitHours,
        spoilageRiskPercent: spoilageRisk,
        isPerishable: isPerishable,
      ));
    }

    // Sort by overall score, best first
    scores.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    return scores;
  }

  // ── Travel Cost Estimation ───────────────────────────────────────────────
  /// Estimates transport cost in ₹/quintal based on distance proxy.
  ///
  /// Uses a city-distance lookup for major mandis. For unknown pairs,
  /// estimates based on same-state/different-state heuristic.
  static double _estimateTravelCost({
    required String fromCity,
    required String fromState,
    required String toMarket,
    required String toDistrict,
    required String toState,
  }) {
    // Normalize
    final from = fromCity.toLowerCase().trim();
    final to = toMarket.toLowerCase().trim();
    final toDist = toDistrict.toLowerCase().trim();

    // Same city = minimal cost
    if (from == to || from == toDist) return 50; // just local transport

    // Known distance pairs (approximate km between major Indian mandis)
    final distKm = _getApproxDistance(from, to.isNotEmpty ? to : toDist);

    if (distKm != null) {
      // Transport rate: ~₹3-5 per km per quintal (truck sharing)
      return (distKm * 3.5).clamp(50, 3000);
    }

    // Heuristic: same state vs different state
    if (fromState.toLowerCase() == toState.toLowerCase()) {
      // Same state — moderate distance
      return 250; // avg intra-state cost
    } else {
      // Different state — higher cost
      final adjacentStates = _adjacentStates[fromState.toLowerCase()];
      if (adjacentStates != null &&
          adjacentStates.contains(toState.toLowerCase())) {
        return 450; // neighboring state
      }
      return 700; // far state
    }
  }

  /// Approximate distances (km) between major mandi cities.
  static double? _getApproxDistance(String city1, String city2) {
    final key1 = '${city1}_$city2';
    final key2 = '${city2}_$city1';
    return _distanceMap[key1] ?? _distanceMap[key2];
  }

  static const Map<String, double> _distanceMap = {
    // Maharashtra
    'nagpur_pune': 720,
    'nagpur_nashik': 600,
    'nagpur_mumbai': 840,
    'nagpur_aurangabad': 480,
    'nagpur_amravati': 155,
    'nagpur_akola': 250,
    'nagpur_latur': 460,
    'pune_nashik': 210,
    'pune_mumbai': 150,
    'pune_aurangabad': 240,
    'mumbai_nashik': 170,
    // MP
    'nagpur_indore': 560,
    'nagpur_bhopal': 350,
    'nagpur_jabalpur': 330,
    'indore_bhopal': 195,
    'indore_ujjain': 55,
    'bhopal_jabalpur': 330,
    // Rajasthan
    'nagpur_jaipur': 900,
    'jaipur_jodhpur': 340,
    'jaipur_kota': 250,
    'jaipur_udaipur': 395,
    // UP
    'nagpur_lucknow': 700,
    'nagpur_agra': 800,
    'lucknow_agra': 330,
    'lucknow_varanasi': 320,
    'lucknow_kanpur': 80,
    'agra_delhi': 230,
    // Cross-state
    'indore_jaipur': 580,
    'bhopal_lucknow': 520,
    'pune_indore': 580,
    'mumbai_indore': 590,
    'nashik_indore': 420,
    'delhi_jaipur': 280,
    'delhi_lucknow': 560,
  };

  // ── Transit Time Estimation ──────────────────────────────────────────────
  /// Estimates transit time in hours to a target market.
  static double _estimateTransitHours({
    required String fromCity,
    required String fromState,
    required String toMarket,
    required String toDistrict,
    required String toState,
  }) {
    final from = fromCity.toLowerCase().trim();
    final to = toMarket.toLowerCase().trim();
    final toDist = toDistrict.toLowerCase().trim();

    if (from == to || from == toDist) return 1.0; // Same city

    final distKm = _getApproxDistance(from, to.isNotEmpty ? to : toDist);
    if (distKm != null) {
      // Average truck speed: 35-45 km/h on Indian highways + loading
      return (distKm / 40) + 1; // +1 hour for loading/unloading
    }

    if (fromState.toLowerCase() == toState.toLowerCase()) {
      return 7; // Avg intra-state transit
    }

    final adjacentStates = _adjacentStates[fromState.toLowerCase()];
    if (adjacentStates != null && adjacentStates.contains(toState.toLowerCase())) {
      return 12; // Adjacent state
    }
    return 18; // Far state
  }

  /// Check if a crop is perishable
  static bool _isPerishableCrop(String commodity) {
    final c = commodity.toLowerCase();
    return c.contains('tomato') || c.contains('onion') || c.contains('potato') ||
        c.contains('banana') || c.contains('mango') || c.contains('apple') ||
        c.contains('cauliflower') || c.contains('cabbage') || c.contains('chilli') ||
        c.contains('brinjal') || c.contains('carrot') || c.contains('garlic') ||
        c.contains('ginger') || c.contains('orange') || c.contains('grape');
  }

  /// Calculate spoilage risk % based on crop type and transit hours
  static double _calcTransitSpoilageRisk({
    required String crop,
    required double transitHours,
    required bool isPerishable,
  }) {
    if (!isPerishable) {
      // Grains/fibers: very low spoilage
      if (transitHours > 24) return 2;
      return 0.5;
    }

    // Perishable crops: spoilage increases with time
    // Base spoilage rate per hour (without cold chain)
    final c = crop.toLowerCase();
    double ratePerHour;
    if (c.contains('tomato') || c.contains('banana') || c.contains('mango')) {
      ratePerHour = 2.5; // Very perishable
    } else if (c.contains('onion') || c.contains('potato') || c.contains('garlic')) {
      ratePerHour = 1.0; // Moderately perishable
    } else {
      ratePerHour = 1.8; // Default perishable
    }

    // First 4 hours: minimal spoilage
    if (transitHours <= 4) return (transitHours * ratePerHour * 0.3).clamp(0, 5);
    // 4-8 hours: moderate
    if (transitHours <= 8) return (4 * ratePerHour * 0.3 + (transitHours - 4) * ratePerHour * 0.8).clamp(0, 25);
    // 8+ hours: accelerated spoilage
    return (4 * ratePerHour * 0.3 + 4 * ratePerHour * 0.8 + (transitHours - 8) * ratePerHour * 1.5).clamp(0, 50);
  }

  /// Adjacent state lookup for transport cost estimation.
  static const Map<String, List<String>> _adjacentStates = {
    'maharashtra': [
      'madhya pradesh',
      'gujarat',
      'karnataka',
      'telangana',
      'goa',
      'chhattisgarh'
    ],
    'madhya pradesh': [
      'maharashtra',
      'rajasthan',
      'uttar pradesh',
      'gujarat',
      'chhattisgarh'
    ],
    'rajasthan': [
      'madhya pradesh',
      'gujarat',
      'haryana',
      'uttar pradesh',
      'punjab'
    ],
    'uttar pradesh': [
      'madhya pradesh',
      'rajasthan',
      'haryana',
      'uttarakhand',
      'bihar',
      'jharkhand'
    ],
    'gujarat': ['maharashtra', 'rajasthan', 'madhya pradesh'],
    'karnataka': ['maharashtra', 'goa', 'kerala', 'tamil nadu', 'telangana'],
    'tamil nadu': ['karnataka', 'kerala', 'andhra pradesh'],
    'telangana': ['maharashtra', 'karnataka', 'andhra pradesh', 'chhattisgarh'],
    'punjab': ['haryana', 'rajasthan', 'himachal pradesh'],
    'haryana': ['punjab', 'rajasthan', 'uttar pradesh', 'delhi'],
    'bihar': ['uttar pradesh', 'jharkhand', 'west bengal'],
    'west bengal': ['bihar', 'jharkhand', 'odisha'],
  };

  // ── Helpers ──────────────────────────────────────────────────────────────
  static String _cleanString(String s) {
    return s
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  // ── Fallback Data ────────────────────────────────────────────────────────
  static List<MarketEntry> _fallbackMarkets(String commodity) {
    final c = commodity.toLowerCase();
    if (c.contains('wheat')) return _wheatFallback;
    if (c.contains('tomato')) return _tomatoFallback;
    if (c.contains('onion')) return _onionFallback;
    if (c.contains('soybean') || c.contains('soya')) return _soybeanFallback;
    if (c.contains('potato')) return _potatoFallback;
    if (c.contains('rice') || c.contains('paddy')) return _riceFallback;
    if (c.contains('cotton')) return _cottonFallback;
    if (c.contains('maize')) return _maizeFallback;
    // Generic fallback
    return _tomatoFallback;
  }

  static final _tomatoFallback = [
    MarketEntry(state: 'Maharashtra', district: 'Nagpur', market: 'Nagpur', commodity: 'Tomato', variety: 'Local', minPrice: 2200, maxPrice: 3200, modalPrice: 2850, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Maharashtra', district: 'Pune', market: 'Pune', commodity: 'Tomato', variety: 'Hybrid', minPrice: 2800, maxPrice: 3800, modalPrice: 3300, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Maharashtra', district: 'Nashik', market: 'Nashik', commodity: 'Tomato', variety: 'Hybrid', minPrice: 2400, maxPrice: 3400, modalPrice: 2900, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Indore', market: 'Indore', commodity: 'Tomato', variety: 'Local', minPrice: 2000, maxPrice: 3100, modalPrice: 2650, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Uttar Pradesh', district: 'Lucknow', market: 'Lucknow', commodity: 'Tomato', variety: 'Hybrid', minPrice: 2000, maxPrice: 3000, modalPrice: 2600, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Rajasthan', district: 'Jaipur', market: 'Jaipur', commodity: 'Tomato', variety: 'Local', minPrice: 2300, maxPrice: 3300, modalPrice: 2750, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Maharashtra', district: 'Mumbai', market: 'Vashi', commodity: 'Tomato', variety: 'Hybrid', minPrice: 3200, maxPrice: 4200, modalPrice: 3700, arrivalDate: '27/02/2026'),
  ];

  static final _onionFallback = [
    MarketEntry(state: 'Maharashtra', district: 'Nashik', market: 'Lasalgaon', commodity: 'Onion', variety: 'Red', minPrice: 1500, maxPrice: 2400, modalPrice: 1920, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Maharashtra', district: 'Pune', market: 'Pune', commodity: 'Onion', variety: 'White', minPrice: 1800, maxPrice: 2600, modalPrice: 2100, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Maharashtra', district: 'Nagpur', market: 'Nagpur', commodity: 'Onion', variety: 'Red', minPrice: 1600, maxPrice: 2300, modalPrice: 1950, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Indore', market: 'Indore', commodity: 'Onion', variety: 'Red', minPrice: 1700, maxPrice: 2500, modalPrice: 2050, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Rajasthan', district: 'Jaipur', market: 'Jaipur', commodity: 'Onion', variety: 'Local', minPrice: 1400, maxPrice: 2200, modalPrice: 1800, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Gujarat', district: 'Ahmedabad', market: 'Ahmedabad', commodity: 'Onion', variety: 'Red', minPrice: 1900, maxPrice: 2700, modalPrice: 2250, arrivalDate: '27/02/2026'),
  ];

  static final _wheatFallback = [
    MarketEntry(state: 'Rajasthan', district: 'Jaipur', market: 'Jaipur', commodity: 'Wheat', variety: 'Lokwan', minPrice: 1900, maxPrice: 2400, modalPrice: 2180, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Rajasthan', district: 'Jodhpur', market: 'Jodhpur', commodity: 'Wheat', variety: 'Sharbati', minPrice: 2100, maxPrice: 2600, modalPrice: 2350, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Indore', market: 'Indore', commodity: 'Wheat', variety: 'Sehore', minPrice: 2000, maxPrice: 2500, modalPrice: 2280, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Bhopal', market: 'Bhopal', commodity: 'Wheat', variety: 'Lokwan', minPrice: 1950, maxPrice: 2450, modalPrice: 2200, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Uttar Pradesh', district: 'Lucknow', market: 'Lucknow', commodity: 'Wheat', variety: 'PBW-343', minPrice: 2100, maxPrice: 2550, modalPrice: 2320, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Uttar Pradesh', district: 'Agra', market: 'Agra', commodity: 'Wheat', variety: 'Sharbati', minPrice: 2050, maxPrice: 2500, modalPrice: 2260, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Haryana', district: 'Karnal', market: 'Karnal', commodity: 'Wheat', variety: 'HD-2967', minPrice: 2200, maxPrice: 2650, modalPrice: 2420, arrivalDate: '27/02/2026'),
  ];

  static final _soybeanFallback = [
    MarketEntry(state: 'Maharashtra', district: 'Nagpur', market: 'Nagpur', commodity: 'Soybean', variety: 'JS-335', minPrice: 4000, maxPrice: 4600, modalPrice: 4250, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Indore', market: 'Indore', commodity: 'Soybean', variety: 'Yellow', minPrice: 3800, maxPrice: 4800, modalPrice: 4320, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Bhopal', market: 'Bhopal', commodity: 'Soybean', variety: 'JS-335', minPrice: 3900, maxPrice: 4700, modalPrice: 4200, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Maharashtra', district: 'Amravati', market: 'Amravati', commodity: 'Soybean', variety: 'Yellow', minPrice: 4100, maxPrice: 4700, modalPrice: 4350, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Rajasthan', district: 'Kota', market: 'Kota', commodity: 'Soybean', variety: 'JS-335', minPrice: 3700, maxPrice: 4500, modalPrice: 4100, arrivalDate: '27/02/2026'),
  ];

  static final _potatoFallback = [
    MarketEntry(state: 'Maharashtra', district: 'Pune', market: 'Pune', commodity: 'Potato', variety: 'Jyoti', minPrice: 1100, maxPrice: 1800, modalPrice: 1450, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Uttar Pradesh', district: 'Agra', market: 'Agra', commodity: 'Potato', variety: 'Kufri Jyoti', minPrice: 900, maxPrice: 1500, modalPrice: 1200, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Uttar Pradesh', district: 'Lucknow', market: 'Lucknow', commodity: 'Potato', variety: 'Jyoti', minPrice: 950, maxPrice: 1400, modalPrice: 1180, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Indore', market: 'Indore', commodity: 'Potato', variety: 'Local', minPrice: 1000, maxPrice: 1600, modalPrice: 1300, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'West Bengal', district: 'Hooghly', market: 'Hooghly', commodity: 'Potato', variety: 'Jyoti', minPrice: 800, maxPrice: 1300, modalPrice: 1050, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Gujarat', district: 'Ahmedabad', market: 'Ahmedabad', commodity: 'Potato', variety: 'Local', minPrice: 1050, maxPrice: 1700, modalPrice: 1380, arrivalDate: '27/02/2026'),
  ];

  static final _riceFallback = [
    MarketEntry(state: 'Uttar Pradesh', district: 'Lucknow', market: 'Lucknow', commodity: 'Rice', variety: 'Basmati', minPrice: 3200, maxPrice: 4200, modalPrice: 3700, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Punjab', district: 'Amritsar', market: 'Amritsar', commodity: 'Rice', variety: 'Basmati', minPrice: 3500, maxPrice: 4500, modalPrice: 4000, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Haryana', district: 'Karnal', market: 'Karnal', commodity: 'Rice', variety: '1121', minPrice: 3400, maxPrice: 4300, modalPrice: 3850, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'West Bengal', district: 'Burdwan', market: 'Burdwan', commodity: 'Rice', variety: 'Swarna', minPrice: 2200, maxPrice: 2800, modalPrice: 2500, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Bihar', district: 'Patna', market: 'Patna', commodity: 'Rice', variety: 'HMT', minPrice: 2800, maxPrice: 3600, modalPrice: 3200, arrivalDate: '27/02/2026'),
  ];

  static final _cottonFallback = [
    MarketEntry(state: 'Maharashtra', district: 'Nagpur', market: 'Nagpur', commodity: 'Cotton', variety: 'H-4', minPrice: 6000, maxPrice: 7200, modalPrice: 6600, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Gujarat', district: 'Rajkot', market: 'Rajkot', commodity: 'Cotton', variety: 'Shankar-6', minPrice: 6200, maxPrice: 7500, modalPrice: 6900, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Maharashtra', district: 'Amravati', market: 'Amravati', commodity: 'Cotton', variety: 'H-4', minPrice: 5800, maxPrice: 7000, modalPrice: 6400, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Madhya Pradesh', district: 'Khandwa', market: 'Khandwa', commodity: 'Cotton', variety: 'H-4', minPrice: 5900, maxPrice: 7100, modalPrice: 6500, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Telangana', district: 'Adilabad', market: 'Adilabad', commodity: 'Cotton', variety: 'MCU-5', minPrice: 6100, maxPrice: 7300, modalPrice: 6700, arrivalDate: '27/02/2026'),
  ];

  static final _maizeFallback = [
    MarketEntry(state: 'Madhya Pradesh', district: 'Bhopal', market: 'Bhopal', commodity: 'Maize', variety: 'Yellow', minPrice: 1500, maxPrice: 2200, modalPrice: 1870, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Karnataka', district: 'Davangere', market: 'Davangere', commodity: 'Maize', variety: 'Yellow', minPrice: 1600, maxPrice: 2100, modalPrice: 1850, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Rajasthan', district: 'Udaipur', market: 'Udaipur', commodity: 'Maize', variety: 'Local', minPrice: 1400, maxPrice: 2000, modalPrice: 1700, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Bihar', district: 'Patna', market: 'Patna', commodity: 'Maize', variety: 'Yellow', minPrice: 1450, maxPrice: 1950, modalPrice: 1720, arrivalDate: '27/02/2026'),
    MarketEntry(state: 'Uttar Pradesh', district: 'Lucknow', market: 'Lucknow', commodity: 'Maize', variety: 'Yellow', minPrice: 1550, maxPrice: 2100, modalPrice: 1800, arrivalDate: '27/02/2026'),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

/// Raw market entry from data.gov.in API
class MarketEntry {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String arrivalDate;

  const MarketEntry({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    this.variety = '',
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    this.arrivalDate = '',
  });
}

/// Scored & ranked market with full analysis
class MarketScore {
  final String market;
  final String district;
  final String state;
  final String commodity;
  final String variety;
  final double modalPrice;
  final double minPrice;
  final double maxPrice;
  final double priceSpread;
  final double volatility; // 0-1, lower = more stable
  final double regionalAvg;
  final double regionalDiffPercent; // positive = above avg
  final double estimatedTravelCost;
  final double netProfit; // modalPrice - travelCost
  final int arrivalCount; // proxy for arrival volume
  final double netPriceScore; // 0-100
  final double stabilityScore; // 0-100
  final double regionalScore; // 0-100
  final double competitionScore; // 0-100
  final double overallScore; // 0-100 weighted
  final List<String> reasons;
  final List<String> warnings;
  final double transitHours;
  final double spoilageRiskPercent;
  final bool isPerishable;

  const MarketScore({
    required this.market,
    required this.district,
    required this.state,
    required this.commodity,
    this.variety = '',
    required this.modalPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.priceSpread,
    required this.volatility,
    required this.regionalAvg,
    required this.regionalDiffPercent,
    required this.estimatedTravelCost,
    required this.netProfit,
    required this.arrivalCount,
    required this.netPriceScore,
    required this.stabilityScore,
    required this.regionalScore,
    required this.competitionScore,
    required this.overallScore,
    required this.reasons,
    required this.warnings,
    this.transitHours = 0,
    this.spoilageRiskPercent = 0,
    this.isPerishable = false,
  });

  /// Overall grade
  String get grade {
    if (overallScore >= 75) return 'A';
    if (overallScore >= 60) return 'B';
    if (overallScore >= 45) return 'C';
    return 'D';
  }

  /// Grade color hint
  String get gradeLabel {
    if (overallScore >= 75) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    if (overallScore >= 45) return 'Average';
    return 'Below Average';
  }

  /// Is this the recommended market?
  bool get isRecommended => overallScore >= 65;

  /// Emoji for commodity
  String get commodityEmoji {
    final lower = commodity.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('wheat')) return '🌾';
    if (lower.contains('rice') || lower.contains('paddy')) return '🍚';
    if (lower.contains('maize') || lower.contains('corn')) return '🌽';
    if (lower.contains('soybean') || lower.contains('soya')) return '🌱';
    if (lower.contains('cotton')) return '🧶';
    if (lower.contains('sugar')) return '🍬';
    if (lower.contains('groundnut')) return '🥜';
    return '🌿';
  }
}
