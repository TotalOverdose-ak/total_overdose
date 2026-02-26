import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import '../services/mandi_ai_service.dart';

/// Provider that fetches LIVE mandi prices from the Government of India
/// data.gov.in API (Agmarknet – Daily Commodity Price List).
///
/// API: https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070
///
/// To get your FREE API key:
///   1. Go to https://data.gov.in/user/register
///   2. Register → verify email → go to dashboard
///   3. Generate an API key
///   4. Paste it in [_apiKey] below
class MandiProvider extends ChangeNotifier {
  // ── Configuration ─────────────────────────────────────────────────────────
  static const String _resourceId = '9ef84268-d588-465a-a308-a864a43d0070';
  static const String _baseUrl =
      'https://api.data.gov.in/resource/$_resourceId';

  /// 🔑 YOUR data.gov.in API key – get it free at https://data.gov.in
  static const String _apiKey =
      '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b';

  // ── State ─────────────────────────────────────────────────────────────────
  List<LiveMandiPrice> _prices = [];
  List<LiveMandiPrice> _filteredPrices = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // Filters
  String _selectedState = 'All';
  String _selectedCommodity = 'All';
  String _searchQuery = '';

  List<String> _availableStates = ['All'];
  List<String> _availableCommodities = ['All'];

  // AI Chat state
  List<ChatMessage> _chatMessages = [];
  bool _isChatLoading = false;
  String _chatLanguage = 'Hinglish';

  // AI Feature state
  String? _negotiationAdvice;
  bool _isNegotiationLoading = false;
  String? _priceInsight;
  bool _isPriceInsightLoading = false;
  List<String> _smartPhrases = [];
  bool _isPhrasesLoading = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<LiveMandiPrice> get prices => _filteredPrices;
  List<LiveMandiPrice> get allPrices => _prices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  String get selectedState => _selectedState;
  String get selectedCommodity => _selectedCommodity;
  List<String> get availableStates => _availableStates;
  List<String> get availableCommodities => _availableCommodities;

  // AI Getters
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isChatLoading => _isChatLoading;
  String get chatLanguage => _chatLanguage;
  String? get negotiationAdvice => _negotiationAdvice;
  bool get isNegotiationLoading => _isNegotiationLoading;
  String? get priceInsight => _priceInsight;
  bool get isPriceInsightLoading => _isPriceInsightLoading;
  List<String> get smartPhrases => _smartPhrases;
  bool get isPhrasesLoading => _isPhrasesLoading;

  // ── Constructor ───────────────────────────────────────────────────────────
  MandiProvider() {
    fetchMandiPrices();
  }

  // ── Fetch Live Data ───────────────────────────────────────────────────────
  Future<void> fetchMandiPrices({String? state, String? commodity}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'api-key': _apiKey,
        'format': 'json',
        'limit': '500',
        'offset': '0',
      };

