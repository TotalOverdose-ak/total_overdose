enum SpoilageRisk { low, medium, high }

class HarvestWindow {
  final String startDate; // e.g. "Mar 10"
  final String endDate; // e.g. "Mar 16"
  final String explanation;
  final int confidencePct;

  const HarvestWindow({
    required this.startDate,
    required this.endDate,
    required this.explanation,
    required this.confidencePct,
  });
}

class MandiRecommendation {
  final String mandiName;
  final String city;
  final double expectedPricePerQuintal; // in INR
  final double estimatedNetProfit; // in INR
  final double distanceKm;
  final String arrivalTime; // e.g. "~2 hrs"
  final List<double> last3DaysPrices; // for mini trend bar

  const MandiRecommendation({
    required this.mandiName,
    required this.city,
    required this.expectedPricePerQuintal,
    required this.estimatedNetProfit,
    required this.distanceKm,
    required this.arrivalTime,
    required this.last3DaysPrices,
  });
}

class PreservationSuggestion {
  final String title;
  final String description;
  final String costLabel; // "Low" / "Medium" / "High"
  final int effectivenessPct;
  final String iconEmoji;

  const PreservationSuggestion({
    required this.title,
    required this.description,
    required this.costLabel,
    required this.effectivenessPct,
    required this.iconEmoji,
  });
}

class WeatherSummary {
  final String condition;
  final int tempCelsius;
  final int humidityPct;
  final String rainForecast;
  final String iconEmoji;

  const WeatherSummary({
    required this.condition,
    required this.tempCelsius,
    required this.humidityPct,
    required this.rainForecast,
    required this.iconEmoji,
  });
}

class RecommendationResult {
  final String cropName;
  final String location;
  final HarvestWindow harvestWindow;
  final MandiRecommendation bestMandi;
  final SpoilageRisk spoilageRisk;
  final double spoilageRiskScore; // 0.0 – 1.0
  final List<PreservationSuggestion> preservationSuggestions;
  final WeatherSummary weather;
  final int overallConfidencePct;
  final DateTime generatedAt;
  final String motivationalQuote;

  const RecommendationResult({
    required this.cropName,
    required this.location,
    required this.harvestWindow,
    required this.bestMandi,
    required this.spoilageRisk,
    required this.spoilageRiskScore,
    required this.preservationSuggestions,
    required this.weather,
    required this.overallConfidencePct,
    required this.generatedAt,
    required this.motivationalQuote,
  });
}
