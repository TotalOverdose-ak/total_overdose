import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

/// AI Service with dual fallback: Gemini direct + Flask/OpenRouter proxy.
class MandiAIService {
  // ── Configuration ─────────────────────────────────────────────────────
  static String get _geminiKey => AppConfig.geminiApiKey;
  static String get _geminiChatKey => AppConfig.geminiChatApiKey;
  static String get _geminiUrl => AppConfig.geminiBaseUrl;
  static String get _geminiModel => AppConfig.geminiModel;
  static String get _proxyUrl => AppConfig.proxyBaseUrl;

  /// System instruction for the AI assistant.
  static const String _systemInstruction =
      'You are a helpful AI assistant for Indian market vendors and buyers at local mandis. '
      'You help with market prices, negotiation tips, quality assessment, storage tips, '
      'best time to buy/sell, market locations and timings. '
      'Be friendly and conversational, like a knowledgeable friend who works in the market. '
      'Keep responses practical and under 100 words. No markdown formatting.';

  /// Supported Indian languages
  static const Map<String, String> supportedLanguages = {
    'Hinglish': 'हिंग्लिश',
    'Hindi': 'हिंदी',
    'Tamil': 'தமிழ்',
    'Telugu': 'తెలుగు',
    'Bengali': 'বাংলা',
    'Marathi': 'मराठी',
    'Kannada': 'ಕನ್ನಡ',
    'Gujarati': 'ગુજરાતી',
    'Punjabi': 'ਪੰਜਾਬੀ',
    'English': 'English',
  };

  // ── Core AI Call (Dual Fallback) ──────────────────────────────────────
  static Future<String> _generate(
    String prompt, {
    int retries = 2,
    String? systemPrompt,
  }) async {
    final messages = <Map<String, String>>[];
    if (systemPrompt != null) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    messages.add({'role': 'user', 'content': prompt});
    return _callAI(messages, retries: retries);
  }

