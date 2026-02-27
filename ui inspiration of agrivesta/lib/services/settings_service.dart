import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class SettingsService {
  static const String _baseUrl = FirebaseConfig.baseApiUrl;
  static const String _settingsEndpoint = '/settings';

  // Get user settings
  static Future<Map<String, dynamic>> getUserSettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return getDefaultSettings();
      }
    } catch (e) {
      print('Error getting user settings: $e');
      return getDefaultSettings();
    }
  }

  // Update user settings
  static Future<Map<String, dynamic>> updateUserSettings({
    required String userId,
    bool? notifications,
    bool? darkMode,
    String? language,
    String? currency,
    String? theme,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'notifications': notifications,
          'darkMode': darkMode,
          'language': language,
          'currency': currency,
          'theme': theme,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update settings: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating settings: $e',
      };
    }
  }

  // Get app settings
  static Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_settingsEndpoint/app'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'appVersion': '1.0.0',
          'maintenanceMode': false,
          'supportedLanguages': ['en', 'hi', 'mr'],
          'supportedCurrencies': ['INR', 'USD', 'EUR'],
          'maxFileSize': 10485760, // 10MB
        };
      }
    } catch (e) {
      print('Error getting app settings: $e');
      return {
        'appVersion': '1.0.0',
        'maintenanceMode': false,
        'supportedLanguages': ['en', 'hi', 'mr'],
        'supportedCurrencies': ['INR', 'USD', 'EUR'],
        'maxFileSize': 10485760, // 10MB
      };
    }
  }

  // Get notification settings
  static Future<Map<String, dynamic>> getNotificationSettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/notifications'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'pushNotifications': true,
          'emailNotifications': true,
          'orderUpdates': true,
          'promotionalOffers': false,
          'priceAlerts': true,
        };
      }
    } catch (e) {
      print('Error getting notification settings: $e');
      return {
        'pushNotifications': true,
        'emailNotifications': true,
        'orderUpdates': true,
        'promotionalOffers': false,
        'priceAlerts': true,
      };
    }
  }

  // Update notification settings
  static Future<Map<String, dynamic>> updateNotificationSettings({
    required String userId,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? orderUpdates,
    bool? promotionalOffers,
    bool? priceAlerts,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/notifications'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pushNotifications': pushNotifications,
          'emailNotifications': emailNotifications,
          'orderUpdates': orderUpdates,
          'promotionalOffers': promotionalOffers,
          'priceAlerts': priceAlerts,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update notification settings: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating notification settings: $e',
      };
    }
  }

  // Get privacy settings
  static Future<Map<String, dynamic>> getPrivacySettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/privacy'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'profileVisibility': 'public',
          'showEmail': false,
          'showPhone': false,
          'allowDataCollection': true,
          'allowAnalytics': true,
        };
      }
    } catch (e) {
      print('Error getting privacy settings: $e');
      return {
        'profileVisibility': 'public',
        'showEmail': false,
        'showPhone': false,
        'allowDataCollection': true,
        'allowAnalytics': true,
      };
    }
  }

  // Update privacy settings
  static Future<Map<String, dynamic>> updatePrivacySettings({
    required String userId,
    String? profileVisibility,
    bool? showEmail,
    bool? showPhone,
    bool? allowDataCollection,
    bool? allowAnalytics,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/privacy'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'profileVisibility': profileVisibility,
          'showEmail': showEmail,
          'showPhone': showPhone,
          'allowDataCollection': allowDataCollection,
          'allowAnalytics': allowAnalytics,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update privacy settings: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating privacy settings: $e',
      };
    }
  }

  // Get security settings
  static Future<Map<String, dynamic>> getSecuritySettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/security'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'twoFactorAuth': false,
          'loginAlerts': true,
          'sessionTimeout': 30, // minutes
          'passwordExpiry': 90, // days
        };
      }
    } catch (e) {
      print('Error getting security settings: $e');
      return {
        'twoFactorAuth': false,
        'loginAlerts': true,
        'sessionTimeout': 30, // minutes
        'passwordExpiry': 90, // days
      };
    }
  }

  // Update security settings
  static Future<Map<String, dynamic>> updateSecuritySettings({
    required String userId,
    bool? twoFactorAuth,
    bool? loginAlerts,
    int? sessionTimeout,
    int? passwordExpiry,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/security'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'twoFactorAuth': twoFactorAuth,
          'loginAlerts': loginAlerts,
          'sessionTimeout': sessionTimeout,
          'passwordExpiry': passwordExpiry,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update security settings: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating security settings: $e',
      };
    }
  }

  // Reset settings to default
  static Future<Map<String, dynamic>> resetSettingsToDefault(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/reset'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to reset settings: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error resetting settings: $e',
      };
    }
  }

  // Export user data
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/export'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to export user data: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error exporting user data: $e',
      };
    }
  }

  // Delete user data
  static Future<Map<String, dynamic>> deleteUserData(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to delete user data: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting user data: $e',
      };
    }
  }

  // Get default settings
  static Map<String, dynamic> getDefaultSettings() {
    return {
      'notifications': true,
      'darkMode': false,
      'language': 'en',
      'currency': 'INR',
      'theme': 'light',
      'pushNotifications': true,
      'emailNotifications': true,
      'orderUpdates': true,
      'promotionalOffers': false,
      'priceAlerts': true,
      'profileVisibility': 'public',
      'showEmail': false,
      'showPhone': false,
      'allowDataCollection': true,
      'allowAnalytics': true,
      'twoFactorAuth': false,
      'loginAlerts': true,
      'sessionTimeout': 30,
      'passwordExpiry': 90,
    };
  }

  // Initialize user settings for new users
  static Future<void> initializeUserSettings(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_settingsEndpoint/$userId/initialize'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(getDefaultSettings()),
      );

      if (response.statusCode == 200) {
        print('User settings initialized successfully for user: $userId');
      } else {
        print('Failed to initialize user settings for user: $userId');
      }
    } catch (e) {
      print('Error initializing user settings for user: $userId - $e');
    }
  }
}