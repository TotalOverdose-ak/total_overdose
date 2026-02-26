import '../models/crop_model.dart';
import '../models/recommendation_model.dart';
import '../models/history_model.dart';

class DummyData {
  // ── Crops ────────────────────────────────────────────────────────────────────
  static const List<CropModel> crops = [
    CropModel(
      id: 'tomato',
      name: 'Tomato',
      emoji: '🍅',
      nameSanskrit: 'Tamatar',
      imageAsset: 'assets/crops/tomato.png',
    ),
    CropModel(
      id: 'soybean',
      name: 'Soybean',
      emoji: '🌱',
      nameSanskrit: 'Soyabean',
      imageAsset: 'assets/crops/soybean.png',
    ),
    CropModel(
      id: 'onion',
      name: 'Onion',
      emoji: '🧅',
      nameSanskrit: 'Pyaz',
      imageAsset: 'assets/crops/onion.png',
    ),
    CropModel(
      id: 'wheat',
      name: 'Wheat',
      emoji: '🌾',
      nameSanskrit: 'Gehun',
      imageAsset: 'assets/crops/wheat.png',
    ),
    CropModel(
      id: 'maize',
      name: 'Maize',
      emoji: '🌽',
      nameSanskrit: 'Makka',
      imageAsset: 'assets/crops/maize.png',
    ),
    CropModel(
      id: 'potato',
      name: 'Potato',
      emoji: '🥔',
      nameSanskrit: 'Aloo',
      imageAsset: 'assets/crops/potato.png',
    ),
  ];

  // ── Locations ────────────────────────────────────────────────────────────────
  static const List<LocationModel> locations = [
    LocationModel(
      id: 'nagpur',
      name: 'Nagpur',
      state: 'Maharashtra',
      lat: 21.14,
      lng: 79.08,
    ),
    LocationModel(
      id: 'pune',
      name: 'Pune',
      state: 'Maharashtra',
      lat: 18.52,
      lng: 73.86,
    ),
    LocationModel(
      id: 'indore',
      name: 'Indore',
      state: 'Madhya Pradesh',
      lat: 22.71,
      lng: 75.86,
    ),
    LocationModel(
      id: 'nashik',
      name: 'Nashik',
      state: 'Maharashtra',
      lat: 19.99,
      lng: 73.79,
    ),
    LocationModel(
      id: 'lucknow',
      name: 'Lucknow',
      state: 'Uttar Pradesh',
      lat: 26.84,
      lng: 80.94,
    ),
    LocationModel(
      id: 'jaipur',
      name: 'Jaipur',
      state: 'Rajasthan',
      lat: 26.91,
      lng: 75.78,
    ),
    LocationModel(
      id: 'ahmedabad',
      name: 'Ahmedabad',
      state: 'Gujarat',
      lat: 23.02,
      lng: 72.57,
    ),
    LocationModel(
      id: 'bhopal',
      name: 'Bhopal',
      state: 'Madhya Pradesh',
      lat: 23.25,
      lng: 77.40,
    ),
  ];

  // ── Recommendation Result ────────────────────────────────────────────────────
  static final RecommendationResult sampleResult = RecommendationResult(
    cropName: 'Tomato 🍅',
    location: 'Nagpur, Maharashtra',
    harvestWindow: const HarvestWindow(
      startDate: 'Mar 10',
      endDate: 'Mar 14',
      explanation:
          'Soil moisture is optimal and night temperatures are cool enough to prevent over-ripening. '
          'Rain expected after Mar 16 may damage quality — harvest before then.',
      confidencePct: 87,
    ),
    bestMandi: const MandiRecommendation(
      mandiName: 'Nagpur APMC Mandi',
      city: 'Nagpur',
      expectedPricePerQuintal: 2850,
      estimatedNetProfit: 12400,
      distanceKm: 34,
      arrivalTime: '~1.5 hrs',
      last3DaysPrices: [2650, 2720, 2850],
    ),
    spoilageRisk: SpoilageRisk.medium,
    spoilageRiskScore: 0.52,
    preservationSuggestions: const [
      PreservationSuggestion(
        title: 'Store in cool room (10–15 °C)',
        description: 'Extend shelf life by 4–6 days. Avoid direct sunlight.',
        costLabel: 'Low',
        effectivenessPct: 88,
        iconEmoji: '🏠',
      ),
      PreservationSuggestion(
        title: 'Apply CaCl₂ coating',
        description: 'Calcium chloride spray firms the skin and delays decay.',
        costLabel: 'Medium',
        effectivenessPct: 76,
        iconEmoji: '💧',
      ),
      PreservationSuggestion(
        title: 'Pack in ventilated crates',
        description: 'Proper airflow reduces bruising and ethylene build-up.',
        costLabel: 'Low',
        effectivenessPct: 70,
        iconEmoji: '📦',
      ),
    ],
    weather: const WeatherSummary(
      condition: 'Partly Cloudy',
      tempCelsius: 29,
      humidityPct: 62,
      rainForecast: 'Rain in 5 days',
      iconEmoji: '⛅',
    ),
    overallConfidencePct: 84,
    generatedAt: DateTime(2026, 3, 5, 10, 30),
    motivationalQuote:
        '"A good farmer is one who harvests at the right time — not the earliest or the latest." 🌾',
  );

