// Firebase configuration for EcoBazaarX
// App Nickname: ecobazaarx
// App ID: 1:321134139960:web:8e7f3c2dd23ba98a32a4cd

class FirebaseConfig {
  // Firebase configuration object
  static const Map<String, dynamic> config = {
    'apiKey': 'AIzaSyBDFe6o3M18xli1ssoNE2db_8luRpF8wCk',
    'authDomain': 'ecobazzarx.firebaseapp.com',
    'projectId': 'ecobazzarx',
    'storageBucket': 'ecobazzarx.firebasestorage.app',
    'messagingSenderId': '321134139960',
    'appId': '1:321134139960:web:8e7f3c2dd23ba98a32a4cd',
    'measurementId': 'G-0TYKMV0NS9',
  };

  // App information
  static const String appName = 'EcoBazaarX';
  static const String appNickname = 'ecobazaarx';
  static const String appId = '1:321134139960:web:8e7f3c2dd23ba98a32a4cd';
  static const String projectId = 'ecobazzarx';

  // Firebase services configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformance = true;
  static const bool enableRemoteConfig = true;

  // Authentication settings - DISABLED (using Spring Boot auth)
  static const bool enableEmailAuth = false;
  static const bool enableGoogleAuth = false;
  static const bool enablePhoneAuth = false;
  static const bool enableAnonymousAuth = false;

  // Firestore settings
  static const String usersCollection = 'users';
  static const String storesCollection = 'stores';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String carbonTrackingCollection = 'carbon_tracking';
  static const String ecoChallengesCollection = 'eco_challenges';
  static const String wishlistCollection = 'wishlist';
  static const String cartCollection = 'cart';
  static const String reviewsCollection = 'reviews';
  static const String analyticsCollection = 'analytics';
  static const String settingsCollection = 'settings';

  // Storage settings
  static const String userImagesPath = 'users/images';
  static const String productImagesPath = 'products/images';
  static const String storeImagesPath = 'stores/images';
  static const String categoryImagesPath = 'categories/images';

  // Security rules paths
  static const String securityRulesPath = 'firestore.rules';
  static const String storageRulesPath = 'storage.rules';

  // Environment settings
  static const bool isProduction = true; // Set to false for local development
  static const String environment = 'production'; // 'development' or 'production'

  // Backend API URLs
  // LOCAL DEVELOPMENT: Use localhost backend (start with .\mvnw.cmd spring-boot:run)
  static const String localApiUrl = 'http://localhost:8080';
  
  // PRODUCTION: Use Render deployed backend
  static const String productionApiUrl = 'https://backend-springboot-ymgn.onrender.com';
  
  // Auto-select based on environment
  static const String baseApiUrl = isProduction ? productionApiUrl : localApiUrl;
  
  // API endpoint paths
  static const String authApiUrl = '$baseApiUrl/api/auth';
  static const String storesApiUrl = '$baseApiUrl/api/stores';
  static const String productsApiUrl = '$baseApiUrl/api/products';
  static const String ordersApiUrl = '$baseApiUrl/api/orders';
  static const String ecoChallengesApiUrl = '$baseApiUrl/api/eco-challenges';
  static const String ecoDiscountsApiUrl = '$baseApiUrl/api/eco-discounts';
  static const String leaderboardApiUrl = '$baseApiUrl/api/leaderboard';
  static const String carbonFootprintApiUrl = '$baseApiUrl/api/carbon-footprint';

  // Error messages
  static const Map<String, String> errorMessages = {
    'auth/user-not-found': 'No user found with this email address.',
    'auth/wrong-password': 'Incorrect password. Please try again.',
    'auth/email-already-in-use': 'An account already exists with this email.',
    'auth/weak-password': 'Password is too weak. Please choose a stronger password.',
    'auth/invalid-email': 'Please enter a valid email address.',
    'auth/too-many-requests': 'Too many failed attempts. Please try again later.',
    'auth/network-request-failed': 'Network error. Please check your connection.',
    'firestore/permission-denied': 'You don\'t have permission to access this resource.',
    'firestore/unavailable': 'Service temporarily unavailable. Please try again.',
    'storage/unauthorized': 'You don\'t have permission to upload files.',
    'storage/quota-exceeded': 'Storage quota exceeded. Please contact support.',
  };

  // Success messages
  static const Map<String, String> successMessages = {
    'auth/signup-success': 'Account created successfully!',
    'auth/login-success': 'Welcome back!',
    'auth/logout-success': 'Logged out successfully.',
    'profile/update-success': 'Profile updated successfully!',
    'store/create-success': 'Store created successfully!',
    'product/add-success': 'Product added successfully!',
    'order/place-success': 'Order placed successfully!',
    'cart/add-success': 'Item added to cart!',
    'wishlist/add-success': 'Item added to wishlist!',
    'review/submit-success': 'Review submitted successfully!',
  };

