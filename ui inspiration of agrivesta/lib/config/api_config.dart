/// API Configuration for EcoBazaarX Backend Integration
/// 
/// This file contains all backend API endpoint configurations
/// Update BASE_URL for production deployment

class ApiConfig {
  // ============================================================
  // ENVIRONMENT CONFIGURATION
  // ============================================================
  
  /// Local development backend URL
  static const String LOCAL_BASE_URL = 'http://localhost:8080/api';
  
  /// Production backend URL (Render deployment)
  /// Update this URL after deploying backend on Render
  static const String PROD_BASE_URL = 'https://ecobazaar-backend.onrender.com/api';
  
  /// Current active environment
  /// Using PROD_BASE_URL for Firebase deployment
  static const String BASE_URL = PROD_BASE_URL;
  
  // ============================================================
  // API ENDPOINTS
  // ============================================================
  
  /// Eco Challenges API Endpoints
  static const String ECO_CHALLENGES = '$BASE_URL/eco-challenges';
  static const String ECO_CHALLENGES_ACTIVE = '$ECO_CHALLENGES/active';
  static const String ECO_CHALLENGES_USER = '$ECO_CHALLENGES/user';
  static const String ECO_CHALLENGES_INITIALIZE = '$ECO_CHALLENGES/initialize-sample-data';
  
  /// Eco Discounts API Endpoints
  static const String ECO_DISCOUNTS = '$BASE_URL/eco-discounts';
  static const String ECO_DISCOUNTS_ACTIVE = '$ECO_DISCOUNTS/active';
  static const String ECO_DISCOUNTS_VALIDATE = '$ECO_DISCOUNTS/validate';
  static const String ECO_DISCOUNTS_APPLY = '$ECO_DISCOUNTS/apply';
  static const String ECO_DISCOUNTS_INITIALIZE = '$ECO_DISCOUNTS/initialize-sample-data';
  
  /// Leaderboard API Endpoints
  static const String LEADERBOARD = '$BASE_URL/leaderboard';
  static const String LEADERBOARD_GLOBAL = '$LEADERBOARD/global';
  static const String LEADERBOARD_TOP10_POINTS = '$LEADERBOARD/top10/eco-points';
  static const String LEADERBOARD_TOP10_CARBON = '$LEADERBOARD/top10/carbon-saved';
  static const String LEADERBOARD_TOP10_CHALLENGES = '$LEADERBOARD/top10/challenges';
  static const String LEADERBOARD_PROFILE = '$LEADERBOARD/profile';
  static const String LEADERBOARD_STATISTICS = '$LEADERBOARD/statistics/global';
  
  /// Carbon Footprint API Endpoints
  static const String CARBON_FOOTPRINT = '$BASE_URL/carbon-footprint';
  static const String CARBON_CALCULATE = '$CARBON_FOOTPRINT/calculate';
  static const String CARBON_USER_HISTORY = '$CARBON_FOOTPRINT/user';
  static const String CARBON_INITIALIZE = '$CARBON_FOOTPRINT/initialize-emission-factors';
  static const String CARBON_HEALTH = '$CARBON_FOOTPRINT/health';
  
  /// Orders API Endpoints (already implemented)
  static const String ORDERS = '$BASE_URL/orders';
  
  /// Cart API Endpoints (if needed)
  static const String CART = '$BASE_URL/cart';
  
  // ============================================================
  // HTTP CONFIGURATION
  // ============================================================
  
  /// Request timeout duration
  static const Duration REQUEST_TIMEOUT = Duration(seconds: 30);
  
  /// Retry configuration
  static const int MAX_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);
  
  /// Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // ============================================================
  // HELPER METHODS
  // ============================================================
  
  /// Get full URL for eco challenges user endpoint
  static String getEcoChallengesUserUrl(String userId) {
    return '$ECO_CHALLENGES_USER/$userId';
  }
  
  /// Get full URL for user challenge stats
  static String getEcoChallengesUserStatsUrl(String userId) {
    return '$ECO_CHALLENGES_USER/$userId/stats';
  }
  
  /// Get full URL for eco discounts user endpoint
  static String getEcoDiscountsUserUrl(String userId) {
    return '$ECO_DISCOUNTS/user/$userId/applicable';
  }
  
  /// Get full URL for discount code lookup
  static String getDiscountByCodeUrl(String code) {
    return '$ECO_DISCOUNTS/code/$code';
  }
  
  /// Get full URL for leaderboard user profile
  static String getLeaderboardProfileUrl(String userId) {
    return '$LEADERBOARD_PROFILE/$userId';
  }
  
  /// Get full URL for user ranking info
  static String getLeaderboardRankUrl(String userId) {
    return '$LEADERBOARD_PROFILE/$userId/rank';
  }
  
  /// Get full URL for carbon footprint user history
  static String getCarbonUserHistoryUrl(String userId) {
    return '$CARBON_USER_HISTORY/$userId/history';
  }
  
  /// Get full URL for carbon footprint user statistics
  static String getCarbonUserStatsUrl(String userId) {
    return '$CARBON_USER_HISTORY/$userId/statistics';
  }
  
  // ============================================================
  // ENVIRONMENT CHECKS
  // ============================================================
  
  /// Check if running in production mode
  static bool get isProduction => BASE_URL == PROD_BASE_URL;
  
  /// Check if running in development mode
  static bool get isDevelopment => BASE_URL == LOCAL_BASE_URL;
  
  /// Get current environment name
  static String get environmentName => isProduction ? 'Production' : 'Development';
  
  // ============================================================
  // DEBUG INFORMATION
  // ============================================================
  
  /// Print API configuration (for debugging)
  static void printConfiguration() {
    print('═══════════════════════════════════════════════════════');
    print('🌐 API Configuration - EcoBazaarX');
    print('═══════════════════════════════════════════════════════');
    print('Environment: $environmentName');
    print('Base URL: $BASE_URL');
    print('───────────────────────────────────────────────────────');
    print('Endpoints:');
    print('  • Eco Challenges: $ECO_CHALLENGES');
    print('  • Eco Discounts: $ECO_DISCOUNTS');
    print('  • Leaderboard: $LEADERBOARD');
    print('  • Carbon Footprint: $CARBON_FOOTPRINT');
    print('  • Orders: $ORDERS');
    print('═══════════════════════════════════════════════════════');
  }
}