  // ── History List ─────────────────────────────────────────────────────────────
  static final List<HistoryEntry> historyEntries = [
    HistoryEntry(
      id: '1',
      cropName: 'Tomato',
      cropEmoji: '🍅',
      location: 'Nagpur, Maharashtra',
      harvestWindow: 'Mar 10 – Mar 14',
      pricePerQuintal: 2850,
      confidencePct: 84,
      date: DateTime(2026, 3, 5),
    ),
    HistoryEntry(
      id: '2',
      cropName: 'Onion',
      cropEmoji: '🧅',
      location: 'Nashik, Maharashtra',
      harvestWindow: 'Feb 20 – Feb 25',
      pricePerQuintal: 1900,
      confidencePct: 79,
      date: DateTime(2026, 2, 15),
    ),
    HistoryEntry(
      id: '3',
      cropName: 'Soybean',
      cropEmoji: '🌱',
      location: 'Indore, MP',
      harvestWindow: 'Jan 8 – Jan 14',
      pricePerQuintal: 4200,
      confidencePct: 91,
      date: DateTime(2026, 1, 3),
    ),
    HistoryEntry(
      id: '4',
      cropName: 'Wheat',
      cropEmoji: '🌾',
      location: 'Lucknow, UP',
      harvestWindow: 'Apr 5 – Apr 10',
      pricePerQuintal: 2150,
      confidencePct: 88,
      date: DateTime(2025, 12, 28),
    ),
  ];

  // ── Mandi Price Summaries ────────────────────────────────────────────────────
  static const List<MandiPriceSummary> mandiPrices = [
    MandiPriceSummary(
      mandiName: 'Nagpur APMC',
      city: 'Nagpur',
      state: 'Maharashtra',
      cropName: 'Tomato',
      cropEmoji: '🍅',
      todayPrice: 2850,
      yesterdayPrice: 2720,
      weekTrend: [2500, 2600, 2580, 2700, 2720, 2790, 2850],
    ),
    MandiPriceSummary(
      mandiName: 'Lasalgaon APMC',
      city: 'Nashik',
      state: 'Maharashtra',
      cropName: 'Onion',
      cropEmoji: '🧅',
      todayPrice: 1920,
      yesterdayPrice: 1950,
      weekTrend: [2100, 2050, 2000, 1970, 1950, 1940, 1920],
    ),
    MandiPriceSummary(
      mandiName: 'Indore Krishi Mandi',
      city: 'Indore',
      state: 'Madhya Pradesh',
      cropName: 'Soybean',
      cropEmoji: '🌱',
      todayPrice: 4320,
      yesterdayPrice: 4200,
      weekTrend: [4050, 4100, 4150, 4200, 4210, 4270, 4320],
    ),
    MandiPriceSummary(
      mandiName: 'Jaipur Grain Mandi',
      city: 'Jaipur',
      state: 'Rajasthan',
      cropName: 'Wheat',
      cropEmoji: '🌾',
      todayPrice: 2180,
      yesterdayPrice: 2150,
      weekTrend: [2100, 2110, 2120, 2140, 2150, 2160, 2180],
    ),
    MandiPriceSummary(
      mandiName: 'Pune Market Yard',
      city: 'Pune',
      state: 'Maharashtra',
      cropName: 'Potato',
      cropEmoji: '🥔',
      todayPrice: 1450,
      yesterdayPrice: 1500,
      weekTrend: [1600, 1570, 1540, 1520, 1500, 1480, 1450],
    ),
    MandiPriceSummary(
      mandiName: 'Bhopal APMC',
      city: 'Bhopal',
      state: 'Madhya Pradesh',
      cropName: 'Maize',
      cropEmoji: '🌽',
      todayPrice: 1870,
      yesterdayPrice: 1820,
      weekTrend: [1700, 1740, 1780, 1800, 1820, 1845, 1870],
    ),
  ];

  // ── Motivational Quotes ──────────────────────────────────────────────────────
  static const List<String> quotes = [
    '"The farmer is the only person in our economy who buys everything retail, sells everything wholesale." — John F. Kennedy',
    '"To be a good farmer, you must have a love of the land." 🌾',
    '"Farming looks easy when your plow is a pencil and you\'re a thousand miles from the corn field." — Dwight Eisenhower',
    '"The ultimate goal of farming is not the growing of crops, but the cultivation and perfection of human beings." — Masanobu Fukuoka',
    '"Those who labor in the earth are the chosen people of God." — Thomas Jefferson',
  ];
}
