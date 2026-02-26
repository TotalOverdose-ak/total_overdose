class AppConfig {
  // Debug configuration
  static const bool isDebugMode = false; // Set to false for production
  static const bool enableDetailedLogging = false; // Set to false to reduce console noise
  static const bool enableNetworkLogging = false; // Set to false to reduce API call logs
  static const bool designDemoMode = true; // Set true to run app without backend dependencies
  
  // API configuration
  static const String appName = 'EcoBazaarX';
  static const String appVersion = '1.0.0';
  
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