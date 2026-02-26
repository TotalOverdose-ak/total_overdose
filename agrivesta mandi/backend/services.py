"""
AI Services for Multilingual Mandi.
Handles translation, negotiation, and AI chat using Google Gemini.

Features:
- Real-time translation between Indian regional languages
- Smart negotiation advice in multiple languages
- AI-powered vendor assistant chat
- Language detection
- Graceful error handling with fallbacks

Updated to use google-genai SDK with gemini-3-flash-preview (2026)
"""
import os
import asyncio
from google import genai
from dotenv import load_dotenv

load_dotenv()

# Initialize the Gemini client
# WHY: Using the new google-genai SDK as recommended by Google
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

# Model to use - gemini-3-flash-preview for best performance (per Google docs 2026)
MODEL_NAME = "gemini-3-flash-preview"

# Supported languages with their native scripts
SUPPORTED_LANGUAGES = {
    "Hindi": "हिंदी",
    "Tamil": "தமிழ்",
    "Telugu": "తెలుగు",
    "Bengali": "বাংলা",
    "Marathi": "मराठी",
    "Kannada": "ಕನ್ನಡ",
    "Gujarati": "ગુજરાતી",
    "Punjabi": "ਪੰਜਾਬੀ",
    "English": "English"
}


def _sync_generate(prompt: str) -> str:
    """
    Synchronous wrapper for Gemini API call.
    WHY: The google-genai SDK is synchronous, we wrap it for async endpoints.
    """
    try:
        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt
        )
        return response.text.strip()
    except Exception as e:
        print(f"Gemini API error: {e}")
        raise


async def translate_text(text: str, target_lang: str) -> str:
    """
    Translates input text to the target Indian regional language.
    
    WHY: Breaking language barriers for local vendors who speak 
    different regional languages but need to communicate for trade.
    
    Args:
        text: The text to translate
        target_lang: Target language name (e.g., "Hindi", "Tamil")
    
    Returns:
        Translated text in the target language
    """
    # Validate target language
    if target_lang not in SUPPORTED_LANGUAGES:
        return f"[Unsupported language: {target_lang}]"
    
    native_name = SUPPORTED_LANGUAGES[target_lang]
    
    prompt = f"""You are an expert translator specializing in Indian regional languages for market/trade contexts.

Translate the following text accurately to {target_lang} ({native_name}).

CRITICAL RULES:
1. Output ONLY the translated text - no explanations, no quotes, no prefixes
2. Preserve the original meaning, tone, and intent precisely
3. Use natural, conversational language as spoken by native speakers in markets
4. Keep numbers as numerals (don't spell them out)
5. For market/trade terms, use commonly understood local vocabulary
6. If the text contains greetings, translate culturally (e.g., "Hello" → "नमस्ते" in Hindi)
7. Maintain any pricing format (₹50/kg stays as ₹50/kg with translated unit if needed)

Text to translate:
{text}"""

    try:
        result = await asyncio.to_thread(_sync_generate, prompt)
        # Clean up any quotes or prefixes that might slip through
        result = result.strip('"\'')
        if result.lower().startswith("translation:"):
            result = result[12:].strip()
        return result
    except Exception as e:
        print(f"Translation error: {e}")
        # WHY: Graceful degradation - return original text with error marker
        return f"[Translation failed] {text}"


