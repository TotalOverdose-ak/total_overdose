class HistoryEntry {
  final String id;
  final String cropName;
  final String cropEmoji;
  final String location;
  final String harvestWindow;
  final double pricePerQuintal;
  final int confidencePct;
  final DateTime date;

  const HistoryEntry({
    required this.id,
    required this.cropName,
    required this.cropEmoji,
    required this.location,
    required this.harvestWindow,
    required this.pricePerQuintal,
    required this.confidencePct,
    required this.date,
  });

  // ── JSON serialization for SharedPreferences persistence ────────────
  Map<String, dynamic> toJson() => {
    'id': id,
    'cropName': cropName,
    'cropEmoji': cropEmoji,
    'location': location,
    'harvestWindow': harvestWindow,
    'pricePerQuintal': pricePerQuintal,
    'confidencePct': confidencePct,
    'date': date.toIso8601String(),
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'] as String? ?? '',
    cropName: json['cropName'] as String? ?? '',
    cropEmoji: json['cropEmoji'] as String? ?? '🌾',
    location: json['location'] as String? ?? '',
    harvestWindow: json['harvestWindow'] as String? ?? '',
    pricePerQuintal: (json['pricePerQuintal'] as num?)?.toDouble() ?? 0,
    confidencePct: (json['confidencePct'] as num?)?.toInt() ?? 0,
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
  );
}

class MandiPriceSummary {
  final String mandiName;
  final String city;
  final String state;
  final String cropName;
  final String cropEmoji;
  final double todayPrice;
  final double yesterdayPrice;
  final List<double> weekTrend; // 7 values

  const MandiPriceSummary({
    required this.mandiName,
    required this.city,
    required this.state,
    required this.cropName,
    required this.cropEmoji,
    required this.todayPrice,
    required this.yesterdayPrice,
    required this.weekTrend,
  });

  double get changePercent =>
      ((todayPrice - yesterdayPrice) / yesterdayPrice) * 100;

  bool get isUp => todayPrice >= yesterdayPrice;
}
