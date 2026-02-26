import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AI Service for Mandi features using Google Gemini API.
///
/// Ported from multilingual_mandi Python backend to direct Flutter calls.
/// Features: Translation, Negotiation tips, Price insights, AI Chat.
class MandiAIService {
  // ── Gemini Configuration ─────────────────────────────────────────────────
  static const String _apiKey = 'AIzaSyCRPu7QSFgUnBeu2SkmDzhvunJjYJ4sEQk';
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

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

  // ── Core Gemini Call ─────────────────────────────────────────────────────
  static Future<String> _generate(String prompt) async {
    try {
      final uri = Uri.parse('$_baseUrl?key=$_apiKey');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512},
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        debugPrint('Gemini API error: ${response.statusCode} ${response.body}');
        throw Exception('Gemini API error ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response from Gemini');
      }
      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      return (parts[0]['text'] as String).trim();
    } catch (e) {
      debugPrint('MandiAIService._generate error: $e');
      rethrow;
    }
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

  // ── Negotiation Advice ───────────────────────────────────────────────────
  /// Gets AI bargaining tips for a commodity.
  static Future<String> getNegotiationAdvice({
    required String item,
    required String vendorPrice,
    String marketPrice = 'standard',
    String language = 'Hinglish',
  }) async {
    String langInstruction;
    switch (language) {
      case 'Hinglish':
        langInstruction =
            'Respond in Hinglish (natural mix of Hindi and English, Roman script). Use words like "bhaiya", "accha", "thoda" naturally.';
        break;
      case 'Hindi':
        langInstruction =
            'Respond ENTIRELY in Hindi using Devanagari script (हिंदी).';
        break;
      case 'Tamil':
        langInstruction =
            'Respond ENTIRELY in Tamil using Tamil script (தமிழ்). Use respectful "அண்ணா" (anna).';
        break;
      case 'Telugu':
        langInstruction =
            'Respond ENTIRELY in Telugu using Telugu script (తెలుగు). Use respectful "అన్నా" (anna).';
        break;
      case 'Marathi':
        langInstruction =
            'Respond ENTIRELY in Marathi using Devanagari script (मराठी). Use "भाऊ" or "दादा".';
        break;
      case 'Bengali':
        langInstruction =
            'Respond ENTIRELY in Bengali using Bengali script (বাংলা). Use "দাদা" (dada).';
        break;
      default:
        langInstruction =
            'Respond in simple, friendly English suitable for Indian markets.';
    }

    final prompt =
        '''You are a friendly, street-smart market expert helping with price negotiations at an Indian mandi.

SCENARIO:
- Item: $item
- Vendor's asking price: $vendorPrice
- Market reference: ${marketPrice != 'standard' ? marketPrice : "Use your knowledge of typical Feb 2026 Indian market prices"}

$langInstruction

Provide PRACTICAL negotiation advice:
1. Quick verdict: Is this price fair, slightly high, or overpriced? (1 line)
2. A ready-to-use negotiation phrase the buyer can say directly to the vendor (make it natural!)
3. One smart tip (bulk discount, quality check, timing, etc.)

STYLE:
- Keep it under 80 words total
- Be warm and friendly, like advice from a helpful neighbor
- NO markdown, NO bullet points, NO asterisks
- Write as flowing text, like someone speaking
- Respectful bargaining is an art form in Indian markets! 🙏''';

    try {
      return await _generate(prompt);
    } catch (e) {
      if (language == 'Hindi') {
        return 'भाई साहब, थोड़ा कम कर दीजिए। बाज़ार में देखकर आया हूँ, ₹10-15 कम में मिल रहा है। रोज़ का ग्राहक बनूँगा! 🙏';
      }
      return 'Bhaiya, thoda kam kar do na. Market mein dekh ke aaya hoon, ₹10-15 kam mein mil raha hai. Regular customer ban jayenge! 🙏';
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

  // ── AI Market Chat ───────────────────────────────────────────────────────
  /// Conversational assistant for market queries.
  static Future<String> chat({
    required String message,
    String language = 'Hinglish',
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

    final prompt =
        '''You are a helpful AI assistant for Indian market vendors and buyers at local mandis.

$langInstruction

You can help with:
- Market prices and trends
- Negotiation tips
- Quality assessment of produce
- Storage and handling tips
- Best time to buy/sell
- Market locations and timings
- Any other market-related questions

User's question: $message

Provide a helpful, practical response. Keep it under 100 words.
Be friendly and conversational, like a knowledgeable friend who works in the market.
No markdown formatting.''';

    try {
      return await _generate(prompt);
    } catch (e) {
      return 'Sorry, I couldn\'t process that. Please try asking again!';
    }
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