async def get_negotiation_advice(item: str, vendor_price: str, market_price: str, language: str = "Hinglish") -> str:
    """
    Provides fair price advice and negotiation strategies in the specified language.
    
    WHY: Helping both vendors and buyers reach a fair deal by providing
    market-aware suggestions in accessible format and their preferred language.
    
    Args:
        item: The produce/item being negotiated
        vendor_price: The price the vendor is asking
        market_price: Reference market price (or "standard" to use AI's knowledge)
        language: Language for the response
    
    Returns:
        Negotiation advice in the specified language with native script
    """
    lang_instruction = ""
    if language == "Hinglish":
        lang_instruction = """Respond in Hinglish (natural mix of Hindi and English, written in Roman script).
Use words like 'bhaiya', 'accha', 'thoda', 'aur', 'kya' naturally. Example: "Bhaiya, thoda kam karo na, 50 rupaye dedo!"
"""
    elif language == "Hindi":
        lang_instruction = """Respond ENTIRELY in Hindi using Devanagari script (हिंदी).
Example: "भाई साहब, थोड़ा कम कर दीजिए, ५० रुपये में दे दीजिए!"
"""
    elif language == "Tamil":
        lang_instruction = """Respond ENTIRELY in Tamil using Tamil script (தமிழ்).
Use respectful terms like 'அண்ணா' (anna) for vendor.
"""
    elif language == "Telugu":
        lang_instruction = """Respond ENTIRELY in Telugu using Telugu script (తెలుగు).
Use respectful terms like 'అన్నా' (anna) for vendor.
"""
    elif language == "Bengali":
        lang_instruction = """Respond ENTIRELY in Bengali using Bengali script (বাংলা).
Use respectful terms like 'দাদা' (dada) for vendor.
"""
    elif language == "Marathi":
        lang_instruction = """Respond ENTIRELY in Marathi using Devanagari script (मराठी).
Use respectful terms like 'भाऊ' (bhau) or 'दादा' (dada) for vendor.
"""
    elif language == "Kannada":
        lang_instruction = """Respond ENTIRELY in Kannada using Kannada script (ಕನ್ನಡ).
Use respectful terms like 'ಅಣ್ಣ' (anna) for vendor.
"""
    elif language == "Gujarati":
        lang_instruction = """Respond ENTIRELY in Gujarati using Gujarati script (ગુજરાતી).
Use respectful terms like 'ભાઈ' (bhai) for vendor.
"""
    elif language == "Punjabi":
        lang_instruction = """Respond ENTIRELY in Punjabi using Gurmukhi script (ਪੰਜਾਬੀ).
Use respectful terms like 'ਭਾਜੀ' (bhaji) or 'ਵੀਰੇ' (veere) for vendor.
"""
    else:
        lang_instruction = "Respond in simple, friendly English suitable for Indian markets."
    
    prompt = f"""You are a friendly, street-smart market expert helping with price negotiations at an Indian mandi (local vegetable/fruit market).

SCENARIO:
- Item: {item}
- Vendor's asking price: {vendor_price}
- Market reference: {market_price if market_price != "standard" else "Use your knowledge of typical January 2026 Indian market prices for this item"}

{lang_instruction}

Provide PRACTICAL negotiation advice:
1. Quick verdict: Is this price fair, slightly high, or overpriced? (1 line)
2. A ready-to-use negotiation phrase the buyer can say directly to the vendor (make it natural!)
3. One smart tip (bulk discount, quality check, timing, etc.)

STYLE:
- Keep it under 80 words total
- Be warm and friendly, like advice from a helpful neighbor
- NO markdown, NO bullet points, NO asterisks
- Write as flowing text, like someone speaking
- Remember: respectful bargaining is an art form in Indian markets! 🙏"""

    try:
        result = await asyncio.to_thread(_sync_generate, prompt)
        return result
    except Exception as e:
        print(f"Negotiation advice error: {e}")
        # WHY: Fallback advice when API fails
        if language == "Hindi":
            return "भाई साहब, थोड़ा कम कर दीजिए। बाज़ार में देखकर आया हूँ, ₹10-15 कम में मिल रहा है। रोज़ का ग्राहक बनूँगा! 🙏"
        elif language == "Tamil":
            return "அண்ணா, கொஞ்சம் குறைங்க. தினமும் வாங்குவேன். நல்ல விலைக்கு கொடுங்க! 🙏"
        else:
            return "Bhaiya, thoda kam kar do na. Market mein dekh ke aaya hoon, ₹10-15 kam mein mil raha hai. Regular customer ban jayenge! 🙏"


async def detect_language(text: str) -> str:
    """
    Detects the language of the input text.
    
    WHY: Auto-detection helps users who may not know how to 
    select their source language explicitly.
    
    Args:
        text: The text to analyze
    
    Returns:
        Detected language name
    """
    prompt = f"""Identify the language of this text. 
Respond with ONLY ONE word - the language name from this exact list:
Hindi, Tamil, Telugu, Bengali, Marathi, Kannada, Gujarati, Punjabi, English

Just the language name, nothing else. No punctuation.

Text: {text}"""

    try:
        result = await asyncio.to_thread(_sync_generate, prompt)
        detected = result.strip()
        # Validate response - clean up any extra text
        for lang in SUPPORTED_LANGUAGES:
            if lang.lower() in detected.lower():
                return lang
        return "Hindi"  # Default fallback
    except Exception as e:
        print(f"Language detection error: {e}")
        return "Hindi"