  /// Dual fallback: Gemini first, Flask proxy on rate limit.
  /// [apiKey] allows overriding the default key (e.g. dedicated chat key).
  static Future<String> _callAI(
    List<Map<String, String>> messages, {
    int retries = 3,
    String? apiKey,
  }) async {
    final key = apiKey ?? _geminiKey;
    // Try Gemini direct
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(seconds: 3 * attempt));
          debugPrint('MandiAIService: Gemini retry $attempt');
        }
        return await _callGeminiDirect(messages, apiKey: key);
      } catch (e) {
        final isRateLimit =
            e.toString().contains('429') ||
            e.toString().contains('RESOURCE_EXHAUSTED');
        debugPrint('Gemini attempt $attempt failed: $e');
        if (isRateLimit) {
          debugPrint('Rate limited -> trying Flask proxy...');
          break;
        }
      }
    }
    // Fallback to Flask proxy
    try {
      return await _callFlaskProxy(messages);
    } catch (proxyError) {
      debugPrint('Flask proxy failed: $proxyError');
    }
    // Last resort: wait then retry Gemini
    await Future.delayed(const Duration(seconds: 8));
    try {
      return await _callGeminiDirect(messages, apiKey: key);
    } catch (_) {}
    throw Exception('AI unavailable. Please wait 30 seconds and try again.');
  }

  /// Call Gemini directly (OpenAI-compatible endpoint).
  static Future<String> _callGeminiDirect(
    List<Map<String, String>> messages, {
    String? apiKey,
  }) async {
    final key = apiKey ?? _geminiKey;
    final response = await http
        .post(
          Uri.parse(_geminiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',
          },
          body: jsonEncode({
            'model': _geminiModel,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 512,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 429 ||
        (response.statusCode == 403 &&
            response.body.contains('RESOURCE_EXHAUSTED'))) {
      throw Exception('429: Gemini rate limited');
    }
    if (response.statusCode != 200) {
      throw Exception('Gemini ${response.statusCode}: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) throw Exception('No AI response');
    final msg = choices[0]['message'] as Map<String, dynamic>?;
    final text = msg?['content'] as String? ?? '';
    if (text.trim().isEmpty) throw Exception('Empty AI response');
    return text.trim();
  }

  /// Call Flask proxy backend (routes to OpenRouter).
  static Future<String> _callFlaskProxy(
    List<Map<String, String>> messages,
  ) async {
    final response = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 512,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Proxy ${response.statusCode}: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] == true) {
      final text = json['content'] as String? ?? '';
      if (text.trim().isEmpty) throw Exception('Empty proxy response');
      return text.trim();
    }
    throw Exception(json['error'] ?? 'Proxy error');
  }

  /// Call Gemini using native REST API (for standard Google API keys like AIzaSy...).
  /// This uses the generateContent endpoint with ?key= param.
  static Future<String> _callGeminiNative(
    List<Map<String, String>> messages, {
    required String apiKey,
  }) async {
    // Convert OpenAI-style messages to Gemini native format
    final contents = <Map<String, dynamic>>[];
    String? systemInstruction;

    for (final msg in messages) {
      final role = msg['role'] ?? 'user';
      final content = msg['content'] ?? '';
      if (role == 'system') {
        systemInstruction = content;
        continue;
      }
      contents.add({
        'role': role == 'assistant' ? 'model' : 'user',
        'parts': [
          {'text': content},
        ],
      });
    }

    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512},
    };

    if (systemInstruction != null) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction},
        ],
      };
    }

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$apiKey';

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 429 ||
        (response.statusCode == 403 &&
            response.body.contains('RESOURCE_EXHAUSTED'))) {
      throw Exception('429: Gemini rate limited');
    }
    if (response.statusCode != 200) {
      throw Exception('Gemini Native ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No AI response');
    }
    final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
    final text = parts?.firstOrNull?['text'] as String? ?? '';
    if (text.trim().isEmpty) throw Exception('Empty AI response');
    return text.trim();
  }

  // ── Translation ──────────────────────────────────────────────────────────
  /// Translates text to the target Indian language.
  static Future<String> translate({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    if (text.trim().isEmpty) return '';

    final native = supportedLanguages[targetLang] ?? targetLang;

    final prompt =
        '''You are an expert translator specializing in Indian regional languages for market/trade contexts.

Translate the following text accurately to $targetLang ($native).

CRITICAL RULES:
1. Output ONLY the translated text - no explanations, no quotes, no prefixes
2. Preserve the original meaning, tone, and intent precisely
3. Use natural, conversational language as spoken by native speakers in markets
4. Keep numbers as numerals (don't spell them out)
5. For market/trade terms, use commonly understood local vocabulary
6. If the text contains greetings, translate culturally
7. Maintain any pricing format (₹50/kg stays as ₹50/kg)

Text to translate:
$text''';

    try {
      final result = await _generate(prompt);
      // Clean up — strip surrounding quotes
      var cleaned = result.replaceAll(RegExp(r'^["\x27]+|["\x27]+$'), '');
      if (cleaned.toLowerCase().startsWith('translation:')) {
        cleaned = cleaned.substring(12).trim();
      }
      return cleaned;
    } catch (e) {
      return '[Translation failed] $text';
    }
  }

  // ── Smart Negotiation Advice (DATA-DRIVEN) ────────────────────────────────
  /// Gets AI bargaining tips using REAL mandi price data for comparison.
  ///
  /// [mandiPriceData] contains actual min/max/modal prices from data.gov.in
  /// so the AI can calculate exact markup % and fair price ranges.
  static Future<String> getNegotiationAdvice({
    required String item,
    required String vendorPrice,
    String marketPrice = 'standard',
    String language = 'Hinglish',
    MandiPriceContext? mandiPriceData,
  }) async {
    String langInstruction = _buildLangInstruction(language);

    // ── Build data-driven context ──────────────────────────────────────
    String priceAnalysis = '';
    if (mandiPriceData != null) {
      final markup = mandiPriceData.markupPercent;
      final fairRange =
          '₹${mandiPriceData.minPrice.toStringAsFixed(0)}-₹${mandiPriceData.maxPrice.toStringAsFixed(0)}/quintal';
      final modalStr =
          '₹${mandiPriceData.modalPrice.toStringAsFixed(0)}/quintal';
      final suggestedTarget = mandiPriceData.suggestedBargainPrice;

      priceAnalysis =
          '''
REAL MANDI DATA (data.gov.in):
- Market: ${mandiPriceData.market}, ${mandiPriceData.district}
- Min Price: ₹${mandiPriceData.minPrice.toStringAsFixed(0)}/quintal
- Max Price: ₹${mandiPriceData.maxPrice.toStringAsFixed(0)}/quintal
- Modal Price (most common): $modalStr
- Market Range: $fairRange
- Vendor's Markup: ${markup > 0 ? '+${markup.toStringAsFixed(1)}% above modal' : '${markup.toStringAsFixed(1)}% below modal'}
- SUGGESTED BARGAIN TARGET: ₹${suggestedTarget.toStringAsFixed(0)}/quintal

ANALYSIS:
${_getVerdictFromMarkup(markup)}''';
    } else {
      priceAnalysis =
          'No real mandi data available. Use general market knowledge for Feb 2026.';
    }

    final prompt =
        '''You are a DATA-DRIVEN market negotiation expert for Indian mandis.

SCENARIO:
- Item: $item
- Vendor's asking price: $vendorPrice
$priceAnalysis

$langInstruction

RULES — YOU MUST FOLLOW:
1. ALWAYS reference the EXACT mandi data numbers (min, max, modal price). Show the numbers!
2. Calculate the EXACT difference between vendor price and modal/fair price
3. Give a SPECIFIC counter-offer amount (not vague "10-15 rupees kam")
4. Explain WHY that counter-offer is fair (backed by data)
5. Give one ready-to-use negotiation dialogue

FORMAT (keep under 100 words):
Line 1: VERDICT — [Fair/Slightly High/Overpriced] + exact markup %
Line 2: DATA — "Mandi modal price is ₹X, vendor is charging ₹Y (Z% more)"
Line 3: COUNTER-OFFER — "Offer ₹[specific amount] because [reason]"
Line 4: DIALOGUE — A natural phrase the buyer can say using the data

NO markdown. NO bullets. NO asterisks. Write as flowing text.''';

    try {
      return await _generate(prompt);
    } catch (e) {
      // Smart fallback using real data if available
      if (mandiPriceData != null) {
        final target = mandiPriceData.suggestedBargainPrice.toStringAsFixed(0);
        final modal = mandiPriceData.modalPrice.toStringAsFixed(0);
        if (language == 'Hindi') {
          return 'मंडी का मोडल भाव ₹$modal/क्विंटल है। ₹$target/क्विंटल का ऑफर दें — यह बाज़ार भाव के हिसाब से सही है।';
        }
        return 'Bhaiya, mandi ka modal rate ₹$modal/quintal hai. ₹$target/quintal pe de do — ye market rate ke hisaab se fair hai!';
      }
      if (language == 'Hindi') {
        return 'माफ़ कीजिए, अभी सलाह नहीं मिल पाई। कृपया दोबारा कोशिश करें।';
      }
      return 'Sorry, could not get advice right now. Please try again.';
    }
  }

  /// Get verdict text from markup percentage
  static String _getVerdictFromMarkup(double markup) {
    if (markup <= 5)
      return 'FAIR PRICE — Close to market rate. Minor bargain possible.';
    if (markup <= 15)
      return 'SLIGHTLY HIGH — 5-15% above market. Bargain down to modal.';
    if (markup <= 30)
      return 'OVERPRICED — Significant markup. Push hard toward modal price.';
    return 'VERY OVERPRICED — $markup% above market! Walk away or demand modal rate.';
  }

  /// Build language instruction string
  static String _buildLangInstruction(String language) {
    switch (language) {
      case 'Hinglish':
        return 'Respond in Hinglish (natural mix of Hindi and English, Roman script). Use words like "bhaiya", "dekho", "mandi ka rate" naturally.';
      case 'Hindi':
        return 'Respond ENTIRELY in Hindi using Devanagari script (हिंदी).';
      case 'Tamil':
        return 'Respond ENTIRELY in Tamil using Tamil script (தமிழ்). Use respectful "அண்ணா" (anna).';
      case 'Telugu':
        return 'Respond ENTIRELY in Telugu using Telugu script (తెలుగు). Use respectful "అన్నా" (anna).';
      case 'Marathi':
        return 'Respond ENTIRELY in Marathi using Devanagari script (मराठी). Use "भाऊ" or "दादा".';
      case 'Bengali':
        return 'Respond ENTIRELY in Bengali using Bengali script (বাংলা). Use "দাদা" (dada).';
      default:
        return 'Respond in simple, friendly English suitable for Indian markets.';
    }
  }

  // ── Price Insight ────────────────────────────────────────────────────────
  /// AI-powered price analysis for a commodity.
  static Future<String> getPriceInsight({
    required String item,
    String location = 'India',
  }) async {
    final prompt =
        '''You are a market analyst expert for Indian agricultural markets and mandis.

For the item "$item" in $location markets (February 2026 season):

1. What's the typical retail price range per kg?
2. Is it currently in season or off-season?
3. One insider buying tip for getting the best deal

Keep response under 60 words, conversational tone.
No markdown formatting.
If you're unsure about exact prices, give a reasonable estimate based on typical Indian market prices.''';

    try {
      return await _generate(prompt);
    } catch (e) {
      return 'Price info temporarily unavailable. Tip: Buy seasonal produce in the morning for freshest quality at best prices!';
    }
  }

  // ── AI Market Chat (with conversation history) ───────────────────────────
  /// Conversational assistant for market queries.
  /// Accepts optional [history] to maintain conversation context.
  static Future<String> chat({
    required String message,
    String language = 'Hinglish',
    List<ChatHistoryItem> history = const [],
  }) async {
    String langInstruction;
    if (language == 'Hinglish') {
      langInstruction =
          'Respond in Hinglish (natural mix of Hindi and English in Roman script).';
    } else if (supportedLanguages.containsKey(language) &&
        language != 'English') {
      final native = supportedLanguages[language];
      langInstruction = 'Respond in $language using $native script.';
    } else {
      langInstruction = 'Respond in simple, friendly English.';
    }

    try {
      // Build Gemini messages array with conversation history
      final messages = <Map<String, String>>[
        {
          'role': 'system',
          'content': '$_systemInstruction\n\n$langInstruction',
        },
      ];

      // Add past messages as context (limit to last 10 for token efficiency)
      final recentHistory = history.length > 10
          ? history.sublist(history.length - 10)
          : history;
      for (final item in recentHistory) {
        messages.add({
          'role': item.isUser ? 'user' : 'assistant',
          'content': item.text,
        });
      }

      // Add current user message
      messages.add({'role': 'user', 'content': message});

      debugPrint(
        'MandiAIService.chat: Sending ${messages.length} messages to Gemini',
      );

      String firstError = '';

      // ── Attempt 1: Native Gemini API with chat key ──────────────────
      try {
        debugPrint('Chat: trying native Gemini API with chat key...');
        final result = await _callGeminiNative(
          messages,
          apiKey: _geminiChatKey,
        );
        return result;
      } catch (e) {
        firstError = e.toString();
        debugPrint('Chat native Gemini failed: $e');
      }

      // ── Attempt 2: OpenAI-compatible endpoint with chat key ─────────
      try {
        debugPrint('Chat: trying OpenAI endpoint with chat key...');
        final result = await _callGeminiDirect(
          messages,
          apiKey: _geminiChatKey,
        );
        return result;
      } catch (e) {
        debugPrint('Chat OpenAI endpoint failed: $e');
      }

      // ── Attempt 3: Flask proxy ──────────────────────────────────────
      try {
        debugPrint('Chat: trying Flask proxy...');
        return await _callFlaskProxy(messages);
      } catch (e) {
        debugPrint('Chat Flask proxy failed: $e');
      }

      // All failed — throw the FIRST error so user sees real issue
      throw Exception(firstError);
    } catch (e) {
      debugPrint('MandiAIService.chat error: $e');
      return _chatErrorFallback(language, e.toString());
    }
  }

  /// Provides a meaningful error fallback for chat failures.
  static String _chatErrorFallback(String language, String error) {
    debugPrint('MandiAIService chat error details: $error');

    // ⚠️ Check RESOURCE_EXHAUSTED / rate-limit FIRST (before 403)
    // because Gemini returns 403 + RESOURCE_EXHAUSTED for quota issues
    if (error.contains('429') ||
        error.contains('RESOURCE_EXHAUSTED') ||
        error.contains('rate') ||
        error.contains('quota')) {
      if (language == 'Hindi') {
        return 'बहुत ज़्यादा रिक्वेस्ट हो गई हैं। कृपया 30 सेकंड रुकें और फिर से कोशिश करें।';
      }
      return 'Rate limit hit! Please wait 30 seconds and try again. (Free tier limit: 15 requests/min)';
    }
    if (error.contains('400')) {
      return 'Invalid request. Please rephrase and try again.';
    }
    if (error.contains('401') ||
        error.contains('403') ||
        error.contains('API_KEY')) {
      return 'API key issue detected. Please check the Gemini API key.';
    }
    if (error.contains('timeout') || error.contains('TimeoutException')) {
      return 'Request timed out. Check your internet connection and try again.';
    }
    if (language == 'Hindi') {
      return 'माफ़ कीजिए, जवाब नहीं मिल पाया। कृपया दोबारा कोशिश करें।';
    }
    // Show actual error for debugging
    final shortError = error.length > 120 ? error.substring(0, 120) : error;
    return 'Sorry, couldn\'t respond. Error: $shortError';
  }

  // ── Smart Phrases ────────────────────────────────────────────────────────
  /// Culturally appropriate negotiation phrases.
  static Future<List<String>> getSmartPhrases({
    required String item,
    String context = 'general negotiation',
    String language = 'Hinglish',
  }) async {
    String langInstruction;
    if (language == 'Hinglish') {
      langInstruction =
          'Generate phrases in Hinglish (Hindi-English mix in Roman script).';
    } else if (supportedLanguages.containsKey(language) &&
        language != 'English') {
      final native = supportedLanguages[language];
      langInstruction = 'Generate phrases in $language using $native script.';
    } else {
      langInstruction =
          'Generate phrases in simple English with Indian cultural context.';
    }

    final prompt =
        '''Generate 3 natural, ready-to-use bargaining phrases for buying $item at an Indian mandi.

Context: $context
$langInstruction

Format: Just list the 3 phrases, one per line.
Make them sound natural - like what a local would actually say.
Include the warm, respectful tone typical of Indian market interactions.
No numbering, no explanations, just the phrases.''';

    try {
      final result = await _generate(prompt);
      return result
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .take(3)
          .toList();
    } catch (e) {
      return [
        'Bhaiya, aaj rate kya hai? Thoda fresh wala dikhao na.',
        'Itna mehnga? Saamne wale se 5 rupaye kam mein mil raha hai!',
        'Accha chal, 2 kg le leta hoon, thoda discount dedo?',
      ];
    }
  }
}

