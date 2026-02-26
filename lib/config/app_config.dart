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

  // ── Gemini AI Configuration ───────────────────────────────────────────────
  // ⚠️ UPDATE THIS KEY if Gemini API stops working!
  // Get a new key from: https://aistudio.google.com/apikey
  static const String geminiApiKey = 'AIzaSyBgN4ijOo--Tquajvv1_D8A8ifi6U8Tw_4';
  static const String geminiModel = 'gemini-2.0-flash';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

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
