import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Frankfurter Exchange Rate API — Completely FREE, no API key needed.
/// Source: European Central Bank rates (https://www.frankfurter.app)
///
/// Shows farmers what their crop would fetch in international currency.
/// Useful for export-potential crops: Onion, Rice, Cotton, Spices.
class ExportPriceService {
  static const String _baseUrl = 'https://api.frankfurter.app/latest';

  /// Fetch current exchange rates from INR to major currencies.
  static Future<ExchangeRates?> fetchRates() async {
    try {
      final uri = Uri.parse('$_baseUrl?from=INR&to=USD,EUR,GBP,AED,JPY');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('ExportPrice: API returned ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = json['rates'] as Map<String, dynamic>? ?? {};

      return ExchangeRates(
        date: json['date'] as String? ?? '',
        inrToUsd: (rates['USD'] as num?)?.toDouble() ?? 0,
        inrToEur: (rates['EUR'] as num?)?.toDouble() ?? 0,
        inrToGbp: (rates['GBP'] as num?)?.toDouble() ?? 0,
        inrToAed: (rates['AED'] as num?)?.toDouble() ?? 0,
        inrToJpy: (rates['JPY'] as num?)?.toDouble() ?? 0,
      );
    } catch (e) {
      debugPrint('ExportPrice error: $e');
      return null;
    }
  }

  /// Calculate export price for a commodity.
  /// [priceInrPerQuintal] is the domestic mandi price.
  static ExportPriceResult? calculateExportPrice({
    required double priceInrPerQuintal,
    required ExchangeRates rates,
    required String crop,
  }) {
    // Export potential classification
    final exportCrops = {
      'rice': ExportInfo(
        exportDemand: 'High',
        majorMarkets: 'Middle East, Africa, EU',
        exportPremiumPercent: 15,
      ),
      'onion': ExportInfo(
        exportDemand: 'High',
        majorMarkets: 'Bangladesh, UAE, Malaysia',
        exportPremiumPercent: 10,
      ),
      'cotton': ExportInfo(
        exportDemand: 'Medium',
        majorMarkets: 'China, Bangladesh, Vietnam',
        exportPremiumPercent: 12,
      ),
      'wheat': ExportInfo(
        exportDemand: 'Medium',
        majorMarkets: 'Egypt, Turkey, Indonesia',
        exportPremiumPercent: 8,
      ),
      'soybean': ExportInfo(
        exportDemand: 'Medium',
        majorMarkets: 'EU, Japan, South Korea',
        exportPremiumPercent: 10,
      ),
      'groundnut': ExportInfo(
        exportDemand: 'Medium',
        majorMarkets: 'Indonesia, Vietnam, EU',
        exportPremiumPercent: 12,
      ),
      'chilli': ExportInfo(
        exportDemand: 'High',
        majorMarkets: 'USA, China, Mexico, Thailand',
        exportPremiumPercent: 20,
      ),
      'garlic': ExportInfo(
        exportDemand: 'Medium',
        majorMarkets: 'Bangladesh, UAE, Sri Lanka',
        exportPremiumPercent: 15,
      ),
      'mango': ExportInfo(
        exportDemand: 'High',
        majorMarkets: 'UAE, USA, EU, Japan',
        exportPremiumPercent: 25,
      ),
      'banana': ExportInfo(
        exportDemand: 'Medium',
        majorMarkets: 'Middle East, Japan',
        exportPremiumPercent: 10,
      ),
      'maize': ExportInfo(
        exportDemand: 'Medium',
        majorMarkets: 'Vietnam, Nepal, Malaysia',
        exportPremiumPercent: 8,
      ),
      'potato': ExportInfo(
        exportDemand: 'Low',
        majorMarkets: 'Nepal, Sri Lanka, Maldives',
        exportPremiumPercent: 5,
      ),
      'tomato': ExportInfo(
        exportDemand: 'Low',
        majorMarkets: 'Pakistan, UAE, Nepal',
        exportPremiumPercent: 5,
      ),
    };

    final cropLower = crop.toLowerCase();
    final info = exportCrops.entries
        .where((e) => cropLower.contains(e.key))
        .map((e) => e.value)
        .firstOrNull;

    if (info == null) return null;

    // Export price with premium
    final exportPriceInr =
        priceInrPerQuintal * (1 + info.exportPremiumPercent / 100);
    final priceUsd = exportPriceInr * rates.inrToUsd;
    final priceEur = exportPriceInr * rates.inrToEur;

    // Per metric ton (1 MT = 10 quintals)
    final priceUsdPerTon = priceUsd * 10;

    return ExportPriceResult(
      domesticPriceInr: priceInrPerQuintal,
      exportPriceInr: exportPriceInr,
      exportPriceUsd: priceUsd,
      exportPriceEur: priceEur,
      exportPriceUsdPerTon: priceUsdPerTon,
      exportPremiumPercent: info.exportPremiumPercent.toDouble(),
      exportDemand: info.exportDemand,
      majorMarkets: info.majorMarkets,
      rates: rates,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class ExchangeRates {
  final String date;
  final double inrToUsd;
  final double inrToEur;
  final double inrToGbp;
  final double inrToAed;
  final double inrToJpy;

  const ExchangeRates({
    required this.date,
    required this.inrToUsd,
    required this.inrToEur,
    required this.inrToGbp,
    required this.inrToAed,
    required this.inrToJpy,
  });

  String get formattedUsdRate => '₹${(1 / inrToUsd).toStringAsFixed(2)}';
}

class ExportInfo {
  final String exportDemand;
  final String majorMarkets;
  final int exportPremiumPercent;

  const ExportInfo({
    required this.exportDemand,
    required this.majorMarkets,
    required this.exportPremiumPercent,
  });
}

class ExportPriceResult {
  final double domesticPriceInr;
  final double exportPriceInr;
  final double exportPriceUsd;
  final double exportPriceEur;
  final double exportPriceUsdPerTon;
  final double exportPremiumPercent;
  final String exportDemand;
  final String majorMarkets;
  final ExchangeRates rates;

  const ExportPriceResult({
    required this.domesticPriceInr,
    required this.exportPriceInr,
    required this.exportPriceUsd,
    required this.exportPriceEur,
    required this.exportPriceUsdPerTon,
    required this.exportPremiumPercent,
    required this.exportDemand,
    required this.majorMarkets,
    required this.rates,
  });

  /// Extra income from export vs domestic
  double get extraIncomeInr => exportPriceInr - domesticPriceInr;

  String get demandEmoji {
    switch (exportDemand) {
      case 'High':
        return '🔥';
      case 'Medium':
        return '📊';
      default:
        return '📉';
    }
  }
}