/// Model for passing chat history to the AI service.
class ChatHistoryItem {
  final String text;
  final bool isUser;

  const ChatHistoryItem({required this.text, required this.isUser});
}

/// Real mandi price context for data-driven bargaining.
/// Prices are in ₹/quintal from data.gov.in.
class MandiPriceContext {
  final String market;
  final String district;
  final String commodity;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final double vendorPriceNumeric; // parsed vendor price in ₹/quintal

  const MandiPriceContext({
    required this.market,
    required this.district,
    required this.commodity,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.vendorPriceNumeric,
  });

  /// How much % above/below modal the vendor is charging
  double get markupPercent => modalPrice > 0
      ? ((vendorPriceNumeric - modalPrice) / modalPrice) * 100
      : 0;

  /// Smart suggested bargain target:
  /// - If vendor > max: target = modal + 5%
  /// - If vendor > modal: target = modal
  /// - If vendor <= modal: it's fair, target = vendor price
  double get suggestedBargainPrice {
    if (vendorPriceNumeric > maxPrice) {
      return modalPrice * 1.05; // slightly above modal
    } else if (vendorPriceNumeric > modalPrice) {
      return modalPrice; // push to modal
    }
    return vendorPriceNumeric; // already fair
  }

  /// Price verdict
  String get verdict {
    final markup = markupPercent;
    if (markup <= 5) return 'FAIR';
    if (markup <= 15) return 'SLIGHTLY HIGH';
    if (markup <= 30) return 'OVERPRICED';
    return 'VERY OVERPRICED';
  }
}
