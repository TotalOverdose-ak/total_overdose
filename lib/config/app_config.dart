class AppConfig {
  // Debug configuration
  static const bool isDebugMode = false; // Set to false for production
  static const bool enableDetailedLogging =
      false; // Set to false to reduce console noise
  static const bool enableNetworkLogging =
      false; // Set to false to reduce API call logs
  static const bool designDemoMode =
      true; // Set true to run app without backend dependencies

  // API configuration
  static const String appName = 'EcoBazaarX';
  static const String appVersion = '1.0.0';

  // ── AI Configuration (Dual Fallback) ──────────────────────────────────────
  // Primary: Gemini direct API (fast, but 15 RPM free tier limit)
  // Fallback: Flask proxy → OpenRouter (when Gemini rate limited)

  // Gemini direct config (PRIMARY)
  static const String geminiApiKey = 'AIzaSyBLsfQrOLPY0wKMBSO9ePR9S8imrzXGq9k';
  static const String geminiModel = 'gemini-1.5-flash';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions';

  // Flask proxy config (FALLBACK — when Gemini rate limited)
  // Android emulator: 10.0.2.2, Real device: use PC's IP
  static const String proxyBaseUrl = 'http://10.0.2.2:5000/api/chat';

  // Logging levels
  static const bool logErrors = true;
  static const bool logWarnings = true;
  static const bool logInfo = isDebugMode;
  static const bool logDebug = isDebugMode && enableDetailedLogging;
}

class Logger {
  static void error(String message) {
    if (AppConfig.logErrors) {
      print('[ERROR] $message');
    }
  }

  static void warning(String message) {
    if (AppConfig.logWarnings) {
      print('[WARNING] $message');
    }
  }

  static void info(String message) {
    if (AppConfig.logInfo) {
      print('[INFO] $message');
    }
  }

  static void debug(String message) {
    if (AppConfig.logDebug) {
      print('[DEBUG] $message');
    }
  }

  static void network(String message) {
    if (AppConfig.enableNetworkLogging) {
      print('[NETWORK] $message');
    }
  }
}