  // Validation rules
  static const Map<String, dynamic> validationRules = {
    'email': {
      'pattern': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      'message': 'Please enter a valid email address.',
    },
    'password': {
      'minLength': 8,
      'requireUppercase': true,
      'requireLowercase': true,
      'requireNumbers': true,
      'requireSpecialChars': false,
      'message': 'Password must be at least 8 characters long.',
    },
    'phone': {
      'pattern': r'^\+?[1-9]\d{1,14}$',
      'message': 'Please enter a valid phone number.',
    },
    'name': {
      'minLength': 2,
      'maxLength': 50,
      'message': 'Name must be between 2 and 50 characters.',
    },
    'storeName': {
      'minLength': 3,
      'maxLength': 100,
      'message': 'Store name must be between 3 and 100 characters.',
    },
    'productName': {
      'minLength': 3,
      'maxLength': 200,
      'message': 'Product name must be between 3 and 200 characters.',
    },
    'price': {
      'minValue': 0.01,
      'maxValue': 999999.99,
      'message': 'Price must be between ₹0.01 and ₹999,999.99.',
    },
  };

  // App features configuration
  static const Map<String, bool> features = {
    'carbonTracking': true,
    'ecoChallenges': true,
    'wishlist': true,
    'reviews': true,
    'notifications': true,
    'analytics': true,
    'offlineMode': true,
    'pushNotifications': true,
    'emailNotifications': true,
    'socialLogin': true,
    'guestMode': false,
    'darkMode': true,
    'multiLanguage': false,
    'voiceSearch': false,
    'arView': false,
  };

  // Analytics events
  static const Map<String, String> analyticsEvents = {
    'user_signup': 'user_signup',
    'user_login': 'user_login',
    'user_logout': 'user_logout',
    'product_view': 'product_view',
    'product_purchase': 'product_purchase',
    'cart_add': 'cart_add',
    'cart_remove': 'cart_remove',
    'wishlist_add': 'wishlist_add',
    'wishlist_remove': 'wishlist_remove',
    'store_view': 'store_view',
    'search_performed': 'search_performed',
    'filter_applied': 'filter_applied',
    'review_submitted': 'review_submitted',
    'challenge_started': 'challenge_started',
    'challenge_completed': 'challenge_completed',
    'carbon_saved': 'carbon_saved',
    'eco_tip_viewed': 'eco_tip_viewed',
  };

  // Remote config defaults
  static const Map<String, dynamic> remoteConfigDefaults = {
    'welcome_message': 'Welcome to EcoBazaarX - Your Sustainable Shopping Destination!',
    'featured_categories': ['Food & Beverages', 'Clothing & Fashion', 'Home & Garden'],
    'max_cart_items': 50,
    'max_wishlist_items': 100,
    'carbon_calculation_factor': 0.5,
    'challenge_reward_multiplier': 1.0,
    'free_shipping_threshold': 1000.0,
    'app_version_required': '1.0.0',
    'maintenance_mode': false,
    'maintenance_message': 'We\'re currently performing maintenance. Please try again later.',
  };

  // Performance monitoring
  static const Map<String, dynamic> performanceConfig = {
    'enableNetworkMonitoring': true,
    'enableHttpMonitoring': true,
    'enableDatabaseMonitoring': true,
    'enableCrashMonitoring': true,
    'enableMemoryMonitoring': true,
    'enableBatteryMonitoring': true,
  };

  // Debug settings
  static const Map<String, bool> debugSettings = {
    'enableLogging': true,
    'enableAnalyticsDebug': false,
    'enablePerformanceDebug': false,
    'enableCrashlyticsDebug': false,
    'enableRemoteConfigDebug': false,
    'enableFirestoreDebug': false,
    'enableAuthDebug': false,
    'enableStorageDebug': false,
  };
}

// Helper class for Firebase service initialization
class FirebaseServiceConfig {
  static const String authService = 'authentication';
  static const String firestoreService = 'firestore';
  static const String storageService = 'storage';
  static const String analyticsService = 'analytics';
  static const String crashlyticsService = 'crashlytics';
  static const String performanceService = 'performance';
  static const String remoteConfigService = 'remote_config';
  static const String messagingService = 'messaging';
  static const String functionsService = 'functions';

  // Service status
  static const Map<String, bool> serviceStatus = {
    'authentication': true,
    'firestore': true,
    'storage': true,
    'analytics': true,
    'crashlytics': true,
    'performance': true,
    'remote_config': true,
    'messaging': false, // Disabled for now
    'functions': false, // Disabled for now
  };
}

// Environment-specific configurations
class EnvironmentConfig {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  static const Map<String, Map<String, dynamic>> configs = {
    'development': {
      'enableLogging': true,
      'enableAnalyticsDebug': true,
      'enablePerformanceDebug': true,
      'enableCrashlyticsDebug': true,
      'enableRemoteConfigDebug': true,
      'enableFirestoreDebug': true,
      'enableAuthDebug': true,
      'enableStorageDebug': true,
    },
    'staging': {
      'enableLogging': true,
      'enableAnalyticsDebug': false,
      'enablePerformanceDebug': false,
      'enableCrashlyticsDebug': false,
      'enableRemoteConfigDebug': true,
      'enableFirestoreDebug': false,
      'enableAuthDebug': false,
      'enableStorageDebug': false,
    },
    'production': {
      'enableLogging': false,
      'enableAnalyticsDebug': false,
      'enablePerformanceDebug': false,
      'enableCrashlyticsDebug': false,
      'enableRemoteConfigDebug': false,
      'enableFirestoreDebug': false,
      'enableAuthDebug': false,
      'enableStorageDebug': false,
    },
  };
}