async def get_price_insight(item: str, location: str = "India") -> str:
    """
    Gets AI-powered insights about commodity prices.
    
    Args:
        item: The item to get insights for
        location: The market location
    
    Returns:
        Price insight and tips
    """
    prompt = f"""You are a market analyst expert for Indian agricultural markets and mandis.

For the item "{item}" in {location} markets (January 2026 season):

1. What's the typical retail price range per kg?
2. Is it currently in season or off-season?
3. One insider buying tip for getting the best deal

Keep response under 60 words, conversational tone.
No markdown formatting.
If you're unsure about exact prices, give a reasonable estimate based on typical Indian market prices."""

    try:
        result = await asyncio.to_thread(_sync_generate, prompt)
        return result
    except Exception as e:
        print(f"Price insight error: {e}")
        return "Price data temporarily unavailable. Generally, buy seasonal produce in the morning for freshest quality and best prices!"


async def chat_with_assistant(message: str, language: str = "Hinglish") -> str:
    """
    AI-powered vendor/buyer assistant for market-related queries.
    
    WHY: Provides a conversational interface for any market-related
    questions in the user's preferred language.
    
    Args:
        message: User's question or message
        language: Preferred language for response
    
    Returns:
        Helpful response in the specified language
    """
    lang_instruction = ""
    if language == "Hinglish":
        lang_instruction = "Respond in Hinglish (natural mix of Hindi and English in Roman script)."
    elif language in SUPPORTED_LANGUAGES and language != "English":
        native = SUPPORTED_LANGUAGES[language]
        lang_instruction = f"Respond in {language} using {native} script."
    else:
        lang_instruction = "Respond in simple, friendly English."
    
    prompt = f"""You are a helpful AI assistant for Indian market vendors and buyers at local mandis (vegetable/fruit markets).

{lang_instruction}

You can help with:
- Market prices and trends
- Negotiation tips
- Quality assessment of produce
- Storage and handling tips
- Best time to buy/sell
- Market locations and timings
- Any other market-related questions

User's question: {message}

Provide a helpful, practical response. Keep it under 100 words.
Be friendly and conversational, like a knowledgeable friend who works in the market.
No markdown formatting."""

    try:
        result = await asyncio.to_thread(_sync_generate, prompt)
        return result
    except Exception as e:
        print(f"Chat assistant error: {e}")
        return "Sorry, I couldn't process that. Please try asking again!"


async def generate_smart_phrases(item: str, context: str, language: str = "Hinglish") -> str:
    """
    Generates culturally appropriate bargaining phrases.
    
    WHY: Pre-made phrases help non-native speakers or shy buyers
    negotiate confidently in the local style.
    
    Args:
        item: The item being purchased
        context: The negotiation context (e.g., "high price", "bulk buy")
        language: Target language for phrases
    
    Returns:
        Ready-to-use negotiation phrases
    """
    lang_instruction = ""
    if language == "Hinglish":
        lang_instruction = "Generate phrases in Hinglish (Hindi-English mix in Roman script)."
    elif language in SUPPORTED_LANGUAGES and language != "English":
        native = SUPPORTED_LANGUAGES[language]
        lang_instruction = f"Generate phrases in {language} using {native} script."
    else:
        lang_instruction = "Generate phrases in simple English with Indian cultural context."
    
    prompt = f"""Generate 3 natural, ready-to-use bargaining phrases for buying {item} at an Indian mandi.

Context: {context}
{lang_instruction}

Format: Just list the 3 phrases, one per line.
Make them sound natural - like what a local would actually say.
Include the warm, respectful tone typical of Indian market interactions.
No numbering, no explanations, just the phrases."""

    try:
        result = await asyncio.to_thread(_sync_generate, prompt)
        return result
    except Exception as e:
        print(f"Smart phrases error: {e}")
        if language == "Hinglish":
            return """Bhaiya, aaj rate kya hai? Thoda fresh wala dikhao na.
Itna mehnga? Woh saamne wale bhaiya se 5 rupaye kam mein mil raha hai!
Accha chal, 2 kg le leta hoon, thoda discount dedo na?"""
        return """What's today's rate? Show me something fresh please.
That seems a bit high, I saw it cheaper at the next stall.
Okay, I'll take 2 kg, can you give a small discount?"""


# ===== TODO =====
# TODO: Add response caching with Redis for production
# TODO: Implement rate limiting per user
# TODO: Add support for text-to-speech audio generation
# NEXT_DEVELOPER: Consider adding translation memory for repeated phrases
