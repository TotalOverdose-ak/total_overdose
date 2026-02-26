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
