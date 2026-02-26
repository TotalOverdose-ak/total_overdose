import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AI Service for Mandi features using Google Gemini API.
///
/// Uses Gemini REST API (`generativelanguage.googleapis.com`) which supports
/// browser CORS. Features: Translation, Smart Negotiation, Price insights, AI Chat.
class MandiAIService {
  // ── Gemini Configuration ─────────────────────────────────────────────────
  static const String _apiKey = 'AIzaSyBgN4ijOo--Tquajvv1_D8A8ifi6U8Tw_4';
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

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

  // ── Core Gemini Call (with retry) ────────────────────────────────────────
  static Future<String> _generate(
    String prompt, {
    int retries = 2,
    String? systemPrompt,
  }) async {
    final fullPrompt = systemPrompt != null
        ? '$systemPrompt\n\n$prompt'
        : prompt;
    return _callGemini(fullPrompt, retries: retries);
  }

  /// Makes the actual Gemini REST API call with retry logic.
  static Future<String> _callGemini(String prompt, {int retries = 2}) async {
    Exception? lastError;

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
          debugPrint('MandiAIService: Retry attempt $attempt');
        }

        final url = '$_baseUrl?key=$_apiKey';

        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                    ],
                  },
                ],
                'generationConfig': {
                  'temperature': 0.7,
                  'maxOutputTokens': 512,
                },
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode != 200) {
          debugPrint('Gemini error: ${response.statusCode} ${response.body}');
          throw Exception(
            'Gemini API error ${response.statusCode}: ${response.body}',
          );
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('No response from Gemini');
        }

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          throw Exception('Empty response from Gemini');
        }

        final text = parts[0]['text'] as String? ?? '';
        if (text.trim().isEmpty) {
          throw Exception('Empty text from Gemini');
        }
        return text.trim();
      } catch (e) {
        debugPrint('MandiAIService._callGemini error (attempt $attempt): $e');
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }

    throw lastError ?? Exception('Failed after $retries retries');
  }

  /// Multi-turn Gemini call: accepts a list of role/content pairs.
  static Future<String> _callGeminiMultiTurn(
    List<Map<String, String>> messages, {
    int retries = 2,
  }) async {
    // Build Gemini contents array from messages
    // Gemini uses 'user' and 'model' roles (not 'assistant')
    final contents = <Map<String, dynamic>>[];
    String systemText = '';

    for (final msg in messages) {
      final role = msg['role'] ?? 'user';
      final text = msg['content'] ?? '';
      if (role == 'system') {
        systemText += '$text\n';
        continue;
      }
      final geminiRole = (role == 'assistant') ? 'model' : 'user';
      contents.add({
        'role': geminiRole,
        'parts': [
          {
            'text': role == 'user' && systemText.isNotEmpty && contents.isEmpty
                ? '$systemText\n$text'
                : text,
          },
        ],
      });
    }

    // If only system message and no user message, send as single prompt
    if (contents.isEmpty && systemText.isNotEmpty) {
      return _callGemini(systemText, retries: retries);
    }

    // Ensure first message is from 'user' (Gemini requirement)
    if (contents.isNotEmpty && contents[0]['role'] != 'user') {
      contents.insert(0, {
        'role': 'user',
        'parts': [
          {'text': systemText.isNotEmpty ? systemText : 'Hello'},
        ],
      });
    }

    Exception? lastError;
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }

        final url = '$_baseUrl?key=$_apiKey';
        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': contents,
                'generationConfig': {
                  'temperature': 0.7,
                  'maxOutputTokens': 512,
                },
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode != 200) {
          throw Exception(
            'Gemini API error ${response.statusCode}: ${response.body}',
          );
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('No response from Gemini');
        }

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        final text = parts?[0]['text'] as String? ?? '';
        if (text.trim().isEmpty) throw Exception('Empty response');
        return text.trim();
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }
    throw lastError ?? Exception('Failed after $retries retries');
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

      final result = await _callGeminiMultiTurn(messages, retries: 2);
      return result;
    } catch (e) {
      debugPrint('MandiAIService.chat error: $e');
      return _chatErrorFallback(language, e.toString());
    }
  }

  /// Provides a meaningful error fallback for chat failures.
  static String _chatErrorFallback(String language, String error) {
    debugPrint('MandiAIService chat error details: $error');

    if (error.contains('400')) {
      return 'Invalid request. Please rephrase and try again.';
    }
    if (error.contains('401') ||
        error.contains('403') ||
        error.contains('API_KEY')) {
      return 'API key issue detected. Please check the Gemini API key.';
    }
    if (error.contains('429') ||
        error.contains('rate') ||
        error.contains('RESOURCE_EXHAUSTED')) {
      return 'Too many requests! Please wait a moment and try again.';
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