      // Apply API-level filters
      if (state != null && state != 'All') {
        queryParams['filters[state]'] = state;
      }
      if (commodity != null && commodity != 'All') {
        queryParams['filters[commodity]'] = commodity;
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final records = json['records'] as List<dynamic>? ?? [];

      if (records.isEmpty) {
        // If API returns empty, fall back to dummy data
        _useFallbackData();
        return;
      }

      _prices = records.map((r) {
        final record = r as Map<String, dynamic>;
        return LiveMandiPrice(
          state: _cleanString(record['state'] ?? ''),
          district: _cleanString(record['district'] ?? ''),
          market: _cleanString(record['market'] ?? ''),
          commodity: _cleanString(record['commodity'] ?? ''),
          variety: _cleanString(record['variety'] ?? ''),
          grade: _cleanString(record['grade'] ?? ''),
          minPrice: _parsePrice(record['min_price']),
          maxPrice: _parsePrice(record['max_price']),
          modalPrice: _parsePrice(record['modal_price']),
          arrivalDate: _cleanString(record['arrival_date'] ?? ''),
        );
      }).toList();

      // Sort by modal price descending
      _prices.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));

      // Build available filter lists
      final stateSet = <String>{'All'};
      final commoditySet = <String>{'All'};
      for (final p in _prices) {
        if (p.state.isNotEmpty) stateSet.add(p.state);
        if (p.commodity.isNotEmpty) commoditySet.add(p.commodity);
      }
      _availableStates = stateSet.toList()..sort();
      _availableCommodities = commoditySet.toList()..sort();

      _lastUpdated = DateTime.now();
      _applyLocalFilters();
    } catch (e) {
      debugPrint('MandiProvider error: $e');
      if (_prices.isEmpty) {
        _useFallbackData();
      } else {
        _errorMessage = 'Update failed. Showing cached data.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filters ───────────────────────────────────────────────────────────────
  void setStateFilter(String state) {
    _selectedState = state;
    _applyLocalFilters();
    notifyListeners();
  }

  void setCommodityFilter(String commodity) {
    _selectedCommodity = commodity;
    _applyLocalFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyLocalFilters();
    notifyListeners();
  }

  void _applyLocalFilters() {
    _filteredPrices = _prices.where((p) {
      if (_selectedState != 'All' && p.state != _selectedState) return false;
      if (_selectedCommodity != 'All' && p.commodity != _selectedCommodity) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final haystack = '${p.market} ${p.commodity} ${p.district} ${p.state}'
            .toLowerCase();
        if (!haystack.contains(_searchQuery)) return false;
      }
      return true;
    }).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _cleanString(String s) {
    // API sometimes returns all caps or extra spaces
    return s
        .trim()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  void _useFallbackData() {
    // Generate fallback data from common Indian mandis for demo
    _prices = _fallbackPrices;
    _availableStates = [
      'All',
      'Madhya Pradesh',
      'Maharashtra',
      'Rajasthan',
      'Uttar Pradesh',
    ];
    _availableCommodities = [
      'All',
      'Maize',
      'Onion',
      'Potato',
      'Soybean',
      'Tomato',
      'Wheat',
    ];
    _lastUpdated = DateTime.now();
    _errorMessage = 'Using offline data. Check internet connection.';
    _applyLocalFilters();
  }

  // ── Fallback dummy prices ─────────────────────────────────────────────────
  static final List<LiveMandiPrice> _fallbackPrices = [
    LiveMandiPrice(
      state: 'Maharashtra',
      district: 'Nagpur',
      market: 'Nagpur',
      commodity: 'Tomato',
      variety: 'Local',
      grade: 'FAQ',
      minPrice: 2200,
      maxPrice: 3200,
      modalPrice: 2850,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Maharashtra',
      district: 'Nashik',
      market: 'Lasalgaon',
      commodity: 'Onion',
      variety: 'Red',
      grade: 'FAQ',
      minPrice: 1500,
      maxPrice: 2400,
      modalPrice: 1920,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Madhya Pradesh',
      district: 'Indore',
      market: 'Indore',
      commodity: 'Soybean',
      variety: 'Yellow',
      grade: 'FAQ',
      minPrice: 3800,
      maxPrice: 4800,
      modalPrice: 4320,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Rajasthan',
      district: 'Jaipur',
      market: 'Jaipur',
      commodity: 'Wheat',
      variety: 'Lokwan',
      grade: 'FAQ',
      minPrice: 1900,
      maxPrice: 2400,
      modalPrice: 2180,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Maharashtra',
      district: 'Pune',
      market: 'Pune',
      commodity: 'Potato',
      variety: 'Jyoti',
      grade: 'FAQ',
      minPrice: 1100,
      maxPrice: 1800,
      modalPrice: 1450,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Madhya Pradesh',
      district: 'Bhopal',
      market: 'Bhopal',
      commodity: 'Maize',
      variety: 'Yellow',
      grade: 'FAQ',
      minPrice: 1500,
      maxPrice: 2200,
      modalPrice: 1870,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Uttar Pradesh',
      district: 'Lucknow',
      market: 'Lucknow',
      commodity: 'Tomato',
      variety: 'Hybrid',
      grade: 'FAQ',
      minPrice: 2000,
      maxPrice: 3000,
      modalPrice: 2600,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Maharashtra',
      district: 'Pune',
      market: 'Pune',
      commodity: 'Onion',
      variety: 'White',
      grade: 'FAQ',
      minPrice: 1800,
      maxPrice: 2600,
      modalPrice: 2100,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Rajasthan',
      district: 'Jodhpur',
      market: 'Jodhpur',
      commodity: 'Wheat',
      variety: 'Sharbati',
      grade: 'FAQ',
      minPrice: 2100,
      maxPrice: 2600,
      modalPrice: 2350,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Uttar Pradesh',
      district: 'Agra',
      market: 'Agra',
      commodity: 'Potato',
      variety: 'Kufri Jyoti',
      grade: 'FAQ',
      minPrice: 900,
      maxPrice: 1500,
      modalPrice: 1200,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Maharashtra',
      district: 'Nagpur',
      market: 'Nagpur',
      commodity: 'Soybean',
      variety: 'JS-335',
      grade: 'FAQ',
      minPrice: 4000,
      maxPrice: 4600,
      modalPrice: 4250,
      arrivalDate: '26/02/2026',
    ),
    LiveMandiPrice(
      state: 'Madhya Pradesh',
      district: 'Indore',
      market: 'Indore',
      commodity: 'Wheat',
      variety: 'Sehore',
      grade: 'FAQ',
      minPrice: 2000,
      maxPrice: 2500,
      modalPrice: 2280,
      arrivalDate: '26/02/2026',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // AI FEATURES (Gemini-powered, from multilingual_mandi)
  // ═══════════════════════════════════════════════════════════════════════════

  void setChatLanguage(String lang) {
    _chatLanguage = lang;
    notifyListeners();
  }

  /// Send a message to AI market chat
  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    _chatMessages.add(ChatMessage(text: message, isUser: true));
    _isChatLoading = true;
    notifyListeners();

    try {
      final reply = await MandiAIService.chat(
        message: message,
        language: _chatLanguage,
      );
      _chatMessages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _chatMessages.add(
        ChatMessage(
          text: 'Sorry, couldn\'t get a response. Please try again.',
          isUser: false,
        ),
      );
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  /// Get negotiation advice for a commodity
  Future<void> fetchNegotiationAdvice({
    required String item,
    required String vendorPrice,
    String? marketPrice,
  }) async {
    _isNegotiationLoading = true;
    _negotiationAdvice = null;
    notifyListeners();

    try {
      _negotiationAdvice = await MandiAIService.getNegotiationAdvice(
        item: item,
        vendorPrice: vendorPrice,
        marketPrice: marketPrice ?? 'standard',
        language: _chatLanguage,
      );
    } catch (e) {
      _negotiationAdvice = 'Could not get advice. Try again.';
    } finally {
      _isNegotiationLoading = false;
      notifyListeners();
    }
  }

  /// Get AI price insight for a commodity
  Future<void> fetchPriceInsight({
    required String item,
    String location = 'India',
  }) async {
    _isPriceInsightLoading = true;
    _priceInsight = null;
    notifyListeners();

    try {
      _priceInsight = await MandiAIService.getPriceInsight(
        item: item,
        location: location,
      );
    } catch (e) {
      _priceInsight = 'Price insight unavailable right now.';
    } finally {
      _isPriceInsightLoading = false;
      notifyListeners();
    }
  }

  /// Get smart bargaining phrases
  Future<void> fetchSmartPhrases({
    required String item,
    String context = 'general negotiation',
  }) async {
    _isPhrasesLoading = true;
    _smartPhrases = [];
    notifyListeners();

    try {
      _smartPhrases = await MandiAIService.getSmartPhrases(
        item: item,
        context: context,
        language: _chatLanguage,
      );
    } catch (e) {
      _smartPhrases = ['Could not generate phrases.'];
    } finally {
      _isPhrasesLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatMessages.clear();
    notifyListeners();
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

// ── Live Mandi Price Model ─────────────────────────────────────────────────
class LiveMandiPrice {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final String grade;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String arrivalDate;

  const LiveMandiPrice({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.grade,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.arrivalDate,
  });

  /// Get emoji for a commodity
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
    if (lower.contains('sugar') || lower.contains('gur')) return '🍬';
    if (lower.contains('chilli') || lower.contains('mirch')) return '🌶️';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('apple')) return '🍎';
    if (lower.contains('mango')) return '🥭';
    if (lower.contains('garlic')) return '🧄';
    if (lower.contains('brinjal') || lower.contains('eggplant')) return '🍆';
    if (lower.contains('cabbage')) return '🥬';
    if (lower.contains('carrot')) return '🥕';
    if (lower.contains('pea')) return '🫛';
    if (lower.contains('lemon') || lower.contains('lime')) return '🍋';
    if (lower.contains('coconut')) return '🥥';
    if (lower.contains('groundnut') || lower.contains('peanut')) return '🥜';
    return '🌿';
  }

  /// Price spread
  double get priceSpread => maxPrice - minPrice;

  /// Is this a good price? (modal close to max)
  bool get isGoodPrice => (modalPrice - minPrice) > (maxPrice - modalPrice);
}
